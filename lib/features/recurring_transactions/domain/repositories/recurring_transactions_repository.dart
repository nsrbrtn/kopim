import 'package:kopim/features/recurring_transactions/domain/entities/recurring_job.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_occurrence.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';

abstract class RecurringTransactionsRepository {
  Stream<List<RecurringRule>> watchRules();
  Stream<List<RecurringOccurrence>> watchUpcomingOccurrences({
    required DateTime from,
    required DateTime to,
  });
  Stream<List<RecurringOccurrence>> watchRuleOccurrences(String ruleId);

  Future<RecurringRule?> getRuleById(String id);
  Future<List<RecurringRule>> getAllRules({bool activeOnly = false});
  Future<void> upsertRule(RecurringRule rule, {bool regenerateWindow = true});
  Future<void> deleteRule(String id);
  Future<void> toggleRule({required String id, required bool isActive});

  Future<void> saveOccurrences(
    Iterable<RecurringOccurrence> occurrences, {
    bool replaceExisting = false,
  });
  Future<void> updateOccurrenceStatus(
    String occurrenceId,
    RecurringOccurrenceStatus status, {
    String? postedTxId,
  });
  Future<List<RecurringOccurrence>> getDueOccurrences(DateTime forDate);

  Future<bool> applyRuleOccurrence({
    required RecurringRule rule,
    required String occurrenceId,
    required DateTime occurrenceLocalDate,
    required Future<String?> Function() postTransaction,
  });

  Future<void> enqueueJob({
    required String type,
    required String payload,
    required DateTime runAt,
  });
  Future<void> markJobAttempt(int jobId, {String? error});
  Stream<List<RecurringJob>> watchPendingJobs();
}
