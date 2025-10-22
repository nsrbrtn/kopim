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
    final List<CategoryExpenseAggregate> topCategories = await _analyticsDao
        .getTopCategories(filter);
    final List<BudgetInstanceAggregate> budgetInstances = await _analyticsDao
        .getBudgetForecasts(filter);
    return _composeOverview(
      monthlyExpenses: monthlyExpenses,
      topCategories: topCategories,
      budgetInstances: budgetInstances,
      filter: filter,
    );
  }

  @override
  Stream<AiFinancialOverview> watchOverview({required AiDataFilter filter}) {
    return Stream<AiFinancialOverview>.multi((
      StreamController<AiFinancialOverview> controller,
    ) {
      List<MonthlyExpenseAggregate>? monthly;
      List<CategoryExpenseAggregate>? categories;
      List<BudgetInstanceAggregate>? budgets;
      bool isClosed = false;

      void emitIfReady() {
        if (isClosed ||
            monthly == null ||
            categories == null ||
            budgets == null) {
          return;
        }
        controller.add(
          _composeOverview(
            monthlyExpenses: monthly!,
            topCategories: categories!,
            budgetInstances: budgets!,
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
      final StreamSubscription<List<CategoryExpenseAggregate>> categoriesSub =
          _analyticsDao.watchTopCategories(filter).listen((
            List<CategoryExpenseAggregate> data,
          ) {
            categories = data;
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
          categoriesSub.cancel(),
          budgetsSub.cancel(),
        ]);
      };
    });
  }

  AiFinancialOverview _composeOverview({
    required List<MonthlyExpenseAggregate> monthlyExpenses,
    required List<CategoryExpenseAggregate> topCategories,
    required List<BudgetInstanceAggregate> budgetInstances,
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

    final List<BudgetForecastInsight> budgetForecasts = budgetInstances
        .where(
          (BudgetInstanceAggregate aggregate) =>
              _matchesFilter(aggregate, filter),
        )
        .map(
          (BudgetInstanceAggregate aggregate) =>
              _mapBudgetForecast(aggregate, generatedAt),
        )
        .toList(growable: false);

    return AiFinancialOverview(
      monthlyExpenses: monthlyInsights,
      topCategories: categoryInsights,
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
