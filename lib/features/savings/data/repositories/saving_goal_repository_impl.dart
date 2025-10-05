import 'package:drift/drift.dart' show Value;
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/savings/data/sources/local/goal_contribution_dao.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/repositories/saving_goal_repository.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:uuid/uuid.dart';

class SavingGoalRepositoryImpl implements SavingGoalRepository {
  SavingGoalRepositoryImpl({
    required db.AppDatabase database,
    required SavingGoalDao savingGoalDao,
    required CategoryDao categoryDao,
    required AccountDao accountDao,
    required TransactionDao transactionDao,
    required GoalContributionDao goalContributionDao,
    required OutboxDao outboxDao,
    required AnalyticsService analyticsService,
    required LoggerService loggerService,
    Uuid? uuidGenerator,
    DateTime Function()? clock,
  }) : _database = database,
       _savingGoalDao = savingGoalDao,
       _categoryDao = categoryDao,
       _accountDao = accountDao,
       _transactionDao = transactionDao,
       _contributionDao = goalContributionDao,
       _outboxDao = outboxDao,
       _analyticsService = analyticsService,
       _logger = loggerService,
       _uuid = uuidGenerator ?? const Uuid(),
       _clock = clock ?? DateTime.now;

  static const String _goalEntityType = 'saving_goal';
  static const String _categoryEntityType = 'category';
  static const String _transactionEntityType = 'transaction';
  static const String _accountEntityType = 'account';
  static const PhosphorIconDescriptor _defaultSavingsIcon =
      PhosphorIconDescriptor(name: 'piggy-bank', style: PhosphorIconStyle.bold);
  static const List<String> _categoryPalette = <String>[
    '#D6D58E',
    '#DBF227',
    '#9FC131',
    '#005C53',
    '#042940',
    '#BDA523',
    '#E3C75F',
    '#CC8D1A',
    '#164C45',
    '#16232E',
    '#E3371E',
    '#FF7A48',
    '#0593A2',
    '#103778',
    '#151F30',
    '#66796B',
    '#BA8E7A',
    '#EFDFCC',
    '#D7A184',
    '#D4C2AD',
    '#293241',
    '#EE6B4D',
    '#DFFBFC',
    '#9BC0D9',
    '#3D5B81',
    '#F26363',
    '#F29F80',
    '#F2D0A7',
    '#171559',
    '#D94169',
    '#F5F549',
    '#EFB7FF',
    '#00F4CC',
    '#4F81F7',
    '#3A356E',
  ];

  final db.AppDatabase _database;
  final SavingGoalDao _savingGoalDao;
  final CategoryDao _categoryDao;
  final AccountDao _accountDao;
  final TransactionDao _transactionDao;
  final GoalContributionDao _contributionDao;
  final OutboxDao _outboxDao;
  final AnalyticsService _analyticsService;
  final LoggerService _logger;
  final Uuid _uuid;
  final DateTime Function() _clock;

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
  Future<SavingGoal?> findByName({
    required String userId,
    required String name,
  }) {
    return _savingGoalDao.findByName(userId: userId, name: name);
  }

  @override
  Future<void> create(SavingGoal goal) async {
    final DateTime now = _clock().toUtc();
    final SavingGoal toPersist = goal.copyWith(updatedAt: now);
    await _database.transaction(() async {
      await _ensureSystemCategory(name: toPersist.name, timestamp: now);
      await _savingGoalDao.upsert(toPersist);
      await _outboxDao.enqueue(
        entityType: _goalEntityType,
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
    final DateTime now = _clock().toUtc();
    final SavingGoal toPersist = goal.copyWith(updatedAt: now);
    await _database.transaction(() async {
      await _savingGoalDao.upsert(toPersist);
      await _outboxDao.enqueue(
        entityType: _goalEntityType,
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
        entityType: _goalEntityType,
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
  Future<SavingGoal> addContribution({
    required SavingGoal goal,
    required int appliedDelta,
    required int newCurrentAmount,
    required DateTime contributedAt,
    String? sourceAccountId,
    String? contributionNote,
  }) async {
    final DateTime timestamp = contributedAt.toUtc();
    final SavingGoal persisted = await _database.transaction(() async {
      final SavingGoal updatedGoal = goal.copyWith(
        currentAmount: newCurrentAmount,
        updatedAt: timestamp,
      );
      final String categoryId = await _ensureSystemCategory(
        name: goal.name,
        timestamp: timestamp,
      );
      final String? accountId =
          (sourceAccountId != null && sourceAccountId.isNotEmpty)
          ? sourceAccountId
          : null;
      if (accountId != null) {
        final db.AccountRow? accountRow = await _accountDao.findById(accountId);
        if (accountRow == null) {
          throw StateError('Account not found for contribution');
        }
        final double amountDouble = appliedDelta / 100;
        final TransactionEntity transaction = TransactionEntity(
          id: _uuid.v4(),
          accountId: accountId,
          categoryId: categoryId,
          savingGoalId: goal.id,
          amount: -amountDouble,
          date: timestamp,
          note: _composeContributionNote(goal.name, contributionNote),
          type: 'expense',
          createdAt: timestamp,
          updatedAt: timestamp,
        );
        await _transactionDao.upsert(transaction);
        await _outboxDao.enqueue(
          entityType: _transactionEntityType,
          entityId: transaction.id,
          operation: OutboxOperation.upsert,
          payload: _mapTransactionPayload(transaction),
        );
        final AccountEntity updatedAccount = AccountEntity(
          id: accountRow.id,
          name: accountRow.name,
          balance: accountRow.balance - amountDouble,
          currency: accountRow.currency,
          type: accountRow.type,
          createdAt: accountRow.createdAt,
          updatedAt: timestamp,
          isDeleted: accountRow.isDeleted,
        );
        await _accountDao.upsert(updatedAccount);
        await _outboxDao.enqueue(
          entityType: _accountEntityType,
          entityId: updatedAccount.id,
          operation: OutboxOperation.upsert,
          payload: _mapAccountPayload(updatedAccount),
        );
        await _contributionDao.insert(
          id: _uuid.v4(),
          goalId: goal.id,
          transactionId: transaction.id,
          amount: appliedDelta,
          createdAt: timestamp,
        );
      }
      await _savingGoalDao.upsert(updatedGoal);
      await _outboxDao.enqueue(
        entityType: _goalEntityType,
        entityId: updatedGoal.id,
        operation: OutboxOperation.upsert,
        payload: _mapGoalPayload(updatedGoal),
      );
      return updatedGoal;
    });

    await _analyticsService
        .logEvent('savings_goal_contribution', <String, dynamic>{
          'goalId': persisted.id,
          'amount': appliedDelta,
          if (sourceAccountId != null && sourceAccountId.isNotEmpty)
            'sourceAccountId': sourceAccountId,
        });
    final String logNote =
        contributionNote != null && contributionNote.isNotEmpty
        ? ' с заметкой $contributionNote'
        : '';
    _logger.logInfo(
      'Добавлен взнос в ${persisted.id} на сумму $appliedDelta$logNote',
    );
    return persisted;
  }

  Future<String> _ensureSystemCategory({
    required String name,
    required DateTime timestamp,
  }) async {
    final db.CategoryRow? existing = await _categoryDao.findByName(name);
    if (existing != null) {
      if (existing.isDeleted || !existing.isSystem) {
        await (_database.update(_database.categories)
              ..where((db.$CategoriesTable tbl) => tbl.id.equals(existing.id)))
            .write(
              db.CategoriesCompanion(
                isDeleted: const Value<bool>(false),
                isSystem: const Value<bool>(true),
                updatedAt: Value<DateTime>(timestamp),
              ),
            );
      }
      return existing.id;
    }
    final Category category = Category(
      id: _uuid.v4(),
      name: name,
      type: 'expense',
      icon: _defaultSavingsIcon,
      color: _pickColorForName(name),
      parentId: null,
      createdAt: timestamp,
      updatedAt: timestamp,
      isDeleted: false,
      isSystem: true,
    );
    await _categoryDao.upsert(category);
    await _outboxDao.enqueue(
      entityType: _categoryEntityType,
      entityId: category.id,
      operation: OutboxOperation.upsert,
      payload: _mapCategoryPayload(category),
    );
    return category.id;
  }

  String _pickColorForName(String name) {
    if (name.isEmpty) {
      return _categoryPalette.first;
    }
    final int hash = name.toLowerCase().runes.fold<int>(
      0,
      (int value, int rune) => (value * 31 + rune) & 0x7fffffff,
    );
    return _categoryPalette[hash % _categoryPalette.length];
  }

  String _composeContributionNote(String goalName, String? note) {
    final String base = 'Накопление: $goalName';
    if (note == null || note.isEmpty) {
      return base;
    }
    return '$base — $note';
  }

  Map<String, dynamic> _mapGoalPayload(SavingGoal goal) {
    final Map<String, dynamic> json = goal.toJson();
    json['createdAt'] = goal.createdAt.toIso8601String();
    json['updatedAt'] = goal.updatedAt.toIso8601String();
    json['archivedAt'] = goal.archivedAt?.toIso8601String();
    return json;
  }

  Map<String, dynamic> _mapCategoryPayload(Category category) {
    final Map<String, dynamic> json = category.toJson();
    json['iconName'] = category.icon?.name;
    json['iconStyle'] = category.icon?.style.label;
    json['createdAt'] = category.createdAt.toIso8601String();
    json['updatedAt'] = category.updatedAt.toIso8601String();
    return json;
  }

  Map<String, dynamic> _mapTransactionPayload(TransactionEntity transaction) {
    final Map<String, dynamic> json = transaction.toJson();
    json['createdAt'] = transaction.createdAt.toIso8601String();
    json['updatedAt'] = transaction.updatedAt.toIso8601String();
    json['date'] = transaction.date.toIso8601String();
    return json;
  }

  Map<String, dynamic> _mapAccountPayload(AccountEntity account) {
    final Map<String, dynamic> json = account.toJson();
    json['updatedAt'] = account.updatedAt.toIso8601String();
    json['createdAt'] = account.createdAt.toIso8601String();
    return json;
  }
}
