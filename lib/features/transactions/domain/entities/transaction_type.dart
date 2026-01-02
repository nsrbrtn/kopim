enum TransactionType { expense, income, transfer }

extension TransactionTypeX on TransactionType {
  String get storageValue => name;

  bool get isIncome => this == TransactionType.income;

  bool get isExpense => this == TransactionType.expense;

  bool get isTransfer => this == TransactionType.transfer;
}

TransactionType parseTransactionType(String raw) {
  if (raw == TransactionType.income.storageValue) {
    return TransactionType.income;
  }
  if (raw == TransactionType.transfer.storageValue) {
    return TransactionType.transfer;
  }
  return TransactionType.expense;
}
