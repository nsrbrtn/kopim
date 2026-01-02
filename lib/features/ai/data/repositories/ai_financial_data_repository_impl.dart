import 'dart:async';

import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/ai/data/local/ai_analytics_dao.dart';
import 'package:kopim/features/ai/domain/entities/ai_financial_overview_entity.dart';
import 'package:kopim/features/ai/domain/repositories/ai_financial_data_repository.dart';

part 'ai_financial_data_repository_impl.g.dart';

class AiFinancialDataRepositoryImpl implements AiFinancialDataRepository {
  AiFinancialDataRepositoryImpl({
    required AiAnalyticsDao analyticsDao,
    DateTime Function()? nowProvider,
  }) : _analyticsDao = analyticsDao,
       _nowProvider = nowProvider ?? DateTime.now;

  final AiAnalyticsDao _analyticsDao;
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

    final Set<String> allCategoryIds = budgetInstances
        .expand((BudgetInstanceAggregate b) => b.categoryIds)
        .toSet();
    final Map<String, String> categoryNames = await _analyticsDao
        .getCategoryNames(allCategoryIds.toList(growable: false));

    return _composeOverview(
      monthlyExpenses: monthlyExpenses,
      monthlyIncome: monthlyIncome,
      topCategories: topCategories,
      topIncomeCategories: topIncomeCategories,
      budgetInstances: budgetInstances,
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
      List<BudgetInstanceAggregate>? budgets;
      bool isClosed = false;

      void emitIfReady() async {
        if (isClosed ||
            monthly == null ||
            incomes == null ||
            categories == null ||
            incomeCategories == null ||
            budgets == null) {
          return;
        }

        // Note: For streaming, we are doing an async fetch inside the stream callback.
        //Ideally, this should be reactive too, but for now fetching names on demand is acceptable
        // strictly speaking this might introduce a small race or delay, but acceptable for this feature.
        final Set<String> allCategoryIds = budgets!
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
            budgetInstances: budgets!,
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
            budgets = data;
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
    final double spent = aggregate.spent;
    final double allocated = aggregate.allocated;
    final double dailyRate = elapsedDays > 0 ? spent / elapsedDays : 0;
    final double projected = elapsedDays > 0 ? (dailyRate * totalDays) : spent;
    final double remaining = allocated - spent;
    final double completionRate = allocated <= 0
        ? 0
        : (spent / allocated).clamp(0, double.infinity);
    final BudgetForecastStatus status;
    if (spent >= allocated && allocated > 0) {
      status = BudgetForecastStatus.exceeded;
    } else if (projected > allocated && allocated > 0) {
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
      allocated: allocated,
      spent: spent,
      projectedSpent: projected,
      remaining: remaining,
      completionRate: completionRate,
      status: status,
      categoryNames: categoryNames,
      accountIds: aggregate.accountIds,
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
  );
}
