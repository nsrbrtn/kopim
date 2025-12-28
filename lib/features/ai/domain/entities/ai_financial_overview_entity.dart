import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_financial_overview_entity.freezed.dart';
part 'ai_financial_overview_entity.g.dart';

/// Фильтр для выборки финансовых данных, учитывающий пользовательские предпочтения.
@freezed
abstract class AiDataFilter with _$AiDataFilter {
  const AiDataFilter._();

  const factory AiDataFilter({
    DateTime? startDate,
    DateTime? endDate,
    @Default(<String>[]) List<String> accountIds,
    @Default(<String>[]) List<String> categoryIds,
    @Default(5) int topCategoriesLimit,
  }) = _AiDataFilter;

  factory AiDataFilter.fromJson(Map<String, dynamic> json) =>
      _$AiDataFilterFromJson(json);

  /// Проверяет, задан ли временной диапазон фильтра.
  bool get hasDateRange => startDate != null || endDate != null;

  /// Истина, если фильтр ограничивает выборку конкретными счетами.
  bool get hasAccountFilter => accountIds.isNotEmpty;

  /// Истина, если фильтр ограничивает выборку конкретными категориями.
  bool get hasCategoryFilter => categoryIds.isNotEmpty;
}

/// Сводка расходов за месяц.
@freezed
abstract class MonthlyExpenseInsight with _$MonthlyExpenseInsight {
  const MonthlyExpenseInsight._();

  const factory MonthlyExpenseInsight({
    required DateTime month,
    required double totalExpense,
  }) = _MonthlyExpenseInsight;

  factory MonthlyExpenseInsight.fromJson(Map<String, dynamic> json) =>
      _$MonthlyExpenseInsightFromJson(json);

  /// Возвращает месяц, округляя дату к первому числу.
  DateTime get normalizedMonth => DateTime(month.year, month.month);
}

/// Сводка доходов за месяц.
@freezed
abstract class MonthlyIncomeInsight with _$MonthlyIncomeInsight {
  const MonthlyIncomeInsight._();

  const factory MonthlyIncomeInsight({
    required DateTime month,
    required double totalIncome,
  }) = _MonthlyIncomeInsight;

  factory MonthlyIncomeInsight.fromJson(Map<String, dynamic> json) =>
      _$MonthlyIncomeInsightFromJson(json);

  /// Возвращает месяц, округляя дату к первому числу.
  DateTime get normalizedMonth => DateTime(month.year, month.month);
}

/// Данные по расходам в категории.
@freezed
abstract class CategoryExpenseInsight with _$CategoryExpenseInsight {
  const CategoryExpenseInsight._();

  const factory CategoryExpenseInsight({
    String? categoryId,
    required String displayName,
    required double totalExpense,
    String? color,
  }) = _CategoryExpenseInsight;

  factory CategoryExpenseInsight.fromJson(Map<String, dynamic> json) =>
      _$CategoryExpenseInsightFromJson(json);

  /// Истина, если расходы не привязаны к конкретной категории.
  bool get isUncategorized => categoryId == null || categoryId!.isEmpty;
}

/// Данные по доходам в категории.
@freezed
abstract class CategoryIncomeInsight with _$CategoryIncomeInsight {
  const CategoryIncomeInsight._();

  const factory CategoryIncomeInsight({
    String? categoryId,
    required String displayName,
    required double totalIncome,
    String? color,
  }) = _CategoryIncomeInsight;

  factory CategoryIncomeInsight.fromJson(Map<String, dynamic> json) =>
      _$CategoryIncomeInsightFromJson(json);

  /// Истина, если доходы не привязаны к конкретной категории.
  bool get isUncategorized => categoryId == null || categoryId!.isEmpty;
}

/// Статус прогноза бюджета относительно текущих трат.
enum BudgetForecastStatus { onTrack, warning, exceeded }

/// Прогноз исполнения бюджета.
@freezed
abstract class BudgetForecastInsight with _$BudgetForecastInsight {
  const BudgetForecastInsight._();

  const factory BudgetForecastInsight({
    required String budgetId,
    required String title,
    required DateTime periodStart,
    required DateTime periodEnd,
    required double allocated,
    required double spent,
    required double projectedSpent,
    required double remaining,
    required double completionRate,
    required BudgetForecastStatus status,
    @Default(<String>[]) List<String> categoryNames,
    @Default(<String>[]) List<String> accountIds,
  }) = _BudgetForecastInsight;

  factory BudgetForecastInsight.fromJson(Map<String, dynamic> json) =>
      _$BudgetForecastInsightFromJson(json);

  /// Насколько прогноз превышает выделенный бюджет.
  double get projectedVariance => projectedSpent - allocated;

  /// Истина, если прогноз сигнализирует о риске превышения.
  bool get isAtRisk =>
      status == BudgetForecastStatus.warning ||
      status == BudgetForecastStatus.exceeded;
}

/// Комплексный срез финансовых метрик, используемый для формирования промптов.
@freezed
abstract class AiFinancialOverview with _$AiFinancialOverview {
  const AiFinancialOverview._();

  const factory AiFinancialOverview({
    required List<MonthlyExpenseInsight> monthlyExpenses,
    required List<MonthlyIncomeInsight> monthlyIncomes,
    required List<CategoryExpenseInsight> topCategories,
    required List<CategoryIncomeInsight> topIncomeCategories,
    required List<BudgetForecastInsight> budgetForecasts,
    required DateTime generatedAt,
  }) = _AiFinancialOverview;

  factory AiFinancialOverview.fromJson(Map<String, dynamic> json) =>
      _$AiFinancialOverviewFromJson(json);

  /// Проверяет, содержит ли сводка хоть один прогноз бюджета.
  bool get hasBudgetSignals => budgetForecasts.isNotEmpty;

  /// Указывает, доступны ли данные по топовым категориям расходов.
  bool get hasCategoryBreakdown => topCategories.isNotEmpty;

  /// Указывает, доступны ли данные по топовым категориям доходов.
  bool get hasIncomeBreakdown => topIncomeCategories.isNotEmpty;
}
