import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/accounts/data/mappers/account_sync_payload_mapper.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/utils/account_type_utils.dart';

class AccountTypeBackfillResult {
  const AccountTypeBackfillResult({
    required this.scannedCount,
    required this.updatedCount,
    required this.skippedUnknownCount,
    required this.skippedUpToDateCount,
  });

  final int scannedCount;
  final int updatedCount;
  final int skippedUnknownCount;
  final int skippedUpToDateCount;
}

class AccountTypeBackfillService {
  AccountTypeBackfillService({
    required db.AppDatabase database,
    required AccountDao accountDao,
    required OutboxDao outboxDao,
    LoggerService? loggerService,
    AnalyticsService? analyticsService,
  }) : _database = database,
       _accountDao = accountDao,
       _outboxDao = outboxDao,
       _logger = loggerService,
       _analytics = analyticsService;

  final db.AppDatabase _database;
  final AccountDao _accountDao;
  final OutboxDao _outboxDao;
  final LoggerService? _logger;
  final AnalyticsService? _analytics;

  static const String _entityType = 'account';

  Future<AccountTypeBackfillResult> run({
    int targetTypeVersion = kCurrentAccountTypeVersion,
    DateTime? now,
  }) async {
    final List<AccountEntity> accounts = await _accountDao.getAllAccounts();
    final DateTime timestamp = now ?? DateTime.now().toUtc();
    int updatedCount = 0;
    int skippedUnknownCount = 0;
    int skippedUpToDateCount = 0;
    final Set<String> unknownLegacyTypes = <String>{};

    for (final AccountEntity account in accounts) {
      final String? canonicalType = resolveBackfillAccountType(account.type);
      if (canonicalType == null) {
        skippedUnknownCount += 1;
        final String rawType = account.type.trim().toLowerCase();
        if (rawType.isNotEmpty) {
          unknownLegacyTypes.add(rawType);
        }
        continue;
      }
      if (!shouldBackfillAccountType(
        account.type,
        typeVersion: account.typeVersion,
        targetTypeVersion: targetTypeVersion,
      )) {
        skippedUpToDateCount += 1;
        continue;
      }

      final AccountEntity migrated = account.copyWith(
        type: canonicalType,
        typeVersion: targetTypeVersion,
        updatedAt: timestamp,
      );
      await _database.transaction(() async {
        await _accountDao.upsert(migrated);
        await _outboxDao.enqueue(
          entityType: _entityType,
          entityId: migrated.id,
          operation: migrated.isDeleted
              ? OutboxOperation.delete
              : OutboxOperation.upsert,
          payload: mapAccountSyncPayload(migrated),
        );
      });
      updatedCount += 1;
    }

    final AccountTypeBackfillResult result = AccountTypeBackfillResult(
      scannedCount: accounts.length,
      updatedCount: updatedCount,
      skippedUnknownCount: skippedUnknownCount,
      skippedUpToDateCount: skippedUpToDateCount,
    );
    if (unknownLegacyTypes.isNotEmpty) {
      _logger?.logInfo(
        'AccountTypeBackfillService: skipped unknown legacy account types: '
        '${unknownLegacyTypes.join(', ')}',
      );
    }
    _logger?.logInfo(
      'AccountTypeBackfillService: scanned=${result.scannedCount}, '
      'updated=${result.updatedCount}, '
      'skipped_unknown=${result.skippedUnknownCount}, '
      'skipped_up_to_date=${result.skippedUpToDateCount}',
    );
    if (_analytics != null) {
      await _analytics
          .logEvent('account_type_backfill_completed', <String, dynamic>{
            'scanned': result.scannedCount,
            'updated': result.updatedCount,
            'skippedUnknown': result.skippedUnknownCount,
            'skippedUpToDate': result.skippedUpToDateCount,
            'unknownTypeCount': unknownLegacyTypes.length,
          });
    }
    return result;
  }
}
