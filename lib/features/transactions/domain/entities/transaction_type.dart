enum TransactionType { expense, income }

extension TransactionTypeX on TransactionType {
  String get storageValue => name;

  bool get isIncome => this == TransactionType.income;

  bool get isExpense => this == TransactionType.expense;
}
