import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:kopim/features/categories/domain/entities/category.dart';

part 'budget_category_spend.freezed.dart';

@freezed
abstract class BudgetCategorySpend with _$BudgetCategorySpend {
  const factory BudgetCategorySpend({
    required Category category,
    required double spent,
    double? limit,
  }) = _BudgetCategorySpend;
}
