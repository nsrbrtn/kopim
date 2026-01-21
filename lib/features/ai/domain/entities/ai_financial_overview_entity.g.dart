// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_financial_overview_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AiDataFilter _$AiDataFilterFromJson(Map<String, dynamic> json) =>
    _AiDataFilter(
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      accountIds:
          (json['accountIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      categoryIds:
          (json['categoryIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      topCategoriesLimit: (json['topCategoriesLimit'] as num?)?.toInt() ?? 5,
    );

Map<String, dynamic> _$AiDataFilterToJson(_AiDataFilter instance) =>
    <String, dynamic>{
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'accountIds': instance.accountIds,
      'categoryIds': instance.categoryIds,
      'topCategoriesLimit': instance.topCategoriesLimit,
    };

_MonthlyExpenseInsight _$MonthlyExpenseInsightFromJson(
  Map<String, dynamic> json,
) => _MonthlyExpenseInsight(
  month: DateTime.parse(json['month'] as String),
  totalExpense: const MoneyAmountJsonConverter().fromJson(
    json['totalExpense'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$MonthlyExpenseInsightToJson(
  _MonthlyExpenseInsight instance,
) => <String, dynamic>{
  'month': instance.month.toIso8601String(),
  'totalExpense': const MoneyAmountJsonConverter().toJson(
    instance.totalExpense,
  ),
};

_MonthlyIncomeInsight _$MonthlyIncomeInsightFromJson(
  Map<String, dynamic> json,
) => _MonthlyIncomeInsight(
  month: DateTime.parse(json['month'] as String),
  totalIncome: const MoneyAmountJsonConverter().fromJson(
    json['totalIncome'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$MonthlyIncomeInsightToJson(
  _MonthlyIncomeInsight instance,
) => <String, dynamic>{
  'month': instance.month.toIso8601String(),
  'totalIncome': const MoneyAmountJsonConverter().toJson(instance.totalIncome),
};

_CategoryExpenseInsight _$CategoryExpenseInsightFromJson(
  Map<String, dynamic> json,
) => _CategoryExpenseInsight(
  categoryId: json['categoryId'] as String?,
  displayName: json['displayName'] as String,
  totalExpense: const MoneyAmountJsonConverter().fromJson(
    json['totalExpense'] as Map<String, dynamic>,
  ),
  color: json['color'] as String?,
);

Map<String, dynamic> _$CategoryExpenseInsightToJson(
  _CategoryExpenseInsight instance,
) => <String, dynamic>{
  'categoryId': instance.categoryId,
  'displayName': instance.displayName,
  'totalExpense': const MoneyAmountJsonConverter().toJson(
    instance.totalExpense,
  ),
  'color': instance.color,
};

_CategoryIncomeInsight _$CategoryIncomeInsightFromJson(
  Map<String, dynamic> json,
) => _CategoryIncomeInsight(
  categoryId: json['categoryId'] as String?,
  displayName: json['displayName'] as String,
  totalIncome: const MoneyAmountJsonConverter().fromJson(
    json['totalIncome'] as Map<String, dynamic>,
  ),
  color: json['color'] as String?,
);

Map<String, dynamic> _$CategoryIncomeInsightToJson(
  _CategoryIncomeInsight instance,
) => <String, dynamic>{
  'categoryId': instance.categoryId,
  'displayName': instance.displayName,
  'totalIncome': const MoneyAmountJsonConverter().toJson(instance.totalIncome),
  'color': instance.color,
};

_BudgetForecastInsight _$BudgetForecastInsightFromJson(
  Map<String, dynamic> json,
) => _BudgetForecastInsight(
  budgetId: json['budgetId'] as String,
  title: json['title'] as String,
  periodStart: DateTime.parse(json['periodStart'] as String),
  periodEnd: DateTime.parse(json['periodEnd'] as String),
  allocated: const MoneyAmountJsonConverter().fromJson(
    json['allocated'] as Map<String, dynamic>,
  ),
  spent: const MoneyAmountJsonConverter().fromJson(
    json['spent'] as Map<String, dynamic>,
  ),
  projectedSpent: const MoneyAmountJsonConverter().fromJson(
    json['projectedSpent'] as Map<String, dynamic>,
  ),
  remaining: const MoneyAmountJsonConverter().fromJson(
    json['remaining'] as Map<String, dynamic>,
  ),
  completionRate: (json['completionRate'] as num).toDouble(),
  status: $enumDecode(_$BudgetForecastStatusEnumMap, json['status']),
  categoryNames:
      (json['categoryNames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  accountIds:
      (json['accountIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$BudgetForecastInsightToJson(
  _BudgetForecastInsight instance,
) => <String, dynamic>{
  'budgetId': instance.budgetId,
  'title': instance.title,
  'periodStart': instance.periodStart.toIso8601String(),
  'periodEnd': instance.periodEnd.toIso8601String(),
  'allocated': const MoneyAmountJsonConverter().toJson(instance.allocated),
  'spent': const MoneyAmountJsonConverter().toJson(instance.spent),
  'projectedSpent': const MoneyAmountJsonConverter().toJson(
    instance.projectedSpent,
  ),
  'remaining': const MoneyAmountJsonConverter().toJson(instance.remaining),
  'completionRate': instance.completionRate,
  'status': _$BudgetForecastStatusEnumMap[instance.status]!,
  'categoryNames': instance.categoryNames,
  'accountIds': instance.accountIds,
};

const _$BudgetForecastStatusEnumMap = {
  BudgetForecastStatus.onTrack: 'onTrack',
  BudgetForecastStatus.warning: 'warning',
  BudgetForecastStatus.exceeded: 'exceeded',
};

_AiFinancialOverview _$AiFinancialOverviewFromJson(Map<String, dynamic> json) =>
    _AiFinancialOverview(
      monthlyExpenses: (json['monthlyExpenses'] as List<dynamic>)
          .map((e) => MonthlyExpenseInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
      monthlyIncomes: (json['monthlyIncomes'] as List<dynamic>)
          .map((e) => MonthlyIncomeInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
      topCategories: (json['topCategories'] as List<dynamic>)
          .map(
            (e) => CategoryExpenseInsight.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      topIncomeCategories: (json['topIncomeCategories'] as List<dynamic>)
          .map((e) => CategoryIncomeInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
      budgetForecasts: (json['budgetForecasts'] as List<dynamic>)
          .map((e) => BudgetForecastInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );

Map<String, dynamic> _$AiFinancialOverviewToJson(
  _AiFinancialOverview instance,
) => <String, dynamic>{
  'monthlyExpenses': instance.monthlyExpenses,
  'monthlyIncomes': instance.monthlyIncomes,
  'topCategories': instance.topCategories,
  'topIncomeCategories': instance.topIncomeCategories,
  'budgetForecasts': instance.budgetForecasts,
  'generatedAt': instance.generatedAt.toIso8601String(),
};
