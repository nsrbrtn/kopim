import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/core/services/auth_sync_service.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/data/sources/remote/account_remote_data_source.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/data/sources/local/budget_dao.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_instance_remote_data_source.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_remote_data_source.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance_status.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/data/sources/remote/category_remote_data_source.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/profile/data/local/profile_dao.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:kopim/features/savings/data/sources/remote/saving_goal_remote_data_source.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/settings/data/repositories/import_data_repository_impl.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/tags/data/sources/local/tag_dao.dart';
import 'package:kopim/features/tags/data/sources/local/transaction_tags_dao.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/payment_reminders_dao.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/upcoming_payments_dao.dart';
import 'package:kopim/features/upcoming_payments/data/sources/remote/payment_reminder_remote_data_source.dart';
import 'package:kopim/features/upcoming_payments/data/sources/remote/upcoming_payment_remote_data_source.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'support/auth_sync_test_harness.dart';
import 'package:mocktail/mocktail.dart';

class ThrowingAccountRemoteDataSource extends AccountRemoteDataSource {
  ThrowingAccountRemoteDataSource(super.firestore);

  @override
  void upsertInTransaction(
    Transaction transaction,
    String userId,
    AccountEntity account,
  ) {
    throw FirebaseException(plugin: 'cloud_firestore', message: 'boom');
  }
}

void main() {
  late AuthSyncTestHarness harness;
  late db.AppDatabase database;
  late OutboxDao outboxDao;
  late AccountDao accountDao;
  late CategoryDao categoryDao;
  late TransactionDao transactionDao;
  late BudgetDao budgetDao;
  late BudgetInstanceDao budgetInstanceDao;
  late UpcomingPaymentsDao upcomingPaymentsDao;
  late PaymentRemindersDao paymentRemindersDao;
  late TagDao tagDao;
  late TransactionTagsDao transactionTagsDao;
  late ProfileDao profileDao;
  late FirebaseFirestore firestore;
  late BudgetRemoteDataSource budgetRemote;
  late BudgetInstanceRemoteDataSource budgetInstanceRemote;
  late ImportDataRepositoryImpl importRepository;

  AuthSyncService buildService({
    AccountRemoteDataSource? accountRemoteDataSource,
    BudgetRemoteDataSource? budgetRemoteDataSource,
    BudgetInstanceRemoteDataSource? budgetInstanceRemoteDataSource,
    SavingGoalRemoteDataSource? savingGoalRemoteDataSource,
    UpcomingPaymentRemoteDataSource? upcomingPaymentRemoteDataSource,
    PaymentReminderRemoteDataSource? paymentReminderRemoteDataSource,
  }) {
    return harness.buildService(
      accountRemoteDataSource: accountRemoteDataSource,
      budgetRemoteDataSource: budgetRemoteDataSource,
      budgetInstanceRemoteDataSource: budgetInstanceRemoteDataSource,
      savingGoalRemoteDataSource: savingGoalRemoteDataSource,
      upcomingPaymentRemoteDataSource: upcomingPaymentRemoteDataSource,
      paymentReminderRemoteDataSource: paymentReminderRemoteDataSource,
    );
  }

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(StackTrace.empty);
  });

  setUp(() async {
    harness = AuthSyncTestHarness();
    await harness.setUp();
    database = harness.database;
    outboxDao = harness.outboxDao;
    accountDao = harness.accountDao;
    categoryDao = harness.categoryDao;
    transactionDao = harness.transactionDao;
    budgetDao = harness.budgetDao;
    budgetInstanceDao = harness.budgetInstanceDao;
    upcomingPaymentsDao = harness.upcomingPaymentsDao;
    paymentRemindersDao = harness.paymentRemindersDao;
    tagDao = harness.tagDao;
    transactionTagsDao = harness.transactionTagsDao;
    profileDao = harness.profileDao;
    firestore = harness.firestore;
    budgetRemote = harness.budgetRemote;
    budgetInstanceRemote = harness.budgetInstanceRemote;
    importRepository = harness.importRepository;
  });

  tearDown(() async {
    await harness.tearDown();
  });

  group('AuthSyncService', () {
    test(
      'replays outbox entries, merges remote data and profile on login',
      () async {
        final AuthSyncService service = buildService();
        const String userId = 'user-1';
        const double balance = 1500;
        final int accountScale = resolveCurrencyScale('RUB');
        final MoneyAmount balanceAmount = resolveMoneyAmount(
          amount: balance,
          scale: accountScale,
        );
        final AccountEntity account = AccountEntity(
          id: 'acc-1',
          name: 'Main',
          balanceMinor: balanceAmount.minor,
          openingBalanceMinor: balanceAmount.minor,
          currency: 'RUB',
          currencyScale: accountScale,
          type: 'checking',
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 1, 2),
          isDeleted: false,
        );

        await firestore
            .collection('users')
            .doc(userId)
            .collection('accounts')
            .doc(account.id)
            .set(<String, dynamic>{
              'id': account.id,
              'name': 'Legacy',
              'balance': 300,
              'currency': 'RUB',
              'type': 'checking',
              'createdAt': Timestamp.fromDate(DateTime.utc(2023, 1, 1)),
              'updatedAt': Timestamp.fromDate(DateTime.utc(2023, 1, 1)),
              'isDeleted': false,
            });

        await firestore
            .collection('users')
            .doc(userId)
            .collection('profile')
            .doc('profile')
            .set(<String, dynamic>{
              'uid': userId,
              'name': 'Old Name',
              'currency': 'RUB',
              'locale': 'en',
              'updatedAt': Timestamp.fromDate(DateTime.utc(2023, 1, 1)),
            });

        await outboxDao.enqueue(
          entityType: 'account',
          entityId: account.id,
          operation: OutboxOperation.upsert,
          payload: account.toJson()
            ..['updatedAt'] = account.updatedAt.toIso8601String()
            ..['createdAt'] = account.createdAt.toIso8601String()
            ..['balanceMinor'] = balanceAmount.minor.toString()
            ..['openingBalanceMinor'] = balanceAmount.minor.toString()
            ..['currencyScale'] = accountScale,
        );

        const Map<String, String> profilePayload = <String, String>{
          'uid': userId,
          'name': 'Alice',
          'currency': 'eur',
          'locale': 'de',
          'updatedAt': '2024-02-01T00:00:00.000Z',
        };

        await outboxDao.enqueue(
          entityType: 'profile',
          entityId: userId,
          operation: OutboxOperation.upsert,
          payload: profilePayload,
        );

        final Budget localBudget = Budget(
          id: 'budget-1',
          title: 'Groceries',
          period: BudgetPeriod.monthly,
          startDate: DateTime.utc(2024, 1, 1, 0, 1),
          endDate: null,
          amountMinor: BigInt.from(50000),
          amountScale: 2,
          scope: BudgetScope.all,
          categories: const <String>[],
          accounts: const <String>[],
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 1, 2),
        );

        await outboxDao.enqueue(
          entityType: 'budget',
          entityId: localBudget.id,
          operation: OutboxOperation.upsert,
          payload: localBudget.toJson()
            ..['amountMinor'] = localBudget.amountMinor.toString()
            ..['amountScale'] = localBudget.amountScale
            ..['startDate'] = localBudget.startDate.toIso8601String()
            ..['endDate'] = localBudget.endDate?.toIso8601String()
            ..['createdAt'] = localBudget.createdAt.toIso8601String()
            ..['updatedAt'] = localBudget.updatedAt.toIso8601String(),
        );

        final Budget remoteBudget = Budget(
          id: 'budget-remote',
          title: 'Travel Remote',
          period: BudgetPeriod.custom,
          startDate: DateTime.utc(2023, 12, 1, 0, 1),
          endDate: DateTime.utc(2023, 12, 31, 0, 1),
          amountMinor: BigInt.from(80000),
          amountScale: 2,
          scope: BudgetScope.all,
          categories: const <String>[],
          accounts: const <String>[],
          createdAt: DateTime.utc(2023, 12, 1),
          updatedAt: DateTime.utc(2024, 3, 1),
        );

        await budgetDao.upsert(
          remoteBudget.copyWith(
            title: 'Travel Local',
            updatedAt: DateTime.utc(2024, 2, 1),
          ),
        );

        final BudgetInstance remoteInstance = BudgetInstance(
          id: 'budget-remote-2024-03',
          budgetId: remoteBudget.id,
          periodStart: DateTime.utc(2024, 3, 1, 0, 1),
          periodEnd: DateTime.utc(2024, 4, 1, 0, 1),
          amountMinor: remoteBudget.amountValue.minor,
          amountScale: remoteBudget.amountValue.scale,
          spentMinor: BigInt.from(15000),
          status: BudgetInstanceStatus.active,
          createdAt: DateTime.utc(2024, 3, 1),
          updatedAt: DateTime.utc(2024, 3, 5),
        );

        await budgetInstanceDao.upsert(
          remoteInstance.copyWith(
            spentMinor: BigInt.from(6000),
            updatedAt: DateTime.utc(2024, 3, 3),
          ),
        );

        await budgetRemote.upsert(userId, remoteBudget);
        await budgetInstanceRemote.upsert(userId, remoteInstance);

        final AuthUser authUser = AuthUser(
          uid: userId,
          email: 'user@kopim.app',
          displayName: 'User',
          photoUrl: null,
          isAnonymous: false,
          emailVerified: true,
          creationTime: DateTime.utc(2024, 1, 1),
          lastSignInTime: DateTime.utc(2024, 1, 2),
        );

        await service.synchronizeOnLogin(user: authUser, previousUser: null);

        final DocumentSnapshot<Map<String, dynamic>> remoteDoc = await firestore
            .collection('users')
            .doc(userId)
            .collection('accounts')
            .doc(account.id)
            .get();

        expect(remoteDoc.exists, isTrue);
        expect(remoteDoc.data()?['balance'], equals(balance));
        expect(
          remoteDoc.data()?['balanceMinor'],
          equals(balanceAmount.minor.toString()),
        );
        expect(remoteDoc.data()?['currencyScale'], equals(accountScale));

        final List<AccountEntity> localAccounts = await accountDao
            .getAllAccounts();
        expect(localAccounts, hasLength(1));
        expect(localAccounts.single.balanceAmount.toDouble(), equals(balance));
        expect(
          localAccounts.single.openingBalanceAmount.toDouble(),
          equals(balance),
        );
        expect(localAccounts.single.balanceMinor, equals(balanceAmount.minor));
        expect(localAccounts.single.currencyScale, equals(accountScale));

        final DocumentSnapshot<Map<String, dynamic>> profileDoc =
            await firestore
                .collection('users')
                .doc(userId)
                .collection('profile')
                .doc('profile')
                .get();
        expect(profileDoc.exists, isTrue);
        expect(profileDoc.data()?['name'], equals('Alice'));
        expect(profileDoc.data()?['currency'], equals('EUR'));
        expect(profileDoc.data()?['locale'], equals('de'));

        final Profile? localProfile = await profileDao.getProfile(userId);
        expect(localProfile, isNotNull);
        expect(localProfile!.name, equals('Alice'));
        expect(localProfile.currency, equals(ProfileCurrency.eur));
        expect(localProfile.locale, equals('de'));

        final List<Budget> storedBudgets = await budgetDao.getAllBudgets();
        expect(
          storedBudgets.map((Budget b) => b.id),
          containsAll(<String>{localBudget.id, remoteBudget.id}),
        );
        final Budget mergedRemoteBudget = storedBudgets.firstWhere(
          (Budget b) => b.id == remoteBudget.id,
        );
        expect(mergedRemoteBudget.title, equals(remoteBudget.title));
        expect(
          mergedRemoteBudget.updatedAt.isAtSameMomentAs(remoteBudget.updatedAt),
          isTrue,
        );

        final Budget mergedLocalBudget = storedBudgets.firstWhere(
          (Budget b) => b.id == localBudget.id,
        );
        expect(
          mergedLocalBudget.amountValue.minor,
          equals(localBudget.amountValue.minor),
        );
        expect(
          mergedLocalBudget.amountValue.scale,
          equals(localBudget.amountValue.scale),
        );
        expect(mergedLocalBudget.scope, equals(BudgetScope.all));

        final List<BudgetInstance> storedInstances = await budgetInstanceDao
            .getAllInstances();
        expect(storedInstances, hasLength(1));
        expect(
          storedInstances.single.spentValue,
          equals(remoteInstance.spentValue),
        );
        expect(
          storedInstances.single.status,
          equals(BudgetInstanceStatus.active),
        );

        final List<Budget> remoteBudgets = await budgetRemote.fetchAll(userId);
        expect(remoteBudgets.map((Budget b) => b.id), contains(localBudget.id));
        final Budget remoteStoredBudget = remoteBudgets.firstWhere(
          (Budget b) => b.id == localBudget.id,
        );
        expect(
          remoteStoredBudget.updatedAt.isAtSameMomentAs(localBudget.updatedAt),
          isTrue,
        );

        final List<BudgetInstance> remoteInstances = await budgetInstanceRemote
            .fetchAll(userId);
        expect(
          remoteInstances.map((BudgetInstance i) => i.id),
          contains(remoteInstance.id),
        );

        expect(await outboxDao.pendingCount(), equals(0));

        verify(
          () => harness.analytics.logEvent('auth_sync_start', any()),
        ).called(1);
        verify(
          () => harness.analytics.logEvent('auth_sync_success', any()),
        ).called(1);
      },
    );

    test('processes all pending outbox batches before remote merge', () async {
      final AuthSyncService service = buildService();
      const String userId = 'batch-user';

      await firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('profile')
          .set(<String, dynamic>{
            'uid': userId,
            'name': 'Batch User',
            'currency': 'RUB',
            'locale': 'ru',
            'updatedAt': Timestamp.fromDate(DateTime.utc(2024, 1, 1)),
          });

      for (int i = 0; i < 501; i++) {
        final DateTime updatedAt = DateTime.utc(
          2024,
          1,
          1,
        ).add(Duration(minutes: i));
        final AccountEntity account = AccountEntity(
          id: 'acc-$i',
          name: 'Account $i',
          balanceMinor: BigInt.from(i),
          openingBalanceMinor: BigInt.from(i),
          currency: 'RUB',
          currencyScale: 2,
          type: 'checking',
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: updatedAt,
          isDeleted: false,
        );

        await outboxDao.enqueue(
          entityType: 'account',
          entityId: account.id,
          operation: OutboxOperation.upsert,
          payload: account.toJson()
            ..['updatedAt'] = updatedAt.toIso8601String()
            ..['createdAt'] = account.createdAt.toIso8601String()
            ..['balanceMinor'] = account.balanceMinor.toString()
            ..['openingBalanceMinor'] = account.openingBalanceMinor.toString()
            ..['currencyScale'] = 2,
        );
      }

      final AuthUser authUser = AuthUser(
        uid: userId,
        email: 'batch@kopim.app',
        displayName: 'Batch',
        photoUrl: null,
        isAnonymous: false,
        emailVerified: true,
        creationTime: DateTime.utc(2024, 1, 1),
        lastSignInTime: DateTime.utc(2024, 1, 2),
      );

      await service.synchronizeOnLogin(user: authUser, previousUser: null);

      final DocumentSnapshot<Map<String, dynamic>> lastRemoteDoc =
          await firestore
              .collection('users')
              .doc(userId)
              .collection('accounts')
              .doc('acc-500')
              .get();
      final List<AccountEntity> localAccounts = await accountDao
          .getAllAccounts();
      final List<db.OutboxEntryRow> pendingEntries = await outboxDao
          .fetchPending(limit: 10);

      expect(lastRemoteDoc.exists, isTrue);
      expect(lastRemoteDoc.data()?['id'], 'acc-500');
      expect(localAccounts, hasLength(501));
      expect(pendingEntries, isEmpty);
    });

    test('пересчитывает баланс после LWW merge на основе транзакций', () async {
      final AuthSyncService service = buildService();
      const String userId = 'user-2';
      final DateTime createdAt = DateTime.utc(2024, 1, 1);
      final DateTime updatedAt = DateTime.utc(2024, 1, 2);
      const int scale = 2;

      final AccountEntity localAccount = AccountEntity(
        id: 'acc-merge',
        name: 'Local',
        balanceMinor: BigInt.zero,
        openingBalanceMinor: BigInt.zero,
        currency: 'USD',
        currencyScale: scale,
        type: 'checking',
        createdAt: createdAt,
        updatedAt: createdAt,
        isDeleted: false,
      );
      await accountDao.upsert(localAccount);

      final DateTime txDate = DateTime.utc(2024, 1, 3);
      final TransactionEntity transaction = TransactionEntity(
        id: 'tx-1',
        accountId: localAccount.id,
        amountMinor: BigInt.from(10000),
        amountScale: scale,
        date: txDate,
        type: TransactionType.income.storageValue,
        createdAt: txDate,
        updatedAt: txDate,
      );
      await transactionDao.upsert(transaction);

      await firestore
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .doc(localAccount.id)
          .set(<String, dynamic>{
            'id': localAccount.id,
            'name': 'Remote',
            'balance': 0,
            'openingBalance': 0,
            'balanceMinor': '0',
            'openingBalanceMinor': '0',
            'currency': 'USD',
            'currencyScale': scale,
            'type': 'checking',
            'createdAt': Timestamp.fromDate(createdAt),
            'updatedAt': Timestamp.fromDate(updatedAt),
            'isDeleted': false,
          });

      final AuthUser authUser = AuthUser(
        uid: userId,
        email: 'user2@kopim.app',
        displayName: 'User2',
        photoUrl: null,
        isAnonymous: false,
        emailVerified: true,
        creationTime: createdAt,
        lastSignInTime: updatedAt,
      );

      await service.synchronizeOnLogin(user: authUser, previousUser: null);

      final List<AccountEntity> localAccounts = await accountDao
          .getAllAccounts();
      expect(localAccounts, hasLength(1));
      final AccountEntity merged = localAccounts.single;
      expect(merged.balanceAmount.toDouble(), closeTo(100, 1e-6));
      expect(merged.balanceMinor, BigInt.from(10000));
      expect(merged.openingBalanceMinor, BigInt.zero);
    });

    test(
      'restore через importData удаляет stale remote snapshot и не воскрешает его после login sync',
      () async {
        final AuthSyncService service = buildService();
        const String userId = 'user-restore-e2e';
        final DateTime staleTime = DateTime.utc(2024, 1, 5);
        final DateTime importedTime = DateTime.utc(2024, 2, 10);
        const int scale = 2;

        final AccountEntity staleAccount = AccountEntity(
          id: 'acc-stale',
          name: 'Old account',
          balanceMinor: BigInt.from(50000),
          openingBalanceMinor: BigInt.from(50000),
          currency: 'USD',
          currencyScale: scale,
          type: 'checking',
          createdAt: staleTime,
          updatedAt: staleTime,
        );
        final Category staleCategory = Category(
          id: 'cat-stale',
          name: 'Legacy',
          type: 'expense',
          createdAt: staleTime,
          updatedAt: staleTime,
        );
        final TagEntity staleTag = TagEntity(
          id: 'tag-stale',
          name: 'Old',
          color: '#111111',
          createdAt: staleTime,
          updatedAt: staleTime,
        );
        final TransactionEntity staleTransaction = TransactionEntity(
          id: 'tx-stale',
          accountId: staleAccount.id,
          categoryId: staleCategory.id,
          amountMinor: BigInt.from(1000),
          amountScale: scale,
          date: staleTime,
          type: TransactionType.expense.storageValue,
          createdAt: staleTime,
          updatedAt: staleTime,
        );
        final TransactionTagEntity staleTransactionTag = TransactionTagEntity(
          transactionId: staleTransaction.id,
          tagId: staleTag.id,
          createdAt: staleTime,
          updatedAt: staleTime,
        );
        final Budget staleBudget = Budget(
          id: 'budget-stale',
          title: 'Old budget',
          period: BudgetPeriod.monthly,
          startDate: DateTime.utc(2024, 1, 1),
          amountMinor: BigInt.from(25000),
          amountScale: scale,
          scope: BudgetScope.byCategory,
          categories: <String>[staleCategory.id],
          createdAt: staleTime,
          updatedAt: staleTime,
        );
        final BudgetInstance staleBudgetInstance = BudgetInstance(
          id: 'budget-instance-stale',
          budgetId: staleBudget.id,
          periodStart: DateTime.utc(2024, 1, 1),
          periodEnd: DateTime.utc(2024, 1, 31),
          amountMinor: BigInt.from(25000),
          spentMinor: BigInt.from(1000),
          amountScale: scale,
          status: BudgetInstanceStatus.active,
          createdAt: staleTime,
          updatedAt: staleTime,
        );
        final UpcomingPayment staleUpcomingPayment = UpcomingPayment(
          id: 'upcoming-stale',
          title: 'Old rent',
          accountId: staleAccount.id,
          categoryId: staleCategory.id,
          amountMinor: BigInt.from(30000),
          amountScale: scale,
          dayOfMonth: 10,
          notifyDaysBefore: 2,
          notifyTimeHhmm: '09:00',
          autoPost: false,
          isActive: true,
          createdAtMs: staleTime.millisecondsSinceEpoch,
          updatedAtMs: staleTime.millisecondsSinceEpoch,
        );
        final PaymentReminder staleReminder = PaymentReminder(
          id: 'reminder-stale',
          title: 'Old reminder',
          amountMinor: BigInt.from(5000),
          amountScale: scale,
          whenAtMs: staleTime.millisecondsSinceEpoch,
          isDone: false,
          createdAtMs: staleTime.millisecondsSinceEpoch,
          updatedAtMs: staleTime.millisecondsSinceEpoch,
        );

        await accountDao.upsert(staleAccount);
        await categoryDao.upsert(staleCategory);
        await tagDao.upsert(staleTag);
        await transactionDao.upsert(staleTransaction);
        await transactionTagsDao.upsert(staleTransactionTag);
        await budgetDao.upsert(staleBudget);
        await budgetInstanceDao.upsert(staleBudgetInstance);
        await upcomingPaymentsDao.upsert(staleUpcomingPayment);
        await paymentRemindersDao.upsert(staleReminder);

        await harness.seedRemoteSnapshot(
          userId: userId,
          accounts: <AccountEntity>[staleAccount],
          categories: <Category>[staleCategory],
          tags: <TagEntity>[staleTag],
          transactions: <TransactionEntity>[staleTransaction],
          transactionTags: <TransactionTagEntity>[staleTransactionTag],
          budgets: <Budget>[staleBudget],
          budgetInstances: <BudgetInstance>[staleBudgetInstance],
          upcomingPayments: <UpcomingPayment>[staleUpcomingPayment],
          paymentReminders: <PaymentReminder>[staleReminder],
        );

        final AccountEntity importedAccount = AccountEntity(
          id: 'acc-new',
          name: 'Imported account',
          balanceMinor: BigInt.from(120000),
          openingBalanceMinor: BigInt.from(120000),
          currency: 'USD',
          currencyScale: scale,
          type: 'checking',
          createdAt: importedTime,
          updatedAt: importedTime,
        );
        final Category importedCategory = Category(
          id: 'cat-new',
          name: 'Imported category',
          type: 'expense',
          createdAt: importedTime,
          updatedAt: importedTime,
        );
        final TagEntity importedTag = TagEntity(
          id: 'tag-new',
          name: 'Imported',
          color: '#00AA00',
          createdAt: importedTime,
          updatedAt: importedTime,
        );
        final TransactionEntity importedTransaction = TransactionEntity(
          id: 'tx-new',
          accountId: importedAccount.id,
          categoryId: importedCategory.id,
          amountMinor: BigInt.from(2000),
          amountScale: scale,
          date: importedTime,
          type: TransactionType.expense.storageValue,
          createdAt: importedTime,
          updatedAt: importedTime,
        );
        final TransactionTagEntity importedTransactionTag =
            TransactionTagEntity(
              transactionId: importedTransaction.id,
              tagId: importedTag.id,
              createdAt: importedTime,
              updatedAt: importedTime,
            );
        final Budget importedBudget = Budget(
          id: 'budget-new',
          title: 'Imported budget',
          period: BudgetPeriod.monthly,
          startDate: DateTime.utc(2024, 2, 1),
          amountMinor: BigInt.from(40000),
          amountScale: scale,
          scope: BudgetScope.byCategory,
          categories: <String>[importedCategory.id],
          createdAt: importedTime,
          updatedAt: importedTime,
        );
        final BudgetInstance importedBudgetInstance = BudgetInstance(
          id: 'budget-instance-new',
          budgetId: importedBudget.id,
          periodStart: DateTime.utc(2024, 2, 1),
          periodEnd: DateTime.utc(2024, 2, 29),
          amountMinor: BigInt.from(40000),
          spentMinor: BigInt.from(2000),
          amountScale: scale,
          status: BudgetInstanceStatus.active,
          createdAt: importedTime,
          updatedAt: importedTime,
        );
        final UpcomingPayment importedUpcomingPayment = UpcomingPayment(
          id: 'upcoming-new',
          title: 'Imported rent',
          accountId: importedAccount.id,
          categoryId: importedCategory.id,
          amountMinor: BigInt.from(80000),
          amountScale: scale,
          dayOfMonth: 15,
          notifyDaysBefore: 3,
          notifyTimeHhmm: '08:30',
          autoPost: true,
          isActive: true,
          createdAtMs: importedTime.millisecondsSinceEpoch,
          updatedAtMs: importedTime.millisecondsSinceEpoch,
        );
        final PaymentReminder importedReminder = PaymentReminder(
          id: 'reminder-new',
          title: 'Imported reminder',
          amountMinor: BigInt.from(7000),
          amountScale: scale,
          whenAtMs: importedTime.millisecondsSinceEpoch,
          isDone: false,
          createdAtMs: importedTime.millisecondsSinceEpoch,
          updatedAtMs: importedTime.millisecondsSinceEpoch,
        );

        await importRepository.importData(
          bundle: ExportBundle(
            schemaVersion: '1.7.0',
            generatedAt: importedTime,
            accounts: <AccountEntity>[importedAccount],
            categories: <Category>[importedCategory],
            tags: <TagEntity>[importedTag],
            transactionTags: <TransactionTagEntity>[importedTransactionTag],
            credits: const <CreditEntity>[],
            creditCards: const <CreditCardEntity>[],
            debts: const <DebtEntity>[],
            budgets: <Budget>[importedBudget],
            budgetInstances: <BudgetInstance>[importedBudgetInstance],
            upcomingPayments: <UpcomingPayment>[importedUpcomingPayment],
            paymentReminders: <PaymentReminder>[importedReminder],
            transactions: <TransactionEntity>[importedTransaction],
          ),
        );

        final AuthUser authUser = AuthUser(
          uid: userId,
          email: 'restore@kopim.app',
          displayName: 'Restore',
          photoUrl: null,
          isAnonymous: false,
          emailVerified: true,
          creationTime: staleTime,
          lastSignInTime: importedTime,
        );

        await service.synchronizeOnLogin(user: authUser, previousUser: null);

        await harness.expectActiveLocalIds(
          entityType: 'account',
          expected: <String>[importedAccount.id],
        );
        await harness.expectLocalTombstone(
          entityType: 'account',
          entityId: staleAccount.id,
        );
        await harness.expectActiveLocalIds(
          entityType: 'category',
          expected: <String>[importedCategory.id],
        );
        await harness.expectLocalTombstone(
          entityType: 'category',
          entityId: staleCategory.id,
        );
        await harness.expectActiveLocalIds(
          entityType: 'tag',
          expected: <String>[importedTag.id],
        );
        await harness.expectActiveLocalIds(
          entityType: 'transaction',
          expected: <String>[importedTransaction.id],
        );
        await harness.expectActiveLocalIds(
          entityType: 'transaction_tag',
          expected: <String>['${importedTransaction.id}::${importedTag.id}'],
        );
        await harness.expectActiveLocalIds(
          entityType: 'budget',
          expected: <String>[importedBudget.id],
        );
        expect(
          (await budgetInstanceDao.getByBudgetId(
            importedBudget.id,
          )).map((BudgetInstance e) => e.id),
          equals(<String>[importedBudgetInstance.id]),
        );
        expect(
          (await upcomingPaymentsDao.getAll())
              .where((UpcomingPayment e) => e.isActive)
              .map((UpcomingPayment e) => e.id),
          equals(<String>[importedUpcomingPayment.id]),
        );
        expect(
          (await paymentRemindersDao.getAll())
              .where((PaymentReminder e) => !e.isDone)
              .map((PaymentReminder e) => e.id),
          equals(<String>[importedReminder.id]),
        );

        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'account',
          entityId: staleAccount.id,
          field: 'isDeleted',
          expected: true,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'category',
          entityId: staleCategory.id,
          field: 'isDeleted',
          expected: true,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'tag',
          entityId: staleTag.id,
          field: 'isDeleted',
          expected: true,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'transaction',
          entityId: staleTransaction.id,
          field: 'isDeleted',
          expected: true,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'transaction_tag',
          entityId: '${staleTransaction.id}::${staleTag.id}',
          field: 'isDeleted',
          expected: true,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'budget',
          entityId: staleBudget.id,
          field: 'isDeleted',
          expected: true,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'budget_instance',
          entityId: staleBudgetInstance.id,
          field: 'deleted',
          expected: true,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'upcoming_payment',
          entityId: staleUpcomingPayment.id,
          field: 'isActive',
          expected: false,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'payment_reminder',
          entityId: staleReminder.id,
          field: 'isDone',
          expected: true,
        );

        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'account',
          entityId: importedAccount.id,
          field: 'isDeleted',
          expected: false,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'tag',
          entityId: importedTag.id,
          field: 'isDeleted',
          expected: false,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'budget_instance',
          entityId: importedBudgetInstance.id,
          field: 'deleted',
          expected: false,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'upcoming_payment',
          entityId: importedUpcomingPayment.id,
          field: 'isActive',
          expected: true,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'payment_reminder',
          entityId: importedReminder.id,
          field: 'isDone',
          expected: false,
        );

        expect(await outboxDao.pendingCount(), equals(1));
        final List<db.OutboxEntryRow> pendingEntries = await outboxDao
            .fetchPending(limit: 10);
        expect(pendingEntries, hasLength(1));
        expect(pendingEntries.single.entityType, equals('profile'));
      },
    );

    test(
      'restore через importData не затирает более новые remote версии и применяет более новые local версии',
      () async {
        final AuthSyncService service = buildService();
        const String userId = 'user-restore-conflict';
        const int scale = 2;
        final DateTime remoteOlder = DateTime.utc(2024, 1, 10);
        final DateTime importedOlder = DateTime.utc(2024, 2, 10);
        final DateTime remoteNewer = DateTime.utc(2024, 3, 10);
        final DateTime importedNewer = DateTime.utc(2024, 4, 10);

        final AccountEntity remoteAccount = AccountEntity(
          id: 'acc-conflict',
          name: 'Remote account',
          balanceMinor: BigInt.from(90000),
          openingBalanceMinor: BigInt.from(90000),
          currency: 'USD',
          currencyScale: scale,
          type: 'checking',
          createdAt: remoteOlder,
          updatedAt: remoteNewer,
        );
        final AccountEntity importedAccount = remoteAccount.copyWith(
          name: 'Imported account',
          balanceMinor: BigInt.from(70000),
          openingBalanceMinor: BigInt.from(70000),
          updatedAt: importedOlder,
        );

        final Category remoteCategory = Category(
          id: 'cat-conflict',
          name: 'Remote category',
          type: 'expense',
          createdAt: remoteOlder,
          updatedAt: remoteNewer,
        );
        final Category importedCategory = remoteCategory.copyWith(
          name: 'Imported category',
          updatedAt: importedOlder,
        );

        final TagEntity remoteTag = TagEntity(
          id: 'tag-conflict',
          name: 'Remote tag',
          color: '#999999',
          createdAt: remoteOlder,
          updatedAt: remoteOlder,
        );
        final TagEntity importedTag = remoteTag.copyWith(
          name: 'Imported tag',
          color: '#00AA00',
          updatedAt: importedNewer,
        );

        final TransactionEntity remoteTransaction = TransactionEntity(
          id: 'tx-conflict',
          accountId: remoteAccount.id,
          categoryId: remoteCategory.id,
          amountMinor: BigInt.from(9500),
          amountScale: scale,
          date: remoteNewer,
          type: TransactionType.expense.storageValue,
          createdAt: remoteOlder,
          updatedAt: remoteNewer,
        );
        final TransactionEntity importedTransaction = remoteTransaction
            .copyWith(
              amountMinor: BigInt.from(2100),
              date: importedOlder,
              updatedAt: importedOlder,
            );

        final TransactionTagEntity remoteTransactionTag = TransactionTagEntity(
          transactionId: remoteTransaction.id,
          tagId: remoteTag.id,
          createdAt: remoteOlder,
          updatedAt: remoteOlder,
        );
        final TransactionTagEntity importedTransactionTag = remoteTransactionTag
            .copyWith(updatedAt: importedNewer);

        final Budget remoteBudget = Budget(
          id: 'budget-conflict',
          title: 'Remote budget',
          period: BudgetPeriod.monthly,
          startDate: DateTime.utc(2024, 3, 1),
          amountMinor: BigInt.from(40000),
          amountScale: scale,
          scope: BudgetScope.byCategory,
          categories: <String>[remoteCategory.id],
          accounts: <String>[remoteAccount.id],
          createdAt: remoteOlder,
          updatedAt: remoteNewer,
        );
        final Budget importedBudget = remoteBudget.copyWith(
          title: 'Imported budget',
          amountMinor: BigInt.from(25000),
          updatedAt: importedOlder,
        );

        final BudgetInstance remoteBudgetInstance = BudgetInstance(
          id: 'budget-instance-conflict',
          budgetId: remoteBudget.id,
          periodStart: DateTime.utc(2024, 3, 1),
          periodEnd: DateTime.utc(2024, 3, 31),
          amountMinor: BigInt.from(40000),
          spentMinor: BigInt.from(12000),
          amountScale: scale,
          status: BudgetInstanceStatus.active,
          createdAt: remoteOlder,
          updatedAt: remoteNewer,
        );
        final BudgetInstance importedBudgetInstance = remoteBudgetInstance
            .copyWith(spentMinor: BigInt.from(1500), updatedAt: importedOlder);

        final UpcomingPayment remoteUpcomingPayment = UpcomingPayment(
          id: 'upcoming-conflict',
          title: 'Remote upcoming',
          accountId: remoteAccount.id,
          categoryId: remoteCategory.id,
          amountMinor: BigInt.from(60000),
          amountScale: scale,
          dayOfMonth: 5,
          notifyDaysBefore: 2,
          notifyTimeHhmm: '09:00',
          autoPost: false,
          isActive: true,
          createdAtMs: remoteOlder.millisecondsSinceEpoch,
          updatedAtMs: remoteOlder.millisecondsSinceEpoch,
        );
        final UpcomingPayment importedUpcomingPayment = remoteUpcomingPayment
            .copyWith(
              title: 'Imported upcoming',
              amountMinor: BigInt.from(88000),
              autoPost: true,
              updatedAtMs: importedNewer.millisecondsSinceEpoch,
            );

        final PaymentReminder remoteReminder = PaymentReminder(
          id: 'reminder-conflict',
          title: 'Remote reminder',
          amountMinor: BigInt.from(5000),
          amountScale: scale,
          whenAtMs: remoteNewer.millisecondsSinceEpoch,
          isDone: false,
          createdAtMs: remoteOlder.millisecondsSinceEpoch,
          updatedAtMs: remoteNewer.millisecondsSinceEpoch,
        );
        final PaymentReminder importedReminder = remoteReminder.copyWith(
          title: 'Imported reminder',
          amountMinor: BigInt.from(2000),
          updatedAtMs: importedOlder.millisecondsSinceEpoch,
        );

        await harness.seedRemoteSnapshot(
          userId: userId,
          accounts: <AccountEntity>[remoteAccount],
          categories: <Category>[remoteCategory],
          tags: <TagEntity>[remoteTag],
          transactions: <TransactionEntity>[remoteTransaction],
          transactionTags: <TransactionTagEntity>[remoteTransactionTag],
          budgets: <Budget>[remoteBudget],
          budgetInstances: <BudgetInstance>[remoteBudgetInstance],
          upcomingPayments: <UpcomingPayment>[remoteUpcomingPayment],
          paymentReminders: <PaymentReminder>[remoteReminder],
        );

        await importRepository.importData(
          bundle: ExportBundle(
            schemaVersion: '1.7.0',
            generatedAt: importedNewer,
            accounts: <AccountEntity>[importedAccount],
            categories: <Category>[importedCategory],
            tags: <TagEntity>[importedTag],
            transactionTags: <TransactionTagEntity>[importedTransactionTag],
            credits: const <CreditEntity>[],
            creditCards: const <CreditCardEntity>[],
            debts: const <DebtEntity>[],
            budgets: <Budget>[importedBudget],
            budgetInstances: <BudgetInstance>[importedBudgetInstance],
            upcomingPayments: <UpcomingPayment>[importedUpcomingPayment],
            paymentReminders: <PaymentReminder>[importedReminder],
            transactions: <TransactionEntity>[importedTransaction],
          ),
        );

        final AuthUser authUser = AuthUser(
          uid: userId,
          email: 'conflict@kopim.app',
          displayName: 'Conflict',
          photoUrl: null,
          isAnonymous: false,
          emailVerified: true,
          creationTime: remoteOlder,
          lastSignInTime: importedNewer,
        );

        await service.synchronizeOnLogin(user: authUser, previousUser: null);

        final AccountEntity mergedAccount = (await accountDao.getAllAccounts())
            .where((AccountEntity account) => !account.isDeleted)
            .single;
        expect(mergedAccount.name, equals(remoteAccount.name));
        expect(
          mergedAccount.updatedAt.isAtSameMomentAs(remoteAccount.updatedAt),
          isTrue,
        );

        final Category mergedCategory = (await categoryDao.getAllCategories())
            .where((Category category) => !category.isDeleted)
            .single;
        expect(mergedCategory.name, equals(remoteCategory.name));
        expect(
          mergedCategory.updatedAt.isAtSameMomentAs(remoteCategory.updatedAt),
          isTrue,
        );

        final TagEntity mergedTag = (await tagDao.getAllTags())
            .where((TagEntity tag) => !tag.isDeleted)
            .single;
        expect(mergedTag.name, equals(importedTag.name));
        expect(
          mergedTag.updatedAt.isAtSameMomentAs(importedTag.updatedAt),
          isTrue,
        );

        final TransactionEntity mergedTransaction =
            (await transactionDao.getAllTransactions())
                .where((TransactionEntity tx) => !tx.isDeleted)
                .single;
        expect(
          mergedTransaction.amountMinor,
          equals(remoteTransaction.amountMinor),
        );
        expect(
          mergedTransaction.updatedAt.isAtSameMomentAs(
            remoteTransaction.updatedAt,
          ),
          isTrue,
        );

        final TransactionTagEntity mergedTransactionTag =
            (await transactionTagsDao.getAllTransactionTags())
                .map(transactionTagsDao.mapRowToEntity)
                .where((TransactionTagEntity link) => !link.isDeleted)
                .single;
        expect(
          mergedTransactionTag.updatedAt.isAtSameMomentAs(
            importedTransactionTag.updatedAt,
          ),
          isTrue,
        );

        final Budget mergedBudget = (await budgetDao.getActiveBudgets()).single;
        expect(mergedBudget.title, equals(remoteBudget.title));
        expect(
          mergedBudget.updatedAt.isAtSameMomentAs(remoteBudget.updatedAt),
          isTrue,
        );

        final BudgetInstance mergedBudgetInstance =
            (await budgetInstanceDao.getByBudgetId(remoteBudget.id)).single;
        expect(
          mergedBudgetInstance.spentMinor,
          equals(remoteBudgetInstance.spentMinor),
        );
        expect(
          mergedBudgetInstance.updatedAt.isAtSameMomentAs(
            remoteBudgetInstance.updatedAt,
          ),
          isTrue,
        );

        final UpcomingPayment mergedUpcoming =
            (await upcomingPaymentsDao.getAll())
                .where((UpcomingPayment payment) => payment.isActive)
                .single;
        expect(mergedUpcoming.title, equals(importedUpcomingPayment.title));
        expect(
          mergedUpcoming.updatedAtMs,
          equals(importedUpcomingPayment.updatedAtMs),
        );

        final PaymentReminder mergedReminder =
            (await paymentRemindersDao.getAll())
                .where((PaymentReminder reminder) => !reminder.isDone)
                .single;
        expect(mergedReminder.title, equals(remoteReminder.title));
        expect(mergedReminder.updatedAtMs, equals(remoteReminder.updatedAtMs));

        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'account',
          entityId: remoteAccount.id,
          field: 'name',
          expected: remoteAccount.name,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'tag',
          entityId: remoteTag.id,
          field: 'name',
          expected: importedTag.name,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'transaction',
          entityId: remoteTransaction.id,
          field: 'amountMinor',
          expected: remoteTransaction.amountMinor.toString(),
        );
        expect(
          (await harness.fetchRemoteDocData(
            userId: userId,
            entityType: 'transaction_tag',
            entityId: '${remoteTransaction.id}::${remoteTag.id}',
          ))?['updatedAt'],
          isA<Timestamp>(),
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'budget',
          entityId: remoteBudget.id,
          field: 'title',
          expected: remoteBudget.title,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'upcoming_payment',
          entityId: remoteUpcomingPayment.id,
          field: 'title',
          expected: importedUpcomingPayment.title,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'payment_reminder',
          entityId: remoteReminder.id,
          field: 'title',
          expected: remoteReminder.title,
        );

        expect(await outboxDao.pendingCount(), equals(1));
      },
    );

    test(
      'merge local and remote accounts keeps higher typeVersion even when remote updatedAt is newer',
      () async {
        final AuthSyncService service = buildService();
        const String userId = 'user-account-type-merge';
        final DateTime localUpdatedAt = DateTime.utc(2024, 4, 1);
        final DateTime remoteUpdatedAt = DateTime.utc(2024, 5, 1);

        final AccountEntity localAccount = AccountEntity(
          id: 'acc-type',
          name: 'Local canonical',
          balanceMinor: BigInt.from(10000),
          openingBalanceMinor: BigInt.from(10000),
          currency: 'USD',
          currencyScale: 2,
          type: 'bank',
          typeVersion: 1,
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: localUpdatedAt,
        );
        final AccountEntity remoteAccount = localAccount.copyWith(
          name: 'Remote legacy',
          type: 'card',
          typeVersion: 0,
          updatedAt: remoteUpdatedAt,
        );

        await accountDao.upsert(localAccount);
        await harness.seedRemoteSnapshot(
          userId: userId,
          accounts: <AccountEntity>[remoteAccount],
        );

        await service.synchronizeOnLogin(
          user: AuthUser(
            uid: userId,
            email: 'type-merge@kopim.app',
            displayName: 'Type Merge',
            photoUrl: null,
            isAnonymous: false,
            emailVerified: true,
            creationTime: DateTime.utc(2024, 1, 1),
            lastSignInTime: DateTime.utc(2024, 5, 2),
          ),
        );

        final db.AccountRow merged =
            await (database.select(database.accounts)..where(
                  (db.$AccountsTable tbl) => tbl.id.equals(localAccount.id),
                ))
                .getSingle();
        expect(merged.name, 'Remote legacy');
        expect(merged.type, 'bank');
        expect(merged.typeVersion, 1);
        verify(
          () => harness.analytics.logEvent(
            'account_type_sync_observability',
            any(),
          ),
        ).called(1);
        final List<dynamic> loggerMessages = verify(
          () => harness.logger.logInfo(captureAny()),
        ).captured;
        expect(
          loggerMessages.any(
            (dynamic value) =>
                value.toString().contains('account type observability'),
          ),
          isTrue,
        );
      },
    );

    test(
      'remote legacy account is backfilled locally and propagated to remote in same sync',
      () async {
        final AuthSyncService service = buildService();
        const String userId = 'user-account-backfill';
        final AccountEntity remoteLegacy = AccountEntity(
          id: 'acc-legacy-only',
          name: 'Remote legacy card',
          balanceMinor: BigInt.from(25000),
          openingBalanceMinor: BigInt.from(25000),
          currency: 'USD',
          currencyScale: 2,
          type: 'card',
          typeVersion: 0,
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 6, 1),
        );

        await harness.seedRemoteSnapshot(
          userId: userId,
          accounts: <AccountEntity>[remoteLegacy],
        );

        await service.synchronizeOnLogin(
          user: AuthUser(
            uid: userId,
            email: 'backfill@kopim.app',
            displayName: 'Backfill',
            photoUrl: null,
            isAnonymous: false,
            emailVerified: true,
            creationTime: DateTime.utc(2024, 1, 1),
            lastSignInTime: DateTime.utc(2024, 6, 2),
          ),
        );

        final db.AccountRow localRow =
            await (database.select(database.accounts)..where(
                  (db.$AccountsTable tbl) => tbl.id.equals(remoteLegacy.id),
                ))
                .getSingle();
        expect(localRow.type, 'bank');
        expect(localRow.typeVersion, 1);

        final Map<String, dynamic>? remoteData = await harness
            .fetchRemoteDocData(
              userId: userId,
              entityType: 'account',
              entityId: remoteLegacy.id,
            );
        expect(remoteData, isNotNull);
        expect(remoteData!['type'], 'bank');
        expect(remoteData['typeVersion'], 1);

        verify(
          () => harness.analytics.logEvent(
            'account_type_backfill_sync_propagation',
            any(),
          ),
        ).called(1);
      },
    );

    test(
      'stale outbox account payload does not overwrite remote canonical typeVersion',
      () async {
        final AuthSyncService service = buildService();
        const String userId = 'user-account-type-outbox';
        final AccountEntity remoteAccount = AccountEntity(
          id: 'acc-type-outbox',
          name: 'Remote canonical',
          balanceMinor: BigInt.from(15000),
          openingBalanceMinor: BigInt.from(15000),
          currency: 'USD',
          currencyScale: 2,
          type: 'bank',
          typeVersion: 1,
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 5, 1),
        );
        final AccountEntity staleLocal = remoteAccount.copyWith(
          name: 'Local legacy',
          type: 'card',
          typeVersion: 0,
          updatedAt: DateTime.utc(2024, 5, 2),
        );

        await harness.seedRemoteSnapshot(
          userId: userId,
          accounts: <AccountEntity>[remoteAccount],
        );
        await outboxDao.enqueue(
          entityType: 'account',
          entityId: staleLocal.id,
          operation: OutboxOperation.upsert,
          payload: staleLocal.toJson()
            ..['updatedAt'] = staleLocal.updatedAt.toIso8601String()
            ..['createdAt'] = staleLocal.createdAt.toIso8601String()
            ..['balanceMinor'] = staleLocal.balanceMinor.toString()
            ..['openingBalanceMinor'] = staleLocal.openingBalanceMinor
                .toString()
            ..['currencyScale'] = staleLocal.currencyScale
            ..['typeVersion'] = staleLocal.typeVersion,
        );

        await service.synchronizeOnLogin(
          user: AuthUser(
            uid: userId,
            email: 'type-outbox@kopim.app',
            displayName: 'Type Outbox',
            photoUrl: null,
            isAnonymous: false,
            emailVerified: true,
            creationTime: DateTime.utc(2024, 1, 1),
            lastSignInTime: DateTime.utc(2024, 5, 3),
          ),
        );

        final Map<String, dynamic>? remoteData = await harness
            .fetchRemoteDocData(
              userId: userId,
              entityType: 'account',
              entityId: remoteAccount.id,
            );
        expect(remoteData, isNotNull);
        expect(remoteData!['type'], 'bank');
        expect(remoteData['typeVersion'], 1);

        final db.AccountRow localRow =
            await (database.select(database.accounts)..where(
                  (db.$AccountsTable tbl) => tbl.id.equals(remoteAccount.id),
                ))
                .getSingle();
        expect(localRow.type, 'bank');
        expect(localRow.typeVersion, 1);
        verify(
          () => harness.analytics.logEvent(
            'account_type_rollback_prevented',
            any(),
          ),
        ).called(1);
        final List<dynamic> loggerMessages = verify(
          () => harness.logger.logInfo(captureAny()),
        ).captured;
        expect(
          loggerMessages.any(
            (dynamic value) =>
                value.toString().contains('prevented legacy rollback'),
          ),
          isTrue,
        );
      },
    );

    test(
      'restore через importData удаляет stale saving goal и синхронизирует импортированную цель',
      () async {
        final AuthSyncService service = buildService();
        const String userId = 'user-saving-goal-restore';
        final DateTime staleTime = DateTime.utc(2024, 1, 15);
        final DateTime importedTime = DateTime.utc(2024, 2, 15);

        final AccountEntity account = AccountEntity(
          id: 'acc-goal',
          name: 'Goal account',
          balanceMinor: BigInt.from(50000),
          openingBalanceMinor: BigInt.from(50000),
          currency: 'USD',
          currencyScale: 2,
          type: 'checking',
          createdAt: staleTime,
          updatedAt: staleTime,
        );
        final AccountEntity sharedStorageAccount = AccountEntity(
          id: 'acc-goal-shared',
          name: 'Shared storage',
          balanceMinor: BigInt.from(25000),
          openingBalanceMinor: BigInt.from(25000),
          currency: 'USD',
          currencyScale: 2,
          type: 'checking',
          createdAt: staleTime,
          updatedAt: staleTime,
        );
        final Category category = Category(
          id: 'cat-goal',
          name: 'Goal category',
          type: 'expense',
          createdAt: staleTime,
          updatedAt: staleTime,
        );
        final SavingGoal staleGoal = SavingGoal(
          id: 'goal-stale',
          userId: userId,
          name: 'Old goal',
          accountId: account.id,
          targetAmount: 100000,
          currentAmount: 5000,
          createdAt: staleTime,
          updatedAt: staleTime,
        );
        final SavingGoal importedGoal = SavingGoal(
          id: 'goal-imported',
          userId: userId,
          name: 'Imported goal',
          accountId: account.id,
          storageAccountIds: const <String>['acc-goal', 'acc-goal-shared'],
          targetAmount: 200000,
          currentAmount: 15000,
          createdAt: importedTime,
          updatedAt: importedTime,
        );
        final Profile remoteProfile = Profile(
          uid: userId,
          name: 'Remote user',
          currency: ProfileCurrency.usd,
          locale: 'en',
          updatedAt: importedTime,
        );

        await accountDao.upsert(account);
        await accountDao.upsert(sharedStorageAccount);
        await categoryDao.upsert(category);
        await harness.savingGoalDao.upsert(staleGoal);

        await harness.seedRemoteSnapshot(
          userId: userId,
          accounts: <AccountEntity>[account, sharedStorageAccount],
          categories: <Category>[category],
          savingGoals: <SavingGoal>[staleGoal],
        );
        await harness.seedRemoteProfile(userId: userId, profile: remoteProfile);

        await importRepository.importData(
          bundle: ExportBundle(
            schemaVersion: '1.7.0',
            generatedAt: importedTime,
            accounts: <AccountEntity>[
              account.copyWith(updatedAt: importedTime),
              sharedStorageAccount.copyWith(updatedAt: importedTime),
            ],
            categories: <Category>[category.copyWith(updatedAt: importedTime)],
            savingGoals: <SavingGoal>[importedGoal],
            transactions: const <TransactionEntity>[],
          ),
        );

        final AuthUser authUser = AuthUser(
          uid: userId,
          email: 'goal@kopim.app',
          displayName: 'Goal user',
          photoUrl: null,
          isAnonymous: false,
          emailVerified: true,
          creationTime: staleTime,
          lastSignInTime: importedTime,
        );

        await service.synchronizeOnLogin(user: authUser, previousUser: null);

        await harness.expectActiveLocalIds(
          entityType: 'saving_goal',
          expected: <String>[importedGoal.id],
        );
        expect(
          (await harness.savingGoalDao.findById(importedGoal.id))?.name,
          equals(importedGoal.name),
        );
        expect(
          await harness.goalAccountLinkDao.findAccountIdsByGoalId(
            importedGoal.id,
          ),
          <String>['acc-goal', 'acc-goal-shared'],
        );
        expect(
          await harness.fetchRemoteDocData(
            userId: userId,
            entityType: 'saving_goal',
            entityId: staleGoal.id,
          ),
          isNull,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'saving_goal',
          entityId: importedGoal.id,
          field: 'name',
          expected: importedGoal.name,
        );
        expect(await outboxDao.pendingCount(), isZero);
      },
    );

    test(
      'profile sync сохраняет более новый remote profile и игнорирует устаревший local outbox',
      () async {
        final AuthSyncService service = buildService();
        const String userId = 'user-profile-lww';
        final DateTime localTime = DateTime.utc(2024, 2, 1);
        final DateTime remoteTime = DateTime.utc(2024, 3, 1);

        final Profile localProfile = Profile(
          uid: userId,
          name: 'Local old',
          currency: ProfileCurrency.rub,
          locale: 'ru',
          updatedAt: localTime,
        );
        final Profile remoteProfile = Profile(
          uid: userId,
          name: 'Remote new',
          currency: ProfileCurrency.eur,
          locale: 'de',
          updatedAt: remoteTime,
        );

        await profileDao.upsert(localProfile);
        await harness.seedRemoteProfile(userId: userId, profile: remoteProfile);
        await outboxDao.enqueue(
          entityType: 'profile',
          entityId: userId,
          operation: OutboxOperation.upsert,
          payload: <String, dynamic>{
            'uid': userId,
            'name': localProfile.name,
            'currency': localProfile.currency.name,
            'locale': localProfile.locale,
            'updatedAt': localProfile.updatedAt.toIso8601String(),
          },
        );

        final AuthUser authUser = AuthUser(
          uid: userId,
          email: 'profile@kopim.app',
          displayName: 'Ignored fallback',
          photoUrl: null,
          isAnonymous: false,
          emailVerified: true,
          creationTime: localTime,
          lastSignInTime: remoteTime,
        );

        await service.synchronizeOnLogin(user: authUser, previousUser: null);

        final Profile? storedProfile = await harness.fetchLocalProfile(userId);
        expect(storedProfile, isNotNull);
        expect(storedProfile!.name, equals(remoteProfile.name));
        expect(storedProfile.currency, equals(ProfileCurrency.eur));
        expect(storedProfile.locale, equals(remoteProfile.locale));
        expect(
          storedProfile.updatedAt.isAtSameMomentAs(remoteProfile.updatedAt),
          isTrue,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'profile',
          entityId: userId,
          field: 'name',
          expected: remoteProfile.name,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'profile',
          entityId: userId,
          field: 'currency',
          expected: 'EUR',
        );
        expect(await outboxDao.pendingCount(), isZero);
      },
    );

    test(
      'profile sync создает fallback profile и ставит один pending upsert когда profile отсутствует',
      () async {
        final AuthSyncService service = buildService();
        const String userId = 'user-profile-fallback';
        final DateTime signInTime = DateTime.utc(2024, 4, 1);

        final AuthUser authUser = AuthUser(
          uid: userId,
          email: 'fallback@kopim.app',
          displayName: 'Fallback Name',
          photoUrl: null,
          isAnonymous: false,
          emailVerified: true,
          creationTime: signInTime,
          lastSignInTime: signInTime,
        );

        await service.synchronizeOnLogin(user: authUser, previousUser: null);

        final Profile? storedProfile = await harness.fetchLocalProfile(userId);
        expect(storedProfile, isNotNull);
        expect(storedProfile!.name, equals('Fallback Name'));
        expect(storedProfile.locale, isNotEmpty);

        expect(
          await harness.fetchRemoteDocData(
            userId: userId,
            entityType: 'profile',
            entityId: userId,
          ),
          isNull,
        );

        expect(await outboxDao.pendingCount(), equals(1));
        final List<db.OutboxEntryRow> pendingEntries = await outboxDao
            .fetchPending(limit: 10);
        expect(pendingEntries, hasLength(1));
        expect(pendingEntries.single.entityType, equals('profile'));
      },
    );

    test(
      'restore через importData удаляет stale liability snapshot и синхронизирует импортированные liabilities',
      () async {
        final AuthSyncService service = buildService();
        const String userId = 'user-liability-restore';
        const int scale = 2;
        final DateTime staleTime = DateTime.utc(2024, 1, 20);
        final DateTime importedTime = DateTime.utc(2024, 2, 20);

        final AccountEntity account = AccountEntity(
          id: 'acc-liability',
          name: 'Liability account',
          balanceMinor: BigInt.from(200000),
          openingBalanceMinor: BigInt.from(200000),
          currency: 'USD',
          currencyScale: scale,
          type: 'checking',
          createdAt: staleTime,
          updatedAt: staleTime,
        );
        final Category category = Category(
          id: 'cat-liability',
          name: 'Liability category',
          type: 'expense',
          createdAt: staleTime,
          updatedAt: staleTime,
        );
        final CreditEntity staleCredit = CreditEntity(
          id: 'credit-stale',
          accountId: account.id,
          categoryId: category.id,
          totalAmountMinor: BigInt.from(300000),
          totalAmountScale: scale,
          interestRate: 12.5,
          termMonths: 12,
          startDate: staleTime,
          paymentDay: 5,
          createdAt: staleTime,
          updatedAt: staleTime,
        );
        final CreditCardEntity staleCard = CreditCardEntity(
          id: 'card-stale',
          accountId: account.id,
          creditLimitMinor: BigInt.from(150000),
          creditLimitScale: scale,
          statementDay: 1,
          paymentDueDays: 20,
          interestRateAnnual: 29.9,
          createdAt: staleTime,
          updatedAt: staleTime,
        );
        final DebtEntity staleDebt = DebtEntity(
          id: 'debt-stale',
          accountId: account.id,
          name: 'Old debt',
          amountMinor: BigInt.from(50000),
          amountScale: scale,
          dueDate: staleTime.add(const Duration(days: 30)),
          createdAt: staleTime,
          updatedAt: staleTime,
        );

        final CreditEntity importedCredit = staleCredit.copyWith(
          id: 'credit-imported',
          totalAmountMinor: BigInt.from(450000),
          createdAt: importedTime,
          updatedAt: importedTime,
        );
        final CreditCardEntity importedCard = staleCard.copyWith(
          id: 'card-imported',
          creditLimitMinor: BigInt.from(250000),
          createdAt: importedTime,
          updatedAt: importedTime,
        );
        final DebtEntity importedDebt = staleDebt.copyWith(
          id: 'debt-imported',
          name: 'Imported debt',
          amountMinor: BigInt.from(90000),
          dueDate: importedTime.add(const Duration(days: 45)),
          createdAt: importedTime,
          updatedAt: importedTime,
        );

        await accountDao.upsert(account);
        await categoryDao.upsert(category);
        await harness.creditDao.upsert(staleCredit);
        await harness.creditCardDao.upsert(staleCard);
        await harness.debtDao.upsert(staleDebt);

        await harness.seedRemoteSnapshot(
          userId: userId,
          accounts: <AccountEntity>[account],
          categories: <Category>[category],
          credits: <CreditEntity>[staleCredit],
          creditCards: <CreditCardEntity>[staleCard],
          debts: <DebtEntity>[staleDebt],
        );
        await harness.seedRemoteProfile(
          userId: userId,
          profile: Profile(
            uid: userId,
            name: 'Remote liability user',
            currency: ProfileCurrency.usd,
            locale: 'en',
            updatedAt: importedTime,
          ),
        );

        await importRepository.importData(
          bundle: ExportBundle(
            schemaVersion: '1.7.0',
            generatedAt: importedTime,
            accounts: <AccountEntity>[
              account.copyWith(updatedAt: importedTime),
            ],
            categories: <Category>[category.copyWith(updatedAt: importedTime)],
            savingGoals: const <SavingGoal>[],
            credits: <CreditEntity>[importedCredit],
            creditCards: <CreditCardEntity>[importedCard],
            debts: <DebtEntity>[importedDebt],
            transactions: const <TransactionEntity>[],
          ),
        );

        final AuthUser authUser = AuthUser(
          uid: userId,
          email: 'liability@kopim.app',
          displayName: 'Liability user',
          photoUrl: null,
          isAnonymous: false,
          emailVerified: true,
          creationTime: staleTime,
          lastSignInTime: importedTime,
        );

        await service.synchronizeOnLogin(user: authUser, previousUser: null);

        await harness.expectActiveLocalIds(
          entityType: 'credit',
          expected: <String>[importedCredit.id],
        );
        await harness.expectActiveLocalIds(
          entityType: 'credit_card',
          expected: <String>[importedCard.id],
        );
        await harness.expectActiveLocalIds(
          entityType: 'debt',
          expected: <String>[importedDebt.id],
        );
        await harness.expectLocalTombstone(
          entityType: 'credit',
          entityId: staleCredit.id,
        );
        await harness.expectLocalTombstone(
          entityType: 'credit_card',
          entityId: staleCard.id,
        );
        await harness.expectLocalTombstone(
          entityType: 'debt',
          entityId: staleDebt.id,
        );

        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'credit',
          entityId: staleCredit.id,
          field: 'isDeleted',
          expected: true,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'credit_card',
          entityId: staleCard.id,
          field: 'isDeleted',
          expected: true,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'debt',
          entityId: staleDebt.id,
          field: 'isDeleted',
          expected: true,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'credit',
          entityId: importedCredit.id,
          field: 'isDeleted',
          expected: false,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'credit_card',
          entityId: importedCard.id,
          field: 'isDeleted',
          expected: false,
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'debt',
          entityId: importedDebt.id,
          field: 'isDeleted',
          expected: false,
        );
        expect(await outboxDao.pendingCount(), isZero);
      },
    );

    test(
      'liability sync не затирает более новые remote версии и применяет более новые local версии',
      () async {
        final AuthSyncService service = buildService();
        const String userId = 'user-liability-conflict';
        const int scale = 2;
        final DateTime older = DateTime.utc(2024, 2, 1);
        final DateTime remoteNewer = DateTime.utc(2024, 4, 1);
        final DateTime importedNewer = DateTime.utc(2024, 5, 1);

        final AccountEntity account = AccountEntity(
          id: 'acc-liability-conflict',
          name: 'Conflict account',
          balanceMinor: BigInt.from(400000),
          openingBalanceMinor: BigInt.from(400000),
          currency: 'USD',
          currencyScale: scale,
          type: 'checking',
          createdAt: older,
          updatedAt: older,
        );
        final Category category = Category(
          id: 'cat-liability-conflict',
          name: 'Conflict category',
          type: 'expense',
          createdAt: older,
          updatedAt: older,
        );

        final CreditEntity remoteCredit = CreditEntity(
          id: 'credit-conflict',
          accountId: account.id,
          categoryId: category.id,
          totalAmountMinor: BigInt.from(600000),
          totalAmountScale: scale,
          interestRate: 10,
          termMonths: 24,
          startDate: older,
          paymentDay: 10,
          createdAt: older,
          updatedAt: remoteNewer,
        );
        final CreditEntity importedCredit = remoteCredit.copyWith(
          totalAmountMinor: BigInt.from(450000),
          updatedAt: older,
        );

        final CreditCardEntity remoteCard = CreditCardEntity(
          id: 'card-conflict',
          accountId: account.id,
          creditLimitMinor: BigInt.from(100000),
          creditLimitScale: scale,
          statementDay: 3,
          paymentDueDays: 25,
          interestRateAnnual: 24,
          createdAt: older,
          updatedAt: older,
        );
        final CreditCardEntity importedCard = remoteCard.copyWith(
          creditLimitMinor: BigInt.from(220000),
          updatedAt: importedNewer,
        );

        final DebtEntity remoteDebt = DebtEntity(
          id: 'debt-conflict',
          accountId: account.id,
          name: 'Remote debt',
          amountMinor: BigInt.from(80000),
          amountScale: scale,
          dueDate: older.add(const Duration(days: 20)),
          createdAt: older,
          updatedAt: remoteNewer,
        );
        final DebtEntity importedDebt = remoteDebt.copyWith(
          name: 'Imported debt',
          amountMinor: BigInt.from(50000),
          updatedAt: older,
        );

        await harness.seedRemoteSnapshot(
          userId: userId,
          accounts: <AccountEntity>[account],
          categories: <Category>[category],
          credits: <CreditEntity>[remoteCredit],
          creditCards: <CreditCardEntity>[remoteCard],
          debts: <DebtEntity>[remoteDebt],
        );

        await importRepository.importData(
          bundle: ExportBundle(
            schemaVersion: '1.7.0',
            generatedAt: importedNewer,
            accounts: <AccountEntity>[
              account.copyWith(updatedAt: importedNewer),
            ],
            categories: <Category>[category.copyWith(updatedAt: importedNewer)],
            savingGoals: const <SavingGoal>[],
            credits: <CreditEntity>[importedCredit],
            creditCards: <CreditCardEntity>[importedCard],
            debts: <DebtEntity>[importedDebt],
            transactions: const <TransactionEntity>[],
          ),
        );

        final AuthUser authUser = AuthUser(
          uid: userId,
          email: 'liability-conflict@kopim.app',
          displayName: 'Liability conflict',
          photoUrl: null,
          isAnonymous: false,
          emailVerified: true,
          creationTime: older,
          lastSignInTime: importedNewer,
        );

        await service.synchronizeOnLogin(user: authUser, previousUser: null);

        final CreditEntity mergedCredit = harness.creditDao.mapRowToEntity(
          (await harness.creditDao.getAllCredits()).single,
        );
        expect(
          mergedCredit.totalAmountMinor,
          equals(remoteCredit.totalAmountMinor),
        );
        expect(
          mergedCredit.updatedAt.isAtSameMomentAs(remoteCredit.updatedAt),
          isTrue,
        );

        final CreditCardEntity mergedCard = harness.creditCardDao
            .mapRowToEntity(
              (await harness.creditCardDao.getAllCreditCards()).single,
            );
        expect(
          mergedCard.creditLimitMinor,
          equals(importedCard.creditLimitMinor),
        );
        expect(
          mergedCard.updatedAt.isAtSameMomentAs(importedCard.updatedAt),
          isTrue,
        );

        final DebtEntity mergedDebt = harness.debtDao.mapRowToEntity(
          (await harness.debtDao.getAllDebts()).single,
        );
        expect(mergedDebt.name, equals(remoteDebt.name));
        expect(
          mergedDebt.updatedAt.isAtSameMomentAs(remoteDebt.updatedAt),
          isTrue,
        );

        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'credit',
          entityId: remoteCredit.id,
          field: 'totalAmountMinor',
          expected: remoteCredit.totalAmountMinor.toString(),
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'credit_card',
          entityId: remoteCard.id,
          field: 'creditLimitMinor',
          expected: importedCard.creditLimitMinor.toString(),
        );
        await harness.expectRemoteFieldEquals(
          userId: userId,
          entityType: 'debt',
          entityId: remoteDebt.id,
          field: 'name',
          expected: remoteDebt.name,
        );
        expect(await outboxDao.pendingCount(), equals(1));
      },
    );

    test(
      'replays legacy category outbox payload with string icon descriptor',
      () async {
        final AuthSyncService service = buildService();
        const String userId = 'user-legacy';

        await outboxDao.enqueue(
          entityType: 'category',
          entityId: 'cat-1',
          operation: OutboxOperation.upsert,
          payload: <String, dynamic>{
            'id': 'cat-1',
            'name': 'Food',
            'type': 'expense',
            'icon': 'bowl-food',
            'iconStyle': 'BOLD',
            'color': '#FF0000',
            'createdAt': '2023-01-01T00:00:00.000Z',
            'updatedAt': '2023-01-02T00:00:00.000Z',
            'isDeleted': false,
          },
        );

        final AuthUser authUser = AuthUser(
          uid: userId,
          isAnonymous: false,
          emailVerified: true,
          creationTime: DateTime.utc(2023, 1, 1),
          lastSignInTime: DateTime.utc(2023, 1, 2),
        );

        await service.synchronizeOnLogin(user: authUser, previousUser: null);

        final DocumentSnapshot<Map<String, dynamic>> remoteCategoryDoc =
            await firestore
                .collection('users')
                .doc(userId)
                .collection('categories')
                .doc('cat-1')
                .get();

        expect(remoteCategoryDoc.exists, isTrue);
        final Map<String, dynamic>? remoteData = remoteCategoryDoc.data();
        expect(remoteData?['iconDescriptor'], isA<Map<String, dynamic>>());
        final Map<String, dynamic> descriptor =
            (remoteData?['iconDescriptor'] as Map<String, dynamic>?) ??
            const <String, dynamic>{};
        expect(descriptor['name'], equals('bowl-food'));
        expect(descriptor['style'], equals('bold'));

        final List<Category> storedCategories = await categoryDao
            .getAllCategories();
        expect(storedCategories, hasLength(1));
        expect(storedCategories.single.icon?.name, equals('bowl-food'));
        expect(
          storedCategories.single.icon?.style,
          equals(PhosphorIconStyle.bold),
        );

        expect(await outboxDao.pendingCount(), equals(1));
        final List<db.OutboxEntryRow> pendingEntries = await outboxDao
            .fetchPending(limit: 10);
        expect(pendingEntries, hasLength(1));
        expect(pendingEntries.single.entityType, equals('profile'));
      },
    );

    test('нормализует связь родителя категории после дедупликации', () async {
      final AuthSyncService service = buildService();
      const String userId = 'user-category-conflict';

      final Category legacyParent = Category(
        id: 'cat-legacy',
        name: 'Food Legacy',
        type: 'expense',
        createdAt: DateTime.utc(2023, 1, 1),
        updatedAt: DateTime.utc(2023, 2, 1),
      );
      final Category child = Category(
        id: 'cat-child',
        name: 'Restaurants',
        type: 'expense',
        parentId: legacyParent.id,
        createdAt: DateTime.utc(2023, 1, 5),
        updatedAt: DateTime.utc(2023, 2, 5),
      );

      await categoryDao.upsertAll(<Category>[legacyParent, child]);

      final Category remoteLegacy = legacyParent.copyWith(
        name: 'Food',
        updatedAt: DateTime.utc(2023, 2, 2),
      );
      final Category canonicalParent = remoteLegacy.copyWith(
        id: 'cat-canonical',
        updatedAt: DateTime.utc(2024, 3, 1),
      );
      final CategoryRemoteDataSource categoryRemoteDataSource =
          CategoryRemoteDataSource(firestore);
      await categoryRemoteDataSource.upsert(userId, remoteLegacy);
      await categoryRemoteDataSource.upsert(userId, canonicalParent);

      final AuthUser authUser = AuthUser(
        uid: userId,
        isAnonymous: false,
        emailVerified: true,
        creationTime: DateTime.utc(2024, 1, 1),
        lastSignInTime: DateTime.utc(2024, 1, 2),
      );

      await service.synchronizeOnLogin(user: authUser, previousUser: null);

      final List<Category> storedCategories = await categoryDao
          .getAllCategories();
      final Category storedChild = storedCategories.firstWhere(
        (Category category) => category.id == child.id,
      );
      expect(storedChild.parentId, equals(canonicalParent.id));

      final Category storedCanonical = storedCategories.firstWhere(
        (Category category) => category.id == canonicalParent.id,
      );
      expect(storedCanonical.parentId, isNull);
    });

    test('resets outbox entries when transaction fails', () async {
      final ThrowingAccountRemoteDataSource throwingDataSource =
          ThrowingAccountRemoteDataSource(firestore);
      final AuthSyncService service = buildService(
        accountRemoteDataSource: throwingDataSource,
      );
      const String userId = 'user-2';

      final AccountEntity account = AccountEntity(
        id: 'acc-2',
        name: 'Savings',
        balanceMinor: BigInt.from(20000),
        currency: 'RUB',
        currencyScale: 2,
        type: 'savings',
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 5),
        isDeleted: false,
      );

      await outboxDao.enqueue(
        entityType: 'account',
        entityId: account.id,
        operation: OutboxOperation.upsert,
        payload: account.toJson()
          ..['updatedAt'] = account.updatedAt.toIso8601String()
          ..['createdAt'] = account.createdAt.toIso8601String(),
      );

      final AuthUser authUser = AuthUser(
        uid: userId,
        isAnonymous: false,
        emailVerified: true,
        creationTime: DateTime.utc(2024, 1, 1),
        lastSignInTime: DateTime.utc(2024, 1, 2),
      );

      expect(
        () => service.synchronizeOnLogin(user: authUser, previousUser: null),
        throwsA(isA<AuthFailure>()),
      );

      final List<db.OutboxEntryRow> entries = await database
          .select(database.outboxEntries)
          .get();
      expect(entries, hasLength(1));
      expect(entries.single.status, equals(OutboxStatus.pending.name));
    });
  });
}
