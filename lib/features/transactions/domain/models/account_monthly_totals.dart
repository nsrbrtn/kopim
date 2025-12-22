class AccountMonthlyTotals {
  const AccountMonthlyTotals({
    required this.accountId,
    required this.income,
    required this.expense,
  });

  final String accountId;
  final double income;
  final double expense;
}
