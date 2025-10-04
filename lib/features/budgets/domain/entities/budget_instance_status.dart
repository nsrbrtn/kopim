enum BudgetInstanceStatus { pending, active, closed }

extension BudgetInstanceStatusX on BudgetInstanceStatus {
  String get storageValue => name;

  static BudgetInstanceStatus fromStorage(String? value) {
    if (value == null || value.isEmpty) {
      return BudgetInstanceStatus.pending;
    }
    return BudgetInstanceStatus.values.firstWhere(
      (BudgetInstanceStatus status) => status.storageValue == value,
      orElse: () => BudgetInstanceStatus.pending,
    );
  }
}
