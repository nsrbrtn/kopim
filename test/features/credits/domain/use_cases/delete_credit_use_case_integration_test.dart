import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/accounts/data/repositories/account_repository_impl.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/use_cases/delete_account_use_case.dart';
import 'package:kopim/features/categories/data/repositories/category_repository_impl.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/domain/use_cases/delete_category_use_case.dart';
import 'package:kopim/features/credits/data/repositories/credit_repository_impl.dart';
import 'package:kopim/features/credits/data/sources/local/credit_dao.dart';
import 'package:kopim/features/credits/data/sources/local/credit_payment_dao.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_group.dart';
import 'package:kopim/features/credits/domain/use_cases/delete_credit_use_case.dart';
import 'package:kopim/features/savings/data/sources/local/goal_contribution_dao.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/upcoming_payments_dao.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/upcoming_payments_repository.dart';

// Напишем простую фейковую реализацию UpcomingPaymentsRepository для интеграционного теста
class _FakeUpcomingPaymentsRepository implements UpcomingPaymentsRepository {
  _FakeUpcomingPaymentsRepository(this._dao);
  final UpcomingPaymentsDao _dao;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<UpcomingPayment?> getByCategoryId(String categoryId) async {
    final List<UpcomingPayment> all = await _dao.getAll();
    for (final UpcomingPayment rule in all) {
      if (rule.categoryId == categoryId) return rule;
    }
    return null;
  }

  @override
  Future<void> delete(String id) async {
    await _dao.delete(id);
  }
}

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
  late UpcomingPaymentsDao upcomingPaymentsDao;

  late CreditRepositoryImpl creditRepository;
  late TransactionRepositoryImpl transactionRepository;
  late DeleteCreditUseCase useCase;

  final DateTime now = DateTime.utc(2026, 6, 15, 10, 0, 0);

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
    upcomingPaymentsDao = UpcomingPaymentsDao(database);

    transactionRepository = TransactionRepositoryImpl(
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

    useCase = DeleteCreditUseCase(
      creditRepository,
      transactionRepository,
      DeleteAccountUseCase(accountRepository),
      DeleteCategoryUseCase(categoryRepository),
      _FakeUpcomingPaymentsRepository(upcomingPaymentsDao),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'DeleteCreditUseCase откатывает изменения при ошибке в транзакции (Rollback)',
    () async {
      // Инициализируем данные
      await accountDao.upsert(
        AccountEntity(
          id: 'acc-1',
          name: 'Checking',
          balanceMinor: BigInt.from(1000),
          openingBalanceMinor: BigInt.from(1000),
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
          accountId: 'acc-1',
          interestRate: 10,
          termMonths: 12,
          startDate: now,
          paymentDay: 15,
          createdAt: now,
          updatedAt: now,
          totalAmountMinor: BigInt.from(500000),
          totalAmountScale: 2,
        ),
      );

      final CreditEntity creditBefore =
          (await creditRepository.getCredits()).first;
      expect(creditBefore.isDeleted, isFalse);

      final DeleteCreditUseCase useCaseWithError = DeleteCreditUseCase(
        creditRepository,
        transactionRepository,
        DeleteAccountUseCase(_ThrowingAccountRepository()),
        DeleteCategoryUseCase(
          CategoryRepositoryImpl(
            database: database,
            categoryDao: categoryDao,
            outboxDao: outboxDao,
          ),
        ),
        _FakeUpcomingPaymentsRepository(upcomingPaymentsDao),
      );

      // Создаем группу платежей и транзакцию
      final CreditPaymentGroupEntity group = CreditPaymentGroupEntity(
        id: 'group-1',
        creditId: 'credit-1',
        sourceAccountId: 'acc-1',
        paidAt: now,
        totalOutflow: _money(1000),
        principalPaid: _money(800),
        interestPaid: _money(200),
        feesPaid: _money(0),
        createdAt: now,
        updatedAt: now,
      );
      await creditPaymentDao.insertPaymentGroup(group);

      final TransactionEntity tx = TransactionEntity(
        id: 'tx-1',
        accountId: 'acc-1',
        groupId: 'group-1',
        amountMinor: BigInt.from(1000),
        amountScale: 2,
        date: now,
        type: 'expense',
        createdAt: now,
        updatedAt: now,
      );
      await transactionDao.upsert(tx);

      // Запускаем и ожидаем падение
      expect(
        () => useCaseWithError.call(creditBefore),
        throwsA(isA<StateError>()),
      );

      // Проверяем, что кредит и транзакция НЕ удалились (rollback сработал)
      final List<CreditEntity> creditsAfter = await creditRepository
          .getCredits();
      expect(creditsAfter.first.isDeleted, isFalse);

      final TransactionEntity? txAfter = await transactionRepository.findById(
        'tx-1',
      );
      expect(txAfter?.isDeleted, isFalse);
    },
  );

  test(
    'DeleteCreditUseCase софт-делитит транзакции, связанные как с активными, так и с tombstoned группами',
    () async {
      await accountDao.upsert(
        AccountEntity(
          id: 'acc-1',
          name: 'Checking',
          balanceMinor: BigInt.from(1000),
          openingBalanceMinor: BigInt.from(1000),
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
          accountId: 'acc-1',
          interestRate: 10,
          termMonths: 12,
          startDate: now,
          paymentDay: 15,
          createdAt: now,
          updatedAt: now,
          totalAmountMinor: BigInt.from(500000),
          totalAmountScale: 2,
        ),
      );

      // Активная группа платежей
      final CreditPaymentGroupEntity activeGroup = CreditPaymentGroupEntity(
        id: 'group-active',
        creditId: 'credit-1',
        sourceAccountId: 'acc-1',
        paidAt: now,
        totalOutflow: _money(1000),
        principalPaid: _money(800),
        interestPaid: _money(200),
        feesPaid: _money(0),
        createdAt: now,
        updatedAt: now,
      );
      await creditPaymentDao.insertPaymentGroup(activeGroup);

      // Tombstoned группа платежей (isDeleted = true)
      final CreditPaymentGroupEntity tombstonedGroup = CreditPaymentGroupEntity(
        id: 'group-tombstoned',
        creditId: 'credit-1',
        sourceAccountId: 'acc-1',
        paidAt: now,
        totalOutflow: _money(1000),
        principalPaid: _money(800),
        interestPaid: _money(200),
        feesPaid: _money(0),
        createdAt: now,
        updatedAt: now,
        isDeleted: true,
      );
      // Используем Drift для вставки tombstoned группы напрямую
      await database
          .into(database.creditPaymentGroups)
          .insert(
            db.CreditPaymentGroupsCompanion(
              id: Value<String>(tombstonedGroup.id),
              creditId: Value<String>(tombstonedGroup.creditId),
              sourceAccountId: Value<String>(tombstonedGroup.sourceAccountId),
              paidAt: Value<DateTime>(tombstonedGroup.paidAt),
              totalOutflowMinor: Value<String>(
                tombstonedGroup.totalOutflow.minor.toString(),
              ),
              totalOutflowScale: Value<int>(tombstonedGroup.totalOutflow.scale),
              principalPaidMinor: Value<String>(
                tombstonedGroup.principalPaid.minor.toString(),
              ),
              interestPaidMinor: Value<String>(
                tombstonedGroup.interestPaid.minor.toString(),
              ),
              feesPaidMinor: Value<String>(
                tombstonedGroup.feesPaid.minor.toString(),
              ),
              createdAt: Value<DateTime>(tombstonedGroup.createdAt!),
              updatedAt: Value<DateTime>(tombstonedGroup.updatedAt!),
              isDeleted: const Value<bool>(true),
            ),
          );

      // Транзакции
      final TransactionEntity txActive = TransactionEntity(
        id: 'tx-active',
        accountId: 'acc-1',
        groupId: 'group-active',
        amountMinor: BigInt.from(1000),
        amountScale: 2,
        date: now,
        type: 'expense',
        createdAt: now,
        updatedAt: now,
      );
      final TransactionEntity txTombstoned = TransactionEntity(
        id: 'tx-tombstoned',
        accountId: 'acc-1',
        groupId: 'group-tombstoned',
        amountMinor: BigInt.from(1000),
        amountScale: 2,
        date: now,
        type: 'expense',
        createdAt: now,
        updatedAt: now,
      );

      await transactionDao.upsert(txActive);
      await transactionDao.upsert(txTombstoned);

      // Вызываем удаление кредита
      final CreditEntity credit = (await creditRepository.getCredits()).first;
      await useCase.call(credit);

      // Проверяем, что обе транзакции были софт-делитнуты
      final TransactionEntity? txActiveAfter = await transactionRepository
          .findById('tx-active');
      expect(txActiveAfter?.isDeleted, isTrue);

      final TransactionEntity? txTombstonedAfter = await transactionRepository
          .findById('tx-tombstoned');
      expect(txTombstonedAfter?.isDeleted, isTrue);

      // Проверяем, что кредит удалился
      final List<CreditEntity> creditsAfter = await creditRepository
          .getCredits();
      expect(creditsAfter, isEmpty);
    },
  );
}

class _ThrowingAccountRepository extends AccountRepositoryImpl {
  _ThrowingAccountRepository()
    : super(
        database: db.AppDatabase.connect(
          DatabaseConnection(NativeDatabase.memory()),
        ),
        accountDao: AccountDao(
          db.AppDatabase.connect(DatabaseConnection(NativeDatabase.memory())),
        ),
        outboxDao: OutboxDao(
          db.AppDatabase.connect(DatabaseConnection(NativeDatabase.memory())),
        ),
      );

  @override
  Future<void> softDelete(String id) async {
    throw StateError('Simulated error for rollback test');
  }
}

Money _money(int minor) =>
    Money.fromMinor(BigInt.from(minor), currency: 'RUB', scale: 2);
