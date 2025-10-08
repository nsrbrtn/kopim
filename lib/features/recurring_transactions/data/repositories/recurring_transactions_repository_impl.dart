import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/recurring_transactions/data/sources/local/job_queue_dao.dart';
import 'package:kopim/features/recurring_transactions/data/sources/local/recurring_occurrence_dao.dart';
import 'package:kopim/features/recurring_transactions/data/sources/local/recurring_rule_execution_dao.dart';
import 'package:kopim/features/recurring_transactions/data/sources/local/recurring_rule_dao.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_job.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_occurrence.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/domain/repositories/recurring_transactions_repository.dart';
import 'package:kopim/core/data/database.dart' as db;

class RecurringTransactionsRepositoryImpl
    implements RecurringTransactionsRepository {
  RecurringTransactionsRepositoryImpl({
    required RecurringRuleDao ruleDao,
    required RecurringOccurrenceDao occurrenceDao,
    required RecurringRuleExecutionDao executionDao,
    required JobQueueDao jobQueueDao,
    required db.AppDatabase database,
    required OutboxDao outboxDao,
  }) : _ruleDao = ruleDao,
       _occurrenceDao = occurrenceDao,
       _executionDao = executionDao,
       _jobQueueDao = jobQueueDao,
       _database = database,
       _outboxDao = outboxDao;

  final RecurringRuleDao _ruleDao;
  final RecurringOccurrenceDao _occurrenceDao;
  final RecurringRuleExecutionDao _executionDao;
  final JobQueueDao _jobQueueDao;
  final db.AppDatabase _database;
  final OutboxDao _outboxDao;
  static const String _ruleEntityType = 'recurring_rule';

  @override
  Stream<List<RecurringRule>> watchRules() {
    return _ruleDao.watchAll().map((List<db.RecurringRuleRow> rows) {
      return rows.map(_mapRuleRowToEntity).toList();
    });
  }

  @override
  Stream<List<RecurringOccurrence>> watchUpcomingOccurrences({
    required DateTime from,
    required DateTime to,
  }) {
    return _occurrenceDao
        .watchWindow(from: from, to: to)
        .map(
          (List<db.RecurringOccurrenceRow> rows) =>
              rows.map(_mapOccurrenceRowToEntity).toList(),
        );
  }

  @override
  Stream<List<RecurringOccurrence>> watchRuleOccurrences(String ruleId) {
    return _occurrenceDao
        .watchRule(ruleId)
        .map(
          (List<db.RecurringOccurrenceRow> rows) =>
              rows.map(_mapOccurrenceRowToEntity).toList(),
        );
  }

  @override
  Future<RecurringRule?> getRuleById(String id) async {
    final db.RecurringRuleRow? row = await _ruleDao.findById(id);
    return row == null ? null : _mapRuleRowToEntity(row);
  }

  @override
  Future<List<RecurringRule>> getAllRules({bool activeOnly = false}) async {
    final List<db.RecurringRuleRow> rows = await _ruleDao.getAll();
    final Iterable<RecurringRule> mapped = rows.map(_mapRuleRowToEntity);
    if (!activeOnly) {
      return mapped.toList();
    }
    return mapped.where((RecurringRule rule) => rule.isActive).toList();
  }

  @override
  Future<void> upsertRule(
    RecurringRule rule, {
    bool regenerateWindow = true,
  }) async {
    final DateTime now = DateTime.now().toUtc();
    final RecurringRule normalized = rule.copyWith(
      startAt: rule.startAt.toUtc(),
      endAt: rule.endAt?.toUtc(),
      nextDueLocalDate: rule.nextDueLocalDate?.toUtc(),
      lastRunAt: rule.lastRunAt?.toUtc(),
      createdAt: rule.createdAt.toUtc(),
      updatedAt: now,
    );
    await _database.transaction(() async {
      await _ruleDao.upsert(normalized);
      await _outboxDao.enqueue(
        entityType: _ruleEntityType,
        entityId: normalized.id,
        operation: OutboxOperation.upsert,
        payload: _mapRulePayload(normalized),
      );
    });
  }

  @override
  Future<void> deleteRule(String id) async {
    await _database.transaction(() async {
      final db.RecurringRuleRow? existing = await _ruleDao.findById(id);
      await _occurrenceDao.deleteForRule(id);
      await _ruleDao.deleteById(id);
      if (existing != null) {
        await _outboxDao.enqueue(
          entityType: _ruleEntityType,
          entityId: id,
          operation: OutboxOperation.delete,
          payload: _mapRulePayload(_mapRuleRowToEntity(existing)),
        );
      }
    });
  }

  @override
  Future<void> toggleRule({required String id, required bool isActive}) async {
    final DateTime now = DateTime.now().toUtc();
    await _database.transaction(() async {
      await _ruleDao.toggle(id: id, isActive: isActive, updatedAt: now);
      final db.RecurringRuleRow? updated = await _ruleDao.findById(id);
      if (updated != null) {
        await _outboxDao.enqueue(
          entityType: _ruleEntityType,
          entityId: id,
          operation: OutboxOperation.upsert,
          payload: _mapRulePayload(_mapRuleRowToEntity(updated)),
        );
      }
    });
  }

  @override
  Future<void> saveOccurrences(
    Iterable<RecurringOccurrence> occurrences, {
    bool replaceExisting = false,
  }) {
    if (replaceExisting) {
      if (occurrences.isEmpty) {
        return _occurrenceDao.clearAll();
      }
      return _occurrenceDao.replaceOccurrences(occurrences);
    }
    return _occurrenceDao.upsertAll(occurrences);
  }

  @override
  Future<void> updateOccurrenceStatus(
    String occurrenceId,
    RecurringOccurrenceStatus status, {
    String? postedTxId,
  }) {
    return _occurrenceDao.updateStatus(
      occurrenceId,
      status,
      postedTxId: postedTxId,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<List<RecurringOccurrence>> getDueOccurrences(DateTime forDate) async {
    final List<db.RecurringOccurrenceRow> rows = await _occurrenceDao.getDueOn(
      forDate,
    );
    return rows.map(_mapOccurrenceRowToEntity).toList();
  }

  @override
  Future<bool> applyRuleOccurrence({
    required RecurringRule rule,
    required String occurrenceId,
    required DateTime occurrenceLocalDate,
    required Future<String?> Function() postTransaction,
  }) {
    return _database.transaction(() async {
      final db.RecurringRuleExecutionRow? existing = await _executionDao
          .findById(occurrenceId);
      if (existing != null) {
        return false;
      }
      final String? transactionId = await postTransaction();
      await _executionDao.insertExecution(
        occurrenceId: occurrenceId,
        ruleId: rule.id,
        localDate: occurrenceLocalDate,
        appliedAt: DateTime.now().toUtc(),
        transactionId: transactionId,
      );
      return true;
    });
  }

  @override
  Future<void> enqueueJob({
    required String type,
    required String payload,
    required DateTime runAt,
  }) {
    return _jobQueueDao.enqueue(type: type, payload: payload, runAt: runAt);
  }

  @override
  Future<void> markJobAttempt(int jobId, {String? error}) {
    return _jobQueueDao.markAttempt(jobId, error: error);
  }

  @override
  Stream<List<RecurringJob>> watchPendingJobs() {
    return _jobQueueDao.watchPending().map(
      (List<db.JobQueueRow> rows) => rows.map(_mapJobRowToEntity).toList(),
    );
  }

  RecurringRule _mapRuleRowToEntity(db.RecurringRuleRow row) {
    return RecurringRule(
      id: row.id,
      title: row.title,
      accountId: row.accountId,
      categoryId: row.categoryId,
      amount: row.amount,
      currency: row.currency,
      startAt: row.startAt.toUtc(),
      timezone: row.timezone,
      rrule: row.rrule,
      endAt: row.endAt?.toUtc(),
      notes: row.notes,
      dayOfMonth: row.dayOfMonth,
      applyAtLocalHour: row.applyAtLocalHour,
      applyAtLocalMinute: row.applyAtLocalMinute,
      lastRunAt: row.lastRunAt?.toLocal(),
      nextDueLocalDate: row.nextDueLocalDate?.toLocal(),
      isActive: row.isActive,
      autoPost: row.autoPost,
      reminderMinutesBefore: row.reminderMinutesBefore,
      shortMonthPolicy: RecurringRuleShortMonthPolicy.fromValue(
        row.shortMonthPolicy,
      ),
      createdAt: row.createdAt.toUtc(),
      updatedAt: row.updatedAt.toUtc(),
    );
  }

  RecurringOccurrence _mapOccurrenceRowToEntity(db.RecurringOccurrenceRow row) {
    return RecurringOccurrence(
      id: row.id,
      ruleId: row.ruleId,
      dueAt: row.dueAt.toUtc(),
      status: RecurringOccurrenceStatus.fromValue(row.status),
      createdAt: row.createdAt.toUtc(),
      updatedAt: row.updatedAt.toUtc(),
      postedTxId: row.postedTxId,
    );
  }

  RecurringJob _mapJobRowToEntity(db.JobQueueRow row) {
    return RecurringJob(
      id: row.id,
      type: row.type,
      payload: row.payload,
      runAt: row.runAt.toUtc(),
      attempts: row.attempts,
      lastError: row.lastError,
      createdAt: row.createdAt.toUtc(),
    );
  }

  Map<String, dynamic> _mapRulePayload(RecurringRule rule) {
    final Map<String, dynamic> json = rule.toJson();
    json['startAt'] = rule.startAt.toIso8601String();
    json['endAt'] = rule.endAt?.toIso8601String();
    json['nextDueLocalDate'] = rule.nextDueLocalDate?.toIso8601String();
    json['lastRunAt'] = rule.lastRunAt?.toIso8601String();
    json['createdAt'] = rule.createdAt.toIso8601String();
    json['updatedAt'] = rule.updatedAt.toIso8601String();
    return json;
  }
}
