import 'package:kopim/core/money/money_utils.dart';

class MonthlyCashflowTotals {
  const MonthlyCashflowTotals({
    required this.month,
    required this.income,
    required this.expense,
  });

  final DateTime month;
  final MoneyAmount income;
  final MoneyAmount expense;
}
