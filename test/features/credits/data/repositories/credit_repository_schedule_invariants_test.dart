import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/credits/data/repositories/credit_repository_impl.dart';
import 'package:kopim/features/credits/data/sources/local/credit_dao.dart';
import 'package:kopim/features/credits/data/sources/local/credit_payment_dao.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_group.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';

void main() {
  late db.AppDatabase database;
  late AccountDao accountDao;
  late CreditDao creditDao;
  late CreditPaymentDao creditPaymentDao;
  late OutboxDao outboxDao;
  late CreditRepositoryImpl repository;
  final DateTime now = DateTime.utc(2026, 3, 1, 10);

  setUp(() async {
    database = db.AppDatabase.connect(
      DatabaseConnection(NativeDatabase.memory()),
    );
    accountDao = AccountDao(database);
    creditDao = CreditDao(database);
    creditPaymentDao = CreditPaymentDao(database);
    outboxDao = OutboxDao(database);
    repository = CreditRepositoryImpl(
      database: database,
      creditDao: creditDao,
      creditPaymentDao: creditPaymentDao,
      outboxDao: outboxDao,
    );

    await accountDao.upsert(
      AccountEntity(
        id: 'credit-acc',
        name: 'Credit',
        balanceMinor: BigInt.from(-300_000),
        openingBalanceMinor: BigInt.from(-300_000),
        currency: 'RUB',
        currencyScale: 2,
        type: 'credit',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await accountDao.upsert(
      AccountEntity(
        id: 'source-acc',
        name: 'Source',
        balanceMinor: BigInt.from(500_000),
        openingBalanceMinor: BigInt.from(500_000),
        currency: 'RUB',
        currencyScale: 2,
        type: 'checking',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await creditDao.upsert(
      CreditEntity(
        id: 'credit-1',
        accountId: 'credit-acc',
        interestRate: 10,
        termMonths: 12,
        startDate: now,
        paymentDay: 15,
        createdAt: now,
        updatedAt: now,
        totalAmountMinor: BigInt.from(300_000),
        totalAmountScale: 2,
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('addSchedule отклоняет status=planned со значением paid > 0', () async {
    await expectLater(
      () => repository.addSchedule(<CreditPaymentScheduleEntity>[
        CreditPaymentScheduleEntity(
          id: 'sched-1',
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
            BigInt.from(1),
            currency: 'RUB',
            scale: 2,
          ),
          interestPaid: Money.fromMinor(BigInt.zero, currency: 'RUB', scale: 2),
          paidAt: null,
        ),
      ]),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('updateScheduleItem отклоняет status=paid без paidAt', () async {
    final CreditPaymentScheduleEntity valid = CreditPaymentScheduleEntity(
      id: 'sched-2',
      creditId: 'credit-1',
      periodKey: '2026-04',
      dueDate: now.add(const Duration(days: 40)),
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
      principalPaid: Money.fromMinor(BigInt.zero, currency: 'RUB', scale: 2),
      interestPaid: Money.fromMinor(BigInt.zero, currency: 'RUB', scale: 2),
      paidAt: null,
    );
    await repository.addSchedule(<CreditPaymentScheduleEntity>[valid]);

    final CreditPaymentScheduleEntity invalid = valid.copyWith(
      status: CreditPaymentStatus.paid,
      principalPaid: Money.fromMinor(
        BigInt.from(10_000),
        currency: 'RUB',
        scale: 2,
      ),
      interestPaid: Money.fromMinor(
        BigInt.from(1_000),
        currency: 'RUB',
        scale: 2,
      ),
      paidAt: null,
    );

    await expectLater(
      () => repository.updateScheduleItem(invalid),
      throwsA(isA<ArgumentError>()),
    );
  });

  test(
    'deleteCredit помечает credit payment artifacts tombstone и ставит delete payload с isDeleted=true',
    () async {
      final CreditPaymentScheduleEntity schedule = CreditPaymentScheduleEntity(
        id: 'sched-delete-1',
        creditId: 'credit-1',
        periodKey: '2026-05',
        dueDate: now.add(const Duration(days: 60)),
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
        principalPaid: Money.fromMinor(BigInt.zero, currency: 'RUB', scale: 2),
        interestPaid: Money.fromMinor(BigInt.zero, currency: 'RUB', scale: 2),
        createdAt: now,
        updatedAt: now,
      );
      final CreditPaymentGroupEntity group = CreditPaymentGroupEntity(
        id: 'group-delete-1',
        creditId: 'credit-1',
        sourceAccountId: 'source-acc',
        scheduleItemId: schedule.id,
        paidAt: now.add(const Duration(days: 1)),
        totalOutflow: Money.fromMinor(
          BigInt.from(11_000),
          currency: 'RUB',
          scale: 2,
        ),
        principalPaid: Money.fromMinor(
          BigInt.from(10_000),
          currency: 'RUB',
          scale: 2,
        ),
        interestPaid: Money.fromMinor(
          BigInt.from(1_000),
          currency: 'RUB',
          scale: 2,
        ),
        feesPaid: Money.fromMinor(BigInt.zero, currency: 'RUB', scale: 2),
        createdAt: now,
        updatedAt: now,
      );

      await repository.addSchedule(<CreditPaymentScheduleEntity>[schedule]);
      await repository.addPaymentGroup(group);

      await repository.deleteCredit('credit-1');

      expect(await repository.getSchedule('credit-1'), isEmpty);
      expect(await repository.getPaymentGroups('credit-1'), isEmpty);

      final CreditPaymentScheduleEntity storedSchedule =
          (await creditPaymentDao.getAllScheduleItems()).singleWhere(
            (CreditPaymentScheduleEntity item) => item.id == schedule.id,
          );
      final CreditPaymentGroupEntity storedGroup =
          (await creditPaymentDao.getAllPaymentGroups()).singleWhere(
            (CreditPaymentGroupEntity item) => item.id == group.id,
          );
      expect(storedSchedule.isDeleted, isTrue);
      expect(storedGroup.isDeleted, isTrue);

      final List<db.OutboxEntryRow> outboxRows = await database
          .select(database.outboxEntries)
          .get();
      final db.OutboxEntryRow scheduleDelete = outboxRows.lastWhere(
        (db.OutboxEntryRow row) =>
            row.entityType == 'credit_payment_schedule' &&
            row.entityId == schedule.id &&
            row.operation == OutboxOperation.delete.name,
      );
      final db.OutboxEntryRow groupDelete = outboxRows.lastWhere(
        (db.OutboxEntryRow row) =>
            row.entityType == 'credit_payment_group' &&
            row.entityId == group.id &&
            row.operation == OutboxOperation.delete.name,
      );

      expect(outboxDao.decodePayload(scheduleDelete)['isDeleted'], isTrue);
      expect(outboxDao.decodePayload(groupDelete)['isDeleted'], isTrue);
    },
  );
}
