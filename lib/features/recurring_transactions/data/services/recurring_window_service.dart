import 'package:kopim/features/recurring_transactions/domain/entities/recurring_occurrence.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/domain/repositories/recurring_transactions_repository.dart';
import 'package:kopim/features/recurring_transactions/domain/services/recurring_rule_engine.dart';

class RecurringWindowService {
  RecurringWindowService({
    required RecurringTransactionsRepository repository,
    required RecurringRuleEngine engine,
  }) : _repository = repository,
       _engine = engine;

  final RecurringTransactionsRepository _repository;
  final RecurringRuleEngine _engine;

  Future<void> rebuildWindow({int monthsAhead = 6}) async {
    final List<RecurringRule> rules = await _repository.getAllRules(
      activeOnly: true,
    );
    if (rules.isEmpty) {
      await _repository.saveOccurrences(
        const <RecurringOccurrence>[],
        replaceExisting: true,
      );
      return;
    }
    final DateTime now = DateTime.now().toUtc();
    final DateTime windowStart = DateTime.utc(now.year, now.month, now.day);
    final DateTime windowEnd = DateTime.utc(
      now.year,
      now.month + monthsAhead,
      now.day,
    );

    final List<RecurringOccurrence> aggregated = <RecurringOccurrence>[];
    for (final RecurringRule rule in rules) {
      final List<RecurringOccurrence> occurrences = await _engine
          .generateOccurrences(
            rule: rule,
            windowStart: windowStart,
            windowEnd: windowEnd,
          );
      aggregated.addAll(occurrences);
    }
    await _repository.saveOccurrences(aggregated, replaceExisting: true);
  }
}
