import 'dart:convert';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/accounts/data/services/account_type_backfill_service.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoggerService extends Mock implements LoggerService {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late db.AppDatabase database;
  late AccountTypeBackfillService service;
  late _MockLoggerService logger;
  late _MockAnalyticsService analytics;

  setUp(() {
    database = db.AppDatabase.connect(
      DatabaseConnection(NativeDatabase.memory()),
    );
    logger = _MockLoggerService();
    analytics = _MockAnalyticsService();
    when(() => logger.logInfo(any())).thenReturn(null);
    when(() => analytics.logEvent(any(), any())).thenAnswer((_) async {});
    service = AccountTypeBackfillService(
      database: database,
      accountDao: AccountDao(database),
      outboxDao: OutboxDao(database),
      loggerService: logger,
      analyticsService: analytics,
    );
  });

  tearDown(() async {
    await database.close();
  });

  AccountEntity buildAccount({
    required String id,
    required String type,
    int typeVersion = 0,
  }) {
    final DateTime now = DateTime.utc(2026, 4, 10, 12);
    return AccountEntity(
      id: id,
      name: id,
      balanceMinor: BigInt.zero,
      openingBalanceMinor: BigInt.zero,
      currency: 'RUB',
      currencyScale: 2,
      type: type,
      typeVersion: typeVersion,
      createdAt: now,
      updatedAt: now,
    );
  }

  test(
    'backfill переписывает только whitelist legacy type и ставит marker',
    () async {
      final AccountDao accountDao = AccountDao(database);
      await accountDao.upsertAll(<AccountEntity>[
        buildAccount(id: 'legacy-card', type: 'card'),
        buildAccount(id: 'bank', type: 'bank'),
        buildAccount(id: 'custom', type: 'custom:broker'),
      ]);

      final AccountTypeBackfillResult result = await service.run(
        now: DateTime.utc(2026, 4, 10, 14),
      );

      expect(result.scannedCount, 3);
      expect(result.updatedCount, 2);
      expect(result.skippedUnknownCount, 1);
      expect(result.skippedUpToDateCount, 0);

      final List<db.AccountRow> rows = await database
          .select(database.accounts)
          .get();
      final db.AccountRow legacyCard = rows.firstWhere(
        (db.AccountRow row) => row.id == 'legacy-card',
      );
      final db.AccountRow bank = rows.firstWhere(
        (db.AccountRow row) => row.id == 'bank',
      );
      final db.AccountRow custom = rows.firstWhere(
        (db.AccountRow row) => row.id == 'custom',
      );

      expect(legacyCard.type, 'bank');
      expect(legacyCard.typeVersion, 1);
      expect(bank.type, 'bank');
      expect(bank.typeVersion, 1);
      expect(custom.type, 'custom:broker');
      expect(custom.typeVersion, 0);

      final List<db.OutboxEntryRow> outbox = await database
          .select(database.outboxEntries)
          .get();
      expect(outbox, hasLength(2));
      final List<Map<String, dynamic>> payloads = outbox
          .map(
            (db.OutboxEntryRow row) =>
                jsonDecode(row.payload) as Map<String, dynamic>,
          )
          .toList(growable: false);
      expect(
        payloads.map((Map<String, dynamic> payload) => payload['id']),
        containsAll(<String>['legacy-card', 'bank']),
      );
      expect(
        payloads.every(
          (Map<String, dynamic> payload) => payload['typeVersion'] == 1,
        ),
        isTrue,
      );
      verify(
        () => analytics.logEvent('account_type_backfill_completed', any()),
      ).called(1);
      final List<dynamic> loggedMessages = verify(
        () => logger.logInfo(captureAny()),
      ).captured;
      expect(
        loggedMessages.any(
          (dynamic value) =>
              value.toString().contains('skipped unknown legacy account types'),
        ),
        isTrue,
      );
      expect(
        loggedMessages.any(
          (dynamic value) => value.toString().contains('scanned=3'),
        ),
        isTrue,
      );
    },
  );

  test('backfill идемпотентен для уже мигрированных записей', () async {
    final AccountDao accountDao = AccountDao(database);
    await accountDao.upsert(
      buildAccount(id: 'bank', type: 'bank', typeVersion: 1),
    );

    final AccountTypeBackfillResult result = await service.run();

    expect(result.scannedCount, 1);
    expect(result.updatedCount, 0);
    expect(result.skippedUnknownCount, 0);
    expect(result.skippedUpToDateCount, 1);

    final List<db.OutboxEntryRow> outbox = await database
        .select(database.outboxEntries)
        .get();
    expect(outbox, isEmpty);
  });
}
