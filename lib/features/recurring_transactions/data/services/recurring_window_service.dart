import 'package:kopim/features/recurring_transactions/data/services/recurring_notification_service.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_occurrence.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/domain/repositories/recurring_transactions_repository.dart';
import 'package:kopim/features/recurring_transactions/domain/services/recurring_rule_engine.dart';

class RecurringWindowService {
  RecurringWindowService({
    required RecurringTransactionsRepository repository,
    required RecurringRuleEngine engine,
    required RecurringNotificationService notificationService,
  }) : _repository = repository,
       _engine = engine,
       _notificationService = notificationService;

  final RecurringTransactionsRepository _repository;
  final RecurringRuleEngine _engine;
  final RecurringNotificationService _notificationService;

  Future<void> rebuildWindow({int monthsAhead = 6}) async {
    final List<RecurringRule> rules = await _repository.getAllRules(
      activeOnly: true,
    );
    if (rules.isEmpty) {
      await _repository.saveOccurrences(
        const <RecurringOccurrence>[],
        replaceExisting: true,
      );
      await _notificationService.refreshNotifications(
        occurrences: const <RecurringOccurrence>[],
        rules: const <String, RecurringRule>{},
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
    await _notificationService.refreshNotifications(
      occurrences: aggregated,
      rules: <String, RecurringRule>{
        for (final RecurringRule rule in rules) rule.id: rule,
      },
    );
  }
}
