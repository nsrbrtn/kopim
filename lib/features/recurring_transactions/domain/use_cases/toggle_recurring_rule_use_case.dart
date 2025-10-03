import 'package:kopim/features/recurring_transactions/domain/repositories/recurring_transactions_repository.dart';

class ToggleRecurringRuleUseCase {
  const ToggleRecurringRuleUseCase(this._repository);

  final RecurringTransactionsRepository _repository;

  Future<void> call({required String id, required bool isActive}) {
    return _repository.toggleRule(id: id, isActive: isActive);
  }
}
