import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/accounts/data/repositories/account_repository_impl.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/data/repositories/category_repository_impl.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/credits/data/repositories/credit_repository_impl.dart';
import 'package:kopim/features/credits/data/sources/local/credit_dao.dart';
import 'package:kopim/features/credits/data/sources/local/credit_payment_dao.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_group.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';
import 'package:kopim/features/credits/domain/use_cases/make_credit_payment_use_case.dart';
import 'package:kopim/features/savings/data/sources/local/goal_contribution_dao.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:uuid/uuid.dart';

void main() {
  late db.AppDatabase database;
  late AccountDao accountDao;
  late CreditDao creditDao;
  late TransactionDao transactionDao;
  late CreditPaymentDao creditPaymentDao;
  late CategoryDao categoryDao;
  late SavingGoalDao savingGoalDao;
  late GoalContributionDao contributionDao;
  late OutboxDao outboxDao;
  late CreditRepositoryImpl creditRepository;
  late MakeCreditPaymentUseCase useCase;

  final DateTime now = DateTime.utc(2026, 3, 1, 10, 0, 0);

  setUp(() {
    database = db.AppDatabase.connect(
      DatabaseConnection(NativeDatabase.memory()),
    );
    accountDao = AccountDao(database);
    creditDao = CreditDao(database);
    transactionDao = TransactionDao(database);
    creditPaymentDao = CreditPaymentDao(database);
    categoryDao = CategoryDao(database);
    savingGoalDao = SavingGoalDao(database);
    contributionDao = GoalContributionDao(database);
    outboxDao = OutboxDao(database);

    final TransactionRepositoryImpl transactionRepository =
        TransactionRepositoryImpl(
          database: database,
          transactionDao: transactionDao,
          accountDao: accountDao,
          creditDao: creditDao,
          savingGoalDao: savingGoalDao,
          goalContributionDao: contributionDao,
          outboxDao: outboxDao,
        );
    creditRepository = CreditRepositoryImpl(
      database: database,
      creditDao: creditDao,
      creditPaymentDao: creditPaymentDao,
      outboxDao: outboxDao,
    );
    final AccountRepositoryImpl accountRepository = AccountRepositoryImpl(
      database: database,
      accountDao: accountDao,
      outboxDao: outboxDao,
    );
    final CategoryRepositoryImpl categoryRepository = CategoryRepositoryImpl(
      database: database,
      categoryDao: categoryDao,
      outboxDao: outboxDao,
    );

    useCase = MakeCreditPaymentUseCase(
      creditRepository: creditRepository,
      transactionRepository: transactionRepository,
      accountRepository: accountRepository,
      categoryRepository: categoryRepository,
      uuid: const Uuid(),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'параллельные вызовы с одним idempotencyKey создают только один платеж',
    () async {
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

      Future<void> pay() {
        return useCase.call(
          creditId: 'credit-1',
          sourceAccountId: 'source-1',
          paidAt: now,
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
          feesPaid: Money.fromMinor(
            BigInt.from(500),
            currency: 'RUB',
            scale: 2,
          ),
          totalOutflow: Money.fromMinor(
            BigInt.from(11_500),
            currency: 'RUB',
            scale: 2,
          ),
          idempotencyKey: 'manual:credit-1:parallel',
        );
      }

      await Future.wait(<Future<void>>[pay(), pay()]);

      final List<db.CreditPaymentGroupRow> groups =
          await (database.select(database.creditPaymentGroups)
                ..where(
                  (db.$CreditPaymentGroupsTable tbl) =>
                      tbl.creditId.equals('credit-1'),
                )
                ..where(
                  (db.$CreditPaymentGroupsTable tbl) =>
                      tbl.idempotencyKey.equals('manual:credit-1:parallel'),
                ))
              .get();
      expect(groups, hasLength(1));

      final List<db.TransactionRow> transactions =
          await (database.select(database.transactions)
                ..where(
                  (db.$TransactionsTable tbl) =>
                      tbl.groupId.equals(groups.single.id),
                )
                ..where(
                  (db.$TransactionsTable tbl) => tbl.isDeleted.equals(false),
                ))
              .get();
      expect(transactions, hasLength(3));
      expect(
        transactions.map((db.TransactionRow tx) => tx.idempotencyKey),
        containsAll(<String>[
          'manual:credit-1:parallel:principal',
          'manual:credit-1:parallel:interest',
          'manual:credit-1:parallel:fees',
        ]),
      );
      final List<CreditPaymentGroupEntity> domainGroups = await creditRepository
          .getPaymentGroups('credit-1');
      expect(domainGroups, hasLength(1));
      expect(domainGroups.single.totalOutflow.currency, 'RUB');

      final db.AccountRow? sourceAccount = await accountDao.findById(
        'source-1',
      );
      final db.AccountRow? creditAccount = await accountDao.findById(
        'credit-acc-1',
      );
      expect(sourceAccount, isNotNull);
      expect(creditAccount, isNotNull);
      expect(sourceAccount!.balance, closeTo(9_885.0, 1e-9));
      expect(creditAccount!.balance, closeTo(-4_900.0, 1e-9));
    },
  );

  test('schedule возвращается с валютой кредитного счета, а не XXX', () async {
    await accountDao.upsert(
      AccountEntity(
        id: 'credit-acc-usd',
        name: 'Credit USD',
        balanceMinor: BigInt.from(-200_000),
        openingBalanceMinor: BigInt.from(-200_000),
        currency: 'USD',
        currencyScale: 2,
        type: 'credit',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await creditDao.upsert(
      CreditEntity(
        id: 'credit-usd',
        accountId: 'credit-acc-usd',
        interestRate: 11,
        termMonths: 12,
        startDate: now,
        paymentDay: 15,
        createdAt: now,
        updatedAt: now,
        totalAmountMinor: BigInt.from(200_000),
        totalAmountScale: 2,
      ),
    );

    await creditRepository.addSchedule(<CreditPaymentScheduleEntity>[
      CreditPaymentScheduleEntity(
        id: 'sched-1',
        creditId: 'credit-usd',
        periodKey: '2026-03',
        dueDate: now.add(const Duration(days: 15)),
        status: CreditPaymentStatus.planned,
        principalAmount: Money.fromMinor(
          BigInt.from(8_000),
          currency: 'XXX',
          scale: 2,
        ),
        interestAmount: Money.fromMinor(
          BigInt.from(1_500),
          currency: 'XXX',
          scale: 2,
        ),
        totalAmount: Money.fromMinor(
          BigInt.from(9_500),
          currency: 'XXX',
          scale: 2,
        ),
        principalPaid: Money.fromMinor(BigInt.zero, currency: 'XXX', scale: 2),
        interestPaid: Money.fromMinor(BigInt.zero, currency: 'XXX', scale: 2),
        paidAt: null,
      ),
    ]);

    final List<CreditPaymentScheduleEntity> schedule = await creditRepository
        .getSchedule('credit-usd');
    expect(schedule, hasLength(1));
    expect(schedule.single.totalAmount.currency, 'USD');
    expect(schedule.single.principalAmount.currency, 'USD');
    expect(schedule.single.interestAmount.currency, 'USD');
  });

  test(
    'переплата по periodKey отклоняется и не создает payment group',
    () async {
      await accountDao.upsert(
        AccountEntity(
          id: 'source-2',
          name: 'Source 2',
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
          id: 'credit-acc-2',
          name: 'Credit 2',
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
          id: 'credit-2',
          accountId: 'credit-acc-2',
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

      await creditRepository.addSchedule(<CreditPaymentScheduleEntity>[
        CreditPaymentScheduleEntity(
          id: 'sched-overpay',
          creditId: 'credit-2',
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
            BigInt.from(9_500),
            currency: 'RUB',
            scale: 2,
          ),
          interestPaid: Money.fromMinor(
            BigInt.from(500),
            currency: 'RUB',
            scale: 2,
          ),
          paidAt: null,
        ),
      ]);

      await expectLater(
        () => useCase.call(
          creditId: 'credit-2',
          sourceAccountId: 'source-2',
          paidAt: now,
          principalPaid: Money.fromMinor(
            BigInt.from(1_000),
            currency: 'RUB',
            scale: 2,
          ),
          interestPaid: Money.fromMinor(
            BigInt.from(600),
            currency: 'RUB',
            scale: 2,
          ),
          feesPaid: Money.fromMinor(BigInt.zero, currency: 'RUB', scale: 2),
          totalOutflow: Money.fromMinor(
            BigInt.from(1_600),
            currency: 'RUB',
            scale: 2,
          ),
          idempotencyKey: 'manual:credit-2:overpay',
          periodKey: '2026-03',
        ),
        throwsA(isA<ArgumentError>()),
      );

      final List<db.CreditPaymentGroupRow> groups =
          await (database.select(database.creditPaymentGroups)..where(
                (db.$CreditPaymentGroupsTable tbl) =>
                    tbl.idempotencyKey.equals('manual:credit-2:overpay'),
              ))
              .get();
      expect(groups, isEmpty);
    },
  );
}
