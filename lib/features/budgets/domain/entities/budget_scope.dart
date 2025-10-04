enum BudgetScope { all, byCategory, byAccount }

extension BudgetScopeX on BudgetScope {
  String get storageValue => name;

  static BudgetScope fromStorage(String? value) {
    if (value == null || value.isEmpty) {
      return BudgetScope.all;
    }
    return BudgetScope.values.firstWhere(
      (BudgetScope scope) => scope.storageValue == value,
      orElse: () => BudgetScope.all,
    );
  }
}
