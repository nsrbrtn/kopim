import 'package:kopim/features/recurring_transactions/domain/repositories/recurring_transactions_repository.dart';

class DeleteRecurringRuleUseCase {
  const DeleteRecurringRuleUseCase(this._repository);

  final RecurringTransactionsRepository _repository;

  Future<void> call(String id) {
    return _repository.deleteRule(id);
  }
}
