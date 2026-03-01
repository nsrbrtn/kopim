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
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';

void main() {
  late db.AppDatabase database;
  late AccountDao accountDao;
  late CreditDao creditDao;
  late CreditRepositoryImpl repository;
  final DateTime now = DateTime.utc(2026, 3, 1, 10);

  setUp(() async {
    database = db.AppDatabase.connect(
      DatabaseConnection(NativeDatabase.memory()),
    );
    accountDao = AccountDao(database);
    creditDao = CreditDao(database);
    repository = CreditRepositoryImpl(
      database: database,
      creditDao: creditDao,
      creditPaymentDao: CreditPaymentDao(database),
      outboxDao: OutboxDao(database),
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
}
