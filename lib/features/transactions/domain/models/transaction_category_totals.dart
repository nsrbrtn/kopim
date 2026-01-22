import 'package:kopim/core/money/money_utils.dart';

class TransactionCategoryTotals {
  const TransactionCategoryTotals({
    required this.categoryId,
    required this.income,
    required this.expense,
  });

  final String? categoryId;
  final MoneyAmount income;
  final MoneyAmount expense;
}
