enum BudgetPeriod { monthly, weekly, custom }

extension BudgetPeriodX on BudgetPeriod {
  String get storageValue => name;

  bool get isRecurring =>
      this == BudgetPeriod.monthly || this == BudgetPeriod.weekly;

  static BudgetPeriod fromStorage(String? value) {
    if (value == null || value.isEmpty) {
      return BudgetPeriod.monthly;
    }
    return BudgetPeriod.values.firstWhere(
      (BudgetPeriod period) => period.storageValue == value,
      orElse: () => BudgetPeriod.monthly,
    );
  }
}
