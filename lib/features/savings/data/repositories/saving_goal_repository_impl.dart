import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/repositories/saving_goal_repository.dart';

class SavingGoalRepositoryImpl implements SavingGoalRepository {
  SavingGoalRepositoryImpl({
    required db.AppDatabase database,
    required SavingGoalDao savingGoalDao,
    required OutboxDao outboxDao,
    required AnalyticsService analyticsService,
    required LoggerService loggerService,
  }) : _database = database,
       _savingGoalDao = savingGoalDao,
       _outboxDao = outboxDao,
       _analyticsService = analyticsService,
       _logger = loggerService;

  static const String _entityType = 'saving_goal';

  final db.AppDatabase _database;
  final SavingGoalDao _savingGoalDao;
  final OutboxDao _outboxDao;
  final AnalyticsService _analyticsService;
  final LoggerService _logger;

  @override
  Stream<List<SavingGoal>> watchGoals({required bool includeArchived}) {
    return _savingGoalDao.watchGoals(includeArchived: includeArchived);
  }

  @override
  Future<List<SavingGoal>> loadGoals({required bool includeArchived}) {
    return _savingGoalDao.getGoals(includeArchived: includeArchived);
  }

  @override
  Future<SavingGoal?> findById(String id) {
    return _savingGoalDao.findById(id);
  }

  @override
  Future<void> create(SavingGoal goal) async {
    final DateTime now = DateTime.now().toUtc();
    final SavingGoal toPersist = goal.copyWith(updatedAt: now);
    await _database.transaction(() async {
      await _savingGoalDao.upsert(toPersist);
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: toPersist.id,
        operation: OutboxOperation.upsert,
        payload: _mapGoalPayload(toPersist),
      );
    });
    await _analyticsService.logEvent('savings_goal_create', <String, dynamic>{
      'goalId': toPersist.id,
      'target': toPersist.targetAmount,
    });
    _logger.logInfo('Saving goal created: ${toPersist.id}');
  }

  @override
  Future<void> update(SavingGoal goal) async {
    final DateTime now = DateTime.now().toUtc();
    final SavingGoal toPersist = goal.copyWith(updatedAt: now);
    await _database.transaction(() async {
      await _savingGoalDao.upsert(toPersist);
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: toPersist.id,
        operation: OutboxOperation.upsert,
        payload: _mapGoalPayload(toPersist),
      );
    });
    await _analyticsService.logEvent('savings_goal_update', <String, dynamic>{
      'goalId': toPersist.id,
      'target': toPersist.targetAmount,
    });
    _logger.logInfo('Saving goal updated: ${toPersist.id}');
  }

  @override
  Future<void> archive(String goalId, DateTime archivedAt) async {
    await _database.transaction(() async {
      await _savingGoalDao.archive(goalId, archivedAt);
      final SavingGoal? updated = await _savingGoalDao.findById(goalId);
      if (updated == null) {
        return;
      }
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: goalId,
        operation: OutboxOperation.upsert,
        payload: _mapGoalPayload(updated),
      );
    });
    await _analyticsService.logEvent('savings_goal_archive', <String, dynamic>{
      'goalId': goalId,
    });
    _logger.logInfo('Saving goal archived: $goalId');
  }

  @override
  Future<void> addContribution({
    required SavingGoal updatedGoal,
    required int contributionAmount,
    String? sourceAccountId,
    String? contributionNote,
  }) async {
    final DateTime now = DateTime.now().toUtc();
    final SavingGoal toPersist = updatedGoal.copyWith(updatedAt: now);
    await _database.transaction(() async {
      await _savingGoalDao.upsert(toPersist);
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: toPersist.id,
        operation: OutboxOperation.upsert,
        payload: _mapGoalPayload(toPersist),
      );
    });
    await _analyticsService
        .logEvent('savings_goal_contribution', <String, dynamic>{
          'goalId': toPersist.id,
          'amount': contributionAmount,
          if (sourceAccountId != null) 'sourceAccountId': sourceAccountId,
        });
    if (contributionNote != null) {
      _logger.logInfo(
        'Contribution added to ${toPersist.id} for $contributionAmount with note $contributionNote',
      );
    } else {
      _logger.logInfo(
        'Contribution added to ${toPersist.id} for $contributionAmount',
      );
    }
  }

  Map<String, dynamic> _mapGoalPayload(SavingGoal goal) {
    final Map<String, dynamic> json = goal.toJson();
    json['createdAt'] = goal.createdAt.toIso8601String();
    json['updatedAt'] = goal.updatedAt.toIso8601String();
    json['archivedAt'] = goal.archivedAt?.toIso8601String();
    return json;
  }
}
