import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/services/auth_sync_service.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'support/auth_sync_test_harness.dart';

void main() {
  late AuthSyncTestHarness harness;
  late TransactionDao transactionDao;
  late FirebaseFirestore firestore;

  setUp(() async {
    harness = AuthSyncTestHarness();
    await harness.setUp();
    transactionDao = harness.transactionDao;
    firestore = harness.firestore;
  });

  tearDown(() async {
    await harness.tearDown();
  });

  test(
    'Should reproduce FK error when transaction is synced before its saving goal',
    () async {
      // With the FIX enabled (sanitizer + reordering), this test should actually PASS now,
      // or fail differently if we want to confirm the fix works.
      // The original user intent was to REPRODUCE the error.
      // But now that we implemented the fix, we expect it to NOT THROW.
      // Wait, the reproduction test was designed to fail.
      // Now I should update it to expect SUCCESS because I expect my code to fix it.

      final AuthSyncService service = harness.buildService();

      const String userId = 'user-repro';
      const String accountId = 'acc_1';
      const String categoryId = 'cat_1';
      const String savingGoalId = 'goal_1';

      // 1. Setup remote data
      final DateTime now = DateTime.utc(2025, 1, 1);
      final AccountEntity account = AccountEntity(
        id: accountId,
        name: 'Account',
        balanceMinor: BigInt.from(100000),
        currency: 'RUB',
        currencyScale: 2,
        type: 'checking',
        createdAt: now,
        updatedAt: now,
      );
      final Category category = Category(
        id: categoryId,
        name: 'Category',
        type: 'expense',
        createdAt: now,
        updatedAt: now,
      );
      final SavingGoal savingGoal = SavingGoal(
        id: savingGoalId,
        userId: userId,
        name: 'Goal',
        targetAmount: 10000,
        currentAmount: 0,
        createdAt: now,
        updatedAt: now,
      );
      final TransactionEntity transaction = TransactionEntity(
        id: 'tx-1',
        accountId: accountId,
        categoryId: categoryId,
        savingGoalId: savingGoalId,
        amountMinor: BigInt.from(10000),
        amountScale: 2,
        date: now,
        type: 'expense',
        createdAt: now,
        updatedAt: now,
      );

      // Write to fake firestore
      final DocumentReference<Map<String, dynamic>> userRef = firestore
          .collection('users')
          .doc(userId);
      await userRef
          .collection('accounts')
          .doc(accountId)
          .set(
            account.toJson()
              ..['updatedAt'] = Timestamp.fromDate(account.updatedAt)
              ..['createdAt'] = Timestamp.fromDate(account.createdAt),
          );
      await userRef
          .collection('categories')
          .doc(categoryId)
          .set(
            category.toJson()
              ..['updatedAt'] = Timestamp.fromDate(category.updatedAt)
              ..['createdAt'] = Timestamp.fromDate(category.createdAt),
          );
      await userRef
          .collection('saving_goals')
          .doc(savingGoalId)
          .set(
            savingGoal.toJson()
              ..['updatedAt'] = Timestamp.fromDate(savingGoal.updatedAt)
              ..['createdAt'] = Timestamp.fromDate(savingGoal.createdAt),
          );
      await userRef
          .collection('transactions')
          .doc(transaction.id)
          .set(
            transaction.toJson()
              ..['updatedAt'] = Timestamp.fromDate(transaction.updatedAt)
              ..['createdAt'] = Timestamp.fromDate(transaction.createdAt),
          );

      final AuthUser authUser = AuthUser(
        uid: userId,
        isAnonymous: false,
        emailVerified: true,
        creationTime: DateTime.now(),
        lastSignInTime: DateTime.now(),
      );

      // This previously failed. Now it should succeed.
      await service.synchronizeOnLogin(user: authUser);

      final db.TransactionRow? savedTx = await transactionDao.findById(
        transaction.id,
      );
      expect(savedTx, isNotNull);
      expect(savedTx?.savingGoalId, savingGoalId);
    },
  );

  test('Should sanitize transaction when saving goal is missing', () async {
    final AuthSyncService service = harness.buildService();

    const String userId = 'user-sanitize';
    const String accId = 'acc-2';
    const String catId = 'cat-2';
    const String goalId = 'goal-missing';

    // 1. Setup remote data WITHOUT the goal
    final DateTime now = DateTime.now().toUtc();
    final AccountEntity account = AccountEntity(
      id: accId,
      name: 'Account',
      balanceMinor: BigInt.from(100000),
      currency: 'RUB',
      currencyScale: 2,
      type: 'checking',
      createdAt: now,
      updatedAt: now,
    );
    final Category category = Category(
      id: catId,
      name: 'Category',
      type: 'expense',
      createdAt: now,
      updatedAt: now,
    );
    final TransactionEntity transaction = TransactionEntity(
      id: 'tx-2',
      accountId: accId,
      categoryId: catId,
      savingGoalId: goalId, // Points to non-existent goal
      amountMinor: BigInt.from(10000),
      amountScale: 2,
      date: now,
      type: 'expense',
      createdAt: now,
      updatedAt: now,
    );

    // Write to fake firestore
    final DocumentReference<Map<String, dynamic>> userRef = firestore
        .collection('users')
        .doc(userId);
    await userRef
        .collection('accounts')
        .doc(accId)
        .set(
          account.toJson()
            ..['updatedAt'] = Timestamp.fromDate(account.updatedAt)
            ..['createdAt'] = Timestamp.fromDate(account.createdAt),
        );
    await userRef
        .collection('categories')
        .doc(catId)
        .set(
          category.toJson()
            ..['updatedAt'] = Timestamp.fromDate(category.updatedAt)
            ..['createdAt'] = Timestamp.fromDate(category.createdAt),
        );
    // NOTE: We do NOT write the saving goal!
    await userRef
        .collection('transactions')
        .doc(transaction.id)
        .set(
          transaction.toJson()
            ..['updatedAt'] = Timestamp.fromDate(transaction.updatedAt)
            ..['createdAt'] = Timestamp.fromDate(transaction.createdAt),
        );

    final AuthUser authUser = AuthUser(
      uid: userId,
      isAnonymous: false,
      emailVerified: true,
      creationTime: DateTime.now(),
      lastSignInTime: DateTime.now(),
    );

    // This should SUCCEED if we implement sanitization correctly.
    // The transaction should be saved with savingGoalId = null.
    await service.synchronizeOnLogin(user: authUser);

    final db.TransactionRow? savedTx = await transactionDao.findById(
      transaction.id,
    );
    expect(savedTx, isNotNull);
    expect(savedTx?.savingGoalId, isNull);
  });

  test('Should skip transaction when account is missing', () async {
    final AuthSyncService service = harness.buildService();

    const String userId = 'user-skip-tx';
    const String accId = 'acc-missing'; // Missing!

    final TransactionEntity transaction = TransactionEntity(
      id: 'tx-skip',
      accountId: accId,
      amountMinor: BigInt.from(10000),
      amountScale: 2,
      date: DateTime.now().toUtc(),
      type: 'expense',
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    // Only tx is on remote
    await firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transaction.id)
        .set(
          transaction.toJson()
            ..['updatedAt'] = Timestamp.fromDate(transaction.updatedAt)
            ..['createdAt'] = Timestamp.fromDate(transaction.createdAt),
        );

    final AuthUser authUser = AuthUser(
      uid: userId,
      isAnonymous: false,
      emailVerified: true,
      creationTime: DateTime.now(),
      lastSignInTime: DateTime.now(),
    );

    await service.synchronizeOnLogin(user: authUser);

    final db.TransactionRow? savedTx = await transactionDao.findById(
      transaction.id,
    );
    expect(
      savedTx,
      isNull,
      reason: 'Transaction should be skipped because account is missing',
    );
  });
}
