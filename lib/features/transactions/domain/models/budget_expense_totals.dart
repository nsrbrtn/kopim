import 'package:kopim/core/money/money_utils.dart';

class BudgetExpenseTotals {
  const BudgetExpenseTotals({
    required this.accountId,
    required this.categoryId,
    required this.expense,
  });

  final String accountId;
  final String? categoryId;
  final MoneyAmount expense;
}
