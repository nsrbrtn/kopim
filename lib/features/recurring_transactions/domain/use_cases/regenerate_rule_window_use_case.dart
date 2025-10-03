import 'package:kopim/features/recurring_transactions/domain/entities/recurring_occurrence.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/domain/repositories/recurring_transactions_repository.dart';
import 'package:kopim/features/recurring_transactions/domain/services/recurring_rule_engine.dart';

class RegenerateRuleWindowUseCase {
  const RegenerateRuleWindowUseCase(this._repository, this._engine);

  final RecurringTransactionsRepository _repository;
  final RecurringRuleEngine _engine;

  Future<void> call({
    required String ruleId,
    required DateTime windowStart,
    required DateTime windowEnd,
  }) async {
    final RecurringRule? rule = await _repository.getRuleById(ruleId);
    if (rule == null) {
      return;
    }
    final List<RecurringOccurrence> occurrences = await _engine
        .generateOccurrences(
          rule: rule,
          windowStart: windowStart,
          windowEnd: windowEnd,
        );
    await _repository.saveOccurrences(occurrences, replaceExisting: true);
  }
}
