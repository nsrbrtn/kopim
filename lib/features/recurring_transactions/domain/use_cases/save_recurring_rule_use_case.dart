import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/domain/repositories/recurring_transactions_repository.dart';

class SaveRecurringRuleUseCase {
  const SaveRecurringRuleUseCase(this._repository);

  final RecurringTransactionsRepository _repository;

  Future<void> call(RecurringRule rule, {bool regenerateWindow = true}) {
    return _repository.upsertRule(rule, regenerateWindow: regenerateWindow);
  }
}
