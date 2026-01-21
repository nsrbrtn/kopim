import 'dart:async';

import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/ai/data/local/ai_analytics_dao.dart';
import 'package:kopim/features/ai/domain/entities/ai_financial_overview_entity.dart';
import 'package:kopim/features/ai/domain/repositories/ai_financial_data_repository.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_category_allocation.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/budgets/domain/services/budget_schedule.dart';

part 'ai_financial_data_repository_impl.g.dart';

class AiFinancialDataRepositoryImpl implements AiFinancialDataRepository {
  AiFinancialDataRepositoryImpl({
    required AiAnalyticsDao analyticsDao,
    required BudgetSchedule budgetSchedule,
    DateTime Function()? nowProvider,
  }) : _analyticsDao = analyticsDao,
       _budgetSchedule = budgetSchedule,
       _nowProvider = nowProvider ?? DateTime.now;

  final AiAnalyticsDao _analyticsDao;
  final BudgetSchedule _budgetSchedule;
  final DateTime Function() _nowProvider;

  @override
  Future<AiFinancialOverview> loadOverview({
    required AiDataFilter filter,
  }) async {
    final List<MonthlyExpenseAggregate> monthlyExpenses = await _analyticsDao
        .getMonthlyExpenses(filter);
    final List<MonthlyIncomeAggregate> monthlyIncome = await _analyticsDao
        .getMonthlyIncome(filter);
    final List<CategoryExpenseAggregate> topCategories = await _analyticsDao
        .getTopCategories(filter);
    final List<CategoryIncomeAggregate> topIncomeCategories =
        await _analyticsDao.getTopIncomeCategories(filter);
    final List<BudgetInstanceAggregate> budgetInstances = await _analyticsDao
        .getBudgetForecasts(filter);
    final List<db.BudgetRow> activeBudgets = await _analyticsDao
        .getActiveBudgets();

    final List<BudgetInstanceAggregate> mergedBudgets = await _mergeBudgets(
      budgets: activeBudgets,
      instances: budgetInstances,
    );

    final Set<String> allCategoryIds = mergedBudgets
        .expand((BudgetInstanceAggregate b) => b.categoryIds)
        .toSet();
    final Map<String, String> categoryNames = await _analyticsDao
        .getCategoryNames(allCategoryIds.toList(growable: false));

    return _composeOverview(
      monthlyExpenses: monthlyExpenses,
      monthlyIncome: monthlyIncome,
      topCategories: topCategories,
      topIncomeCategories: topIncomeCategories,
      budgetInstances: mergedBudgets,
      categoryNamesMap: categoryNames,
      filter: filter,
    );
  }

  @override
  Stream<AiFinancialOverview> watchOverview({required AiDataFilter filter}) {
    return Stream<AiFinancialOverview>.multi((
      StreamController<AiFinancialOverview> controller,
    ) {
      List<MonthlyExpenseAggregate>? monthly;
      List<MonthlyIncomeAggregate>? incomes;
      List<CategoryExpenseAggregate>? categories;
      List<CategoryIncomeAggregate>? incomeCategories;
      List<BudgetInstanceAggregate>? existingInstances;
      List<db.BudgetRow>? activeBudgets;
      bool isClosed = false;

      void emitIfReady() async {
        if (isClosed ||
            monthly == null ||
            incomes == null ||
            categories == null ||
            incomeCategories == null ||
            existingInstances == null ||
            activeBudgets == null) {
          return;
        }

        final List<BudgetInstanceAggregate> mergedBudgets = await _mergeBudgets(
          budgets: activeBudgets!,
          instances: existingInstances!,
        );

        final Set<String> allCategoryIds = mergedBudgets
            .expand((BudgetInstanceAggregate b) => b.categoryIds)
            .toSet();
        final Map<String, String> categoryNames = await _analyticsDao
            .getCategoryNames(allCategoryIds.toList(growable: false));

        if (isClosed) return;

        controller.add(
          _composeOverview(
            monthlyExpenses: monthly!,
            monthlyIncome: incomes!,
            topCategories: categories!,
            topIncomeCategories: incomeCategories!,
            budgetInstances: mergedBudgets,
            categoryNamesMap: categoryNames,
            filter: filter,
          ),
        );
      }

      final StreamSubscription<List<MonthlyExpenseAggregate>> monthlySub =
          _analyticsDao.watchMonthlyExpenses(filter).listen((
            List<MonthlyExpenseAggregate> data,
          ) {
            monthly = data;
            emitIfReady();
          });
      final StreamSubscription<List<MonthlyIncomeAggregate>> incomeSub =
          _analyticsDao.watchMonthlyIncome(filter).listen((
            List<MonthlyIncomeAggregate> data,
          ) {
            incomes = data;
            emitIfReady();
          });
      final StreamSubscription<List<CategoryExpenseAggregate>> categoriesSub =
          _analyticsDao.watchTopCategories(filter).listen((
            List<CategoryExpenseAggregate> data,
          ) {
            categories = data;
            emitIfReady();
          });
      final StreamSubscription<List<CategoryIncomeAggregate>>
      incomeCategoriesSub = _analyticsDao
          .watchTopIncomeCategories(filter)
          .listen((List<CategoryIncomeAggregate> data) {
            incomeCategories = data;
            emitIfReady();
          });
      final StreamSubscription<List<BudgetInstanceAggregate>> budgetsSub =
          _analyticsDao.watchBudgetForecasts(filter).listen((
            List<BudgetInstanceAggregate> data,
          ) {
            existingInstances = data;
            emitIfReady();
          });
      final StreamSubscription<List<db.BudgetRow>> activeBudgetsSub =
          _analyticsDao.watchActiveBudgets().listen((List<db.BudgetRow> data) {
            activeBudgets = data;
            emitIfReady();
          });

      controller.onCancel = () async {
        isClosed = true;
        await Future.wait<void>(<Future<void>>[
          monthlySub.cancel(),
          incomeSub.cancel(),
          categoriesSub.cancel(),
          incomeCategoriesSub.cancel(),
          budgetsSub.cancel(),
          activeBudgetsSub.cancel(),
        ]);
      };
    });
  }

  AiFinancialOverview _composeOverview({
    required List<MonthlyExpenseAggregate> monthlyExpenses,
    required List<MonthlyIncomeAggregate> monthlyIncome,
    required List<CategoryExpenseAggregate> topCategories,
    required List<CategoryIncomeAggregate> topIncomeCategories,
    required List<BudgetInstanceAggregate> budgetInstances,
    required Map<String, String> categoryNamesMap,
    required AiDataFilter filter,
  }) {
    final DateTime generatedAt = _nowProvider();
    final List<MonthlyExpenseInsight> monthlyInsights = monthlyExpenses
        .sortedBy<DateTime>((MonthlyExpenseAggregate value) => value.month)
        .map(
          (MonthlyExpenseAggregate aggregate) => MonthlyExpenseInsight(
            month: DateTime(aggregate.month.year, aggregate.month.month),
            totalExpense: aggregate.totalExpense,
          ),
        )
        .toList(growable: false);

    final List<MonthlyIncomeInsight> monthlyIncomeInsights = monthlyIncome
        .sortedBy<DateTime>((MonthlyIncomeAggregate value) => value.month)
        .map(
          (MonthlyIncomeAggregate aggregate) => MonthlyIncomeInsight(
            month: DateTime(aggregate.month.year, aggregate.month.month),
            totalIncome: aggregate.totalIncome,
          ),
        )
        .toList(growable: false);

    final List<CategoryExpenseInsight> categoryInsights = topCategories
        .map(
          (CategoryExpenseAggregate aggregate) => CategoryExpenseInsight(
            categoryId: aggregate.categoryId,
            displayName: aggregate.displayName,
            totalExpense: aggregate.totalExpense,
            color: aggregate.color,
          ),
        )
        .toList(growable: false);

    final List<CategoryIncomeInsight> incomeInsights = topIncomeCategories
        .map(
          (CategoryIncomeAggregate aggregate) => CategoryIncomeInsight(
            categoryId: aggregate.categoryId,
            displayName: aggregate.displayName,
            totalIncome: aggregate.totalIncome,
            color: aggregate.color,
          ),
        )
        .toList(growable: false);

    final List<BudgetForecastInsight> budgetForecasts = budgetInstances
        .where(
          (BudgetInstanceAggregate aggregate) =>
              _matchesFilter(aggregate, filter),
        )
        .map(
          (BudgetInstanceAggregate aggregate) =>
              _mapBudgetForecast(aggregate, generatedAt, categoryNamesMap),
        )
        .toList(growable: false);

    return AiFinancialOverview(
      monthlyExpenses: monthlyInsights,
      monthlyIncomes: monthlyIncomeInsights,
      topCategories: categoryInsights,
      topIncomeCategories: incomeInsights,
      budgetForecasts: budgetForecasts,
      generatedAt: generatedAt,
    );
  }

  bool _matchesFilter(BudgetInstanceAggregate aggregate, AiDataFilter filter) {
    final Set<String> filterAccounts = filter.accountIds.toSet();
    final Set<String> filterCategories = filter.categoryIds.toSet();
    final bool accountMatches =
        filterAccounts.isEmpty ||
        aggregate.accountIds.isEmpty ||
        aggregate.accountIds.any(filterAccounts.contains);
    final bool categoryMatches =
        filterCategories.isEmpty ||
        aggregate.categoryIds.isEmpty ||
        aggregate.categoryIds.any(filterCategories.contains);
    return accountMatches && categoryMatches;
  }

  BudgetForecastInsight _mapBudgetForecast(
    BudgetInstanceAggregate aggregate,
    DateTime now,
    Map<String, String> categoryNamesMap,
  ) {
    final DateTime periodStart = aggregate.periodStart;
    final DateTime periodEnd = aggregate.periodEnd;
    final int totalDays = (periodEnd.difference(periodStart).inDays).abs() + 1;
    final DateTime clampedNow = now.isBefore(periodStart)
        ? periodStart
        : (now.isAfter(periodEnd) ? periodEnd : now);
    final int elapsedDays =
        (clampedNow.difference(periodStart).inDays).clamp(0, totalDays - 1) + 1;
    final MoneyAmount spent = aggregate.spent;
    final MoneyAmount allocated = aggregate.allocated;
    final int targetScale = spent.scale > allocated.scale
        ? spent.scale
        : allocated.scale;
    final MoneyAmount normalizedSpent = rescaleMoneyAmount(spent, targetScale);
    final MoneyAmount normalizedAllocated = rescaleMoneyAmount(
      allocated,
      targetScale,
    );
    final double spentValue = normalizedSpent.toDouble();
    final double allocatedValue = normalizedAllocated.toDouble();
    final double dailyRate = elapsedDays > 0 ? spentValue / elapsedDays : 0;
    final double projectedValue = elapsedDays > 0
        ? (dailyRate * totalDays)
        : spentValue;
    final MoneyAmount projectedSpent = MoneyAmount(
      minor: Money.fromDouble(
        projectedValue,
        currency: 'XXX',
        scale: targetScale,
      ).minor,
      scale: targetScale,
    );
    final MoneyAmount remaining = MoneyAmount(
      minor: normalizedAllocated.minor - normalizedSpent.minor,
      scale: targetScale,
    );
    final double completionRate = allocatedValue <= 0
        ? 0
        : (spentValue / allocatedValue).clamp(0, double.infinity);
    final BudgetForecastStatus status;
    if (normalizedSpent.minor >= normalizedAllocated.minor &&
        normalizedAllocated.minor > BigInt.zero) {
      status = BudgetForecastStatus.exceeded;
    } else if (projectedSpent.minor > normalizedAllocated.minor &&
        normalizedAllocated.minor > BigInt.zero) {
      status = BudgetForecastStatus.warning;
    } else {
      status = BudgetForecastStatus.onTrack;
    }

    final List<String> categoryNames = aggregate.categoryIds
        .map((String id) => categoryNamesMap[id] ?? 'Unknown')
        .toList(growable: false);

    return BudgetForecastInsight(
      budgetId: aggregate.budgetId,
      title: aggregate.title,
      periodStart: periodStart,
      periodEnd: periodEnd,
      allocated: normalizedAllocated,
      spent: normalizedSpent,
      projectedSpent: projectedSpent,
      remaining: remaining,
      completionRate: completionRate,
      status: status,
      categoryNames: categoryNames,
      accountIds: aggregate.accountIds,
    );
  }

  Future<List<BudgetInstanceAggregate>> _mergeBudgets({
    required List<db.BudgetRow> budgets,
    required List<BudgetInstanceAggregate> instances,
  }) async {
    final List<BudgetInstanceAggregate> results =
        List<BudgetInstanceAggregate>.from(instances);
    final Set<String> budgetIdsWithInstances = instances
        .map((BudgetInstanceAggregate i) => i.budgetId)
        .toSet();

    for (final db.BudgetRow row in budgets) {
      if (budgetIdsWithInstances.contains(row.id)) {
        continue;
      }

      // If budget has no instance for the period, calculate it on the fly
      final Budget budget = _mapBudgetRow(row);
      final ({DateTime start, DateTime end}) period = _budgetSchedule.periodFor(
        budget: budget,
        reference: _nowProvider(),
      );

      final MoneyAmount spent = await _analyticsDao.getBudgetSpent(
        categoryIds: budget.categories,
        accountIds: budget.accounts,
        start: period.start,
        end: period.end,
      );
      final MoneyAmount allocated = budget.amountValue;
      final MoneyAmount normalizedSpent = rescaleMoneyAmount(
        spent,
        allocated.scale,
      );

      results.add(
        BudgetInstanceAggregate(
          budgetId: budget.id,
          title: budget.title,
          periodStart: period.start,
          periodEnd: period.end,
          allocated: allocated,
          spent: normalizedSpent,
          accountIds: budget.accounts,
          categoryIds: budget.categories,
        ),
      );
    }
    return results;
  }

  Budget _mapBudgetRow(db.BudgetRow row) {
    return Budget(
      id: row.id,
      title: row.title,
      period: BudgetPeriodX.fromStorage(row.period),
      startDate: row.startDate,
      endDate: row.endDate,
      amount: row.amount,
      scope: BudgetScopeX.fromStorage(row.scope),
      categories: row.categories,
      accounts: row.accounts,
      categoryAllocations: row.categoryAllocations
          .map(
            (Map<String, dynamic> json) =>
                BudgetCategoryAllocation.fromJson(json),
          )
          .toList(growable: false),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
    );
  }
}

@riverpod
AiAnalyticsDao aiAnalyticsDao(Ref ref) {
  return AiAnalyticsDao(ref.watch(appDatabaseProvider));
}

@riverpod
AiFinancialDataRepository aiFinancialDataRepository(Ref ref) {
  return AiFinancialDataRepositoryImpl(
    analyticsDao: ref.watch(aiAnalyticsDaoProvider),
    budgetSchedule: ref.watch(budgetScheduleProvider),
  );
}
