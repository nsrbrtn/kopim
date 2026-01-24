import 'package:kopim/core/money/money_utils.dart';

class TransactionCategoryTotals {
  const TransactionCategoryTotals({
    required this.categoryId,
    this.rootCategoryId,
    required this.income,
    required this.expense,
  });

  final String? categoryId;
  final String? rootCategoryId;
  final MoneyAmount income;
  final MoneyAmount expense;
}
