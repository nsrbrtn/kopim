import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/domain/repositories/recurring_transactions_repository.dart';

class WatchRecurringRulesUseCase {
  const WatchRecurringRulesUseCase(this._repository);

  final RecurringTransactionsRepository _repository;

  Stream<List<RecurringRule>> call() {
    return _repository.watchRules();
  }
}
