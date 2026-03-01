import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/credits/data/sources/local/credit_dao.dart';
import 'package:kopim/features/credits/data/sources/local/credit_payment_dao.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_group.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';

void main() {
  group('AppDatabase credit payment schedule миграции', () {
    final DateTime now = DateTime.utc(2026, 3, 1, 10);

    Future<void> seedCreditFixture(
      AppDatabase database,
      AccountDao accountDao,
      CreditDao creditDao,
    ) async {
      await accountDao.upsert(
        AccountEntity(
          id: 'source-1',
          name: 'Source',
          balanceMinor: BigInt.from(1_000_000),
          openingBalanceMinor: BigInt.from(1_000_000),
          currency: 'RUB',
          currencyScale: 2,
          type: 'checking',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await accountDao.upsert(
        AccountEntity(
          id: 'credit-acc-1',
          name: 'Credit',
          balanceMinor: BigInt.from(-500_000),
          openingBalanceMinor: BigInt.from(-500_000),
          currency: 'RUB',
          currencyScale: 2,
          type: 'credit',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await creditDao.upsert(
        CreditEntity(
          id: 'credit-1',
          accountId: 'credit-acc-1',
          interestRate: 10,
          termMonths: 12,
          startDate: now,
          paymentDay: 15,
          createdAt: now,
          updatedAt: now,
          totalAmountMinor: BigInt.from(500_000),
          totalAmountScale: 2,
        ),
      );
    }

    test('onCreate создает UNIQUE индекс period_key по кредиту', () async {
      final AppDatabase database = AppDatabase.connect(
        drift.DatabaseConnection(NativeDatabase.memory()),
      );
      final AccountDao accountDao = AccountDao(database);
      final CreditDao creditDao = CreditDao(database);
      final CreditPaymentDao creditPaymentDao = CreditPaymentDao(database);

      final List<String> indexes = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='index' AND name='payment_schedules_credit_period_unique'",
          )
          .map((drift.QueryRow row) => row.read<String>('name'))
          .get();
      expect(indexes, contains('payment_schedules_credit_period_unique'));

      await seedCreditFixture(database, accountDao, creditDao);

      await creditPaymentDao.insertSchedule(<CreditPaymentScheduleEntity>[
        CreditPaymentScheduleEntity(
          id: 'schedule-1',
          creditId: 'credit-1',
          periodKey: '2026-03',
          dueDate: now.add(const Duration(days: 10)),
          status: CreditPaymentStatus.planned,
          principalAmount: Money.fromMinor(
            BigInt.from(10_000),
            currency: 'RUB',
            scale: 2,
          ),
          interestAmount: Money.fromMinor(
            BigInt.from(1_000),
            currency: 'RUB',
            scale: 2,
          ),
          totalAmount: Money.fromMinor(
            BigInt.from(11_000),
            currency: 'RUB',
            scale: 2,
          ),
          principalPaid: Money.fromMinor(
            BigInt.zero,
            currency: 'RUB',
            scale: 2,
          ),
          interestPaid: Money.fromMinor(BigInt.zero, currency: 'RUB', scale: 2),
          paidAt: null,
        ),
      ]);

      await expectLater(
        () => creditPaymentDao.insertSchedule(<CreditPaymentScheduleEntity>[
          CreditPaymentScheduleEntity(
            id: 'schedule-2',
            creditId: 'credit-1',
            periodKey: '2026-03',
            dueDate: now.add(const Duration(days: 12)),
            status: CreditPaymentStatus.planned,
            principalAmount: Money.fromMinor(
              BigInt.from(10_000),
              currency: 'RUB',
              scale: 2,
            ),
            interestAmount: Money.fromMinor(
              BigInt.from(1_000),
              currency: 'RUB',
              scale: 2,
            ),
            totalAmount: Money.fromMinor(
              BigInt.from(11_000),
              currency: 'RUB',
              scale: 2,
            ),
            principalPaid: Money.fromMinor(
              BigInt.zero,
              currency: 'RUB',
              scale: 2,
            ),
            interestPaid: Money.fromMinor(
              BigInt.zero,
              currency: 'RUB',
              scale: 2,
            ),
            paidAt: null,
          ),
        ]),
        throwsA(anything),
      );

      await database.close();
    });

    test('onUpgrade 42->43 дедуплицирует period и создает UNIQUE индекс', () async {
      final AppDatabase database = AppDatabase.connect(
        drift.DatabaseConnection(NativeDatabase.memory()),
      );
      final AccountDao accountDao = AccountDao(database);
      final CreditDao creditDao = CreditDao(database);
      final CreditPaymentDao creditPaymentDao = CreditPaymentDao(database);

      await seedCreditFixture(database, accountDao, creditDao);

      await database.customStatement(
        'DROP INDEX IF EXISTS payment_schedules_credit_period_unique',
      );
      await database.customStatement(
        'CREATE INDEX IF NOT EXISTS payment_schedules_credit_period_idx ON credit_payment_schedules(credit_id, period_key)',
      );

      await creditPaymentDao.insertSchedule(<CreditPaymentScheduleEntity>[
        CreditPaymentScheduleEntity(
          id: 'schedule-old',
          creditId: 'credit-1',
          periodKey: '2026-03',
          dueDate: now.add(const Duration(days: 10)),
          status: CreditPaymentStatus.partiallyPaid,
          principalAmount: Money.fromMinor(
            BigInt.from(10_000),
            currency: 'RUB',
            scale: 2,
          ),
          interestAmount: Money.fromMinor(
            BigInt.from(1_000),
            currency: 'RUB',
            scale: 2,
          ),
          totalAmount: Money.fromMinor(
            BigInt.from(11_000),
            currency: 'RUB',
            scale: 2,
          ),
          principalPaid: Money.fromMinor(
            BigInt.from(3_000),
            currency: 'RUB',
            scale: 2,
          ),
          interestPaid: Money.fromMinor(
            BigInt.from(500),
            currency: 'RUB',
            scale: 2,
          ),
          paidAt: now,
        ),
        CreditPaymentScheduleEntity(
          id: 'schedule-new',
          creditId: 'credit-1',
          periodKey: '2026-03',
          dueDate: now.add(const Duration(days: 11)),
          status: CreditPaymentStatus.planned,
          principalAmount: Money.fromMinor(
            BigInt.from(10_000),
            currency: 'RUB',
            scale: 2,
          ),
          interestAmount: Money.fromMinor(
            BigInt.from(1_000),
            currency: 'RUB',
            scale: 2,
          ),
          totalAmount: Money.fromMinor(
            BigInt.from(11_000),
            currency: 'RUB',
            scale: 2,
          ),
          principalPaid: Money.fromMinor(
            BigInt.zero,
            currency: 'RUB',
            scale: 2,
          ),
          interestPaid: Money.fromMinor(BigInt.zero, currency: 'RUB', scale: 2),
          paidAt: null,
        ),
      ]);

      await database.customStatement(
        'UPDATE credit_payment_schedules SET updated_at = ? WHERE id = ?',
        <Object?>[
          DateTime.utc(2026, 3, 1, 9, 0, 0).millisecondsSinceEpoch,
          'schedule-old',
        ],
      );
      await database.customStatement(
        'UPDATE credit_payment_schedules SET updated_at = ? WHERE id = ?',
        <Object?>[
          DateTime.utc(2026, 3, 1, 11, 0, 0).millisecondsSinceEpoch,
          'schedule-new',
        ],
      );

      await creditPaymentDao.insertPaymentGroup(
        CreditPaymentGroupEntity(
          id: 'group-1',
          creditId: 'credit-1',
          sourceAccountId: 'source-1',
          scheduleItemId: 'schedule-old',
          paidAt: now,
          totalOutflow: Money.fromMinor(
            BigInt.from(3_500),
            currency: 'RUB',
            scale: 2,
          ),
          principalPaid: Money.fromMinor(
            BigInt.from(3_000),
            currency: 'RUB',
            scale: 2,
          ),
          interestPaid: Money.fromMinor(
            BigInt.from(500),
            currency: 'RUB',
            scale: 2,
          ),
          feesPaid: Money.fromMinor(BigInt.zero, currency: 'RUB', scale: 2),
          note: null,
          idempotencyKey: 'migration-test-group',
        ),
      );

      await database.customStatement('PRAGMA user_version = 42');
      final drift.Migrator migrator = drift.Migrator(database);
      await database.migration.onUpgrade(migrator, 42, database.schemaVersion);
      final drift.OpeningDetails details = drift.OpeningDetails(
        42,
        database.schemaVersion,
      );
      if (database.migration.beforeOpen != null) {
        await database.migration.beforeOpen!(details);
      }
      await database.customStatement(
        'PRAGMA user_version = ${database.schemaVersion}',
      );

      final List<drift.QueryRow> schedules = await database.customSelect('''
SELECT id
FROM credit_payment_schedules
WHERE credit_id = 'credit-1' AND period_key = '2026-03'
''').get();
      expect(schedules, hasLength(1));
      expect(schedules.single.read<String>('id'), 'schedule-new');

      final String? linkedScheduleId = await database
          .customSelect(
            "SELECT schedule_item_id FROM credit_payment_groups WHERE id = 'group-1' LIMIT 1",
          )
          .map((drift.QueryRow row) => row.read<String?>('schedule_item_id'))
          .getSingleOrNull();
      expect(linkedScheduleId, 'schedule-new');

      final List<String> indexes = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='index' AND name='payment_schedules_credit_period_unique'",
          )
          .map((drift.QueryRow row) => row.read<String>('name'))
          .get();
      expect(indexes, contains('payment_schedules_credit_period_unique'));

      await expectLater(
        () => creditPaymentDao.insertSchedule(<CreditPaymentScheduleEntity>[
          CreditPaymentScheduleEntity(
            id: 'schedule-after-upgrade',
            creditId: 'credit-1',
            periodKey: '2026-03',
            dueDate: now.add(const Duration(days: 12)),
            status: CreditPaymentStatus.planned,
            principalAmount: Money.fromMinor(
              BigInt.from(10_000),
              currency: 'RUB',
              scale: 2,
            ),
            interestAmount: Money.fromMinor(
              BigInt.from(1_000),
              currency: 'RUB',
              scale: 2,
            ),
            totalAmount: Money.fromMinor(
              BigInt.from(11_000),
              currency: 'RUB',
              scale: 2,
            ),
            principalPaid: Money.fromMinor(
              BigInt.zero,
              currency: 'RUB',
              scale: 2,
            ),
            interestPaid: Money.fromMinor(
              BigInt.zero,
              currency: 'RUB',
              scale: 2,
            ),
            paidAt: null,
          ),
        ]),
        throwsA(anything),
      );

      await database.close();
    });
  });
}
