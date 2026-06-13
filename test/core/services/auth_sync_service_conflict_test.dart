// test/core/services/auth_sync_service_conflict_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/sync/sync_conflict_dao.dart';
import 'package:kopim/core/services/auth_sync_service.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'support/auth_sync_test_harness.dart';

void main() {
  late AuthSyncTestHarness harness;
  late db.AppDatabase database;
  late CategoryDao categoryDao;
  late TransactionDao transactionDao;
  late FirebaseFirestore firestore;

  setUp(() async {
    harness = AuthSyncTestHarness();
    await harness.setUp();
    database = harness.database;
    categoryDao = harness.categoryDao;
    transactionDao = harness.transactionDao;
    firestore = harness.firestore;
  });

  tearDown(() async {
    await harness.tearDown();
  });

  group('AuthSyncService - Тесты конфликтов категорий (TASK-001B)', () {
    test(
      'Удаленная категория с сервера (tombstone) сохраняется в Drift с оригинальным именем, конфликт не создается',
      () async {
        final AuthSyncService service = harness.buildService();
        const String userId = 'user-tombstone-test';
        final DateTime now = DateTime.utc(2026, 6, 13, 12);

        // 1. Создаем аккаунт на сервере
        await firestore
            .collection('users')
            .doc(userId)
            .collection('accounts')
            .doc('acc-1')
            .set(<String, dynamic>{
              'id': 'acc-1',
              'name': 'Карта',
              'balance': 100,
              'balanceMinor': '10000',
              'openingBalance': 100,
              'openingBalanceMinor': '10000',
              'currency': 'RUB',
              'currencyScale': 2,
              'type': 'checking',
              'createdAt': Timestamp.fromDate(now),
              'updatedAt': Timestamp.fromDate(now),
              'isDeleted': false,
            });

        // 2. Создаем удаленную категорию "Еда" (tombstone)
        await firestore
            .collection('users')
            .doc(userId)
            .collection('categories')
            .doc('cat-food')
            .set(<String, dynamic>{
              'id': 'cat-food',
              'name': 'Еда',
              'type': 'expense',
              'createdAt': Timestamp.fromDate(now),
              'updatedAt': Timestamp.fromDate(now),
              'isDeleted': true,
              'isSystem': false,
              'isHidden': false,
              'isFavorite': false,
            });

        // 3. Создаем транзакцию, ссылающуюся на эту категорию
        await firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc('tx-1')
            .set(<String, dynamic>{
              'id': 'tx-1',
              'accountId': 'acc-1',
              'categoryId': 'cat-food',
              'amount': 15.5,
              'amountMinor': '1550',
              'amountScale': 2,
              'date': Timestamp.fromDate(now),
              'type': TransactionType.expense.storageValue,
              'createdAt': Timestamp.fromDate(now),
              'updatedAt': Timestamp.fromDate(now),
              'isDeleted': false,
            });

        // Синхронизируем
        await service.synchronizeOnLogin(
          user: const AuthUser(
            uid: userId,
            email: 'tombstone@test.com',
            isAnonymous: false,
          ),
        );

        // Проверяем категорию в БД
        final db.CategoryRow? category = await categoryDao.findById('cat-food');
        expect(category, isNotNull);
        expect(category!.name, 'Еда');
        expect(category.isDeleted, isTrue);
        expect(category.isSystem, isFalse);

        // Проверяем транзакцию
        final db.TransactionRow? tx = await transactionDao.findById('tx-1');
        expect(tx, isNotNull);
        expect(tx!.categoryId, 'cat-food');

        // Проверяем, что конфликт не создался
        final SyncConflictDao conflictDao = SyncConflictDao(database);
        final List<db.SyncConflictRow> conflicts = await conflictDao
            .getPendingConflicts();
        expect(conflicts, isEmpty);
      },
    );

    test(
      'Полностью отсутствующая категория создает конфликт missingOptionalReference и local-only placeholder, не зануляя categoryId',
      () async {
        final AuthSyncService service = harness.buildService();
        const String userId = 'user-missing-test';
        final DateTime now = DateTime.utc(2026, 6, 13, 12);

        // 1. Создаем аккаунт на сервере
        await firestore
            .collection('users')
            .doc(userId)
            .collection('accounts')
            .doc('acc-1')
            .set(<String, dynamic>{
              'id': 'acc-1',
              'name': 'Карта',
              'balance': 100,
              'balanceMinor': '10000',
              'openingBalance': 100,
              'openingBalanceMinor': '10000',
              'currency': 'RUB',
              'currencyScale': 2,
              'type': 'checking',
              'createdAt': Timestamp.fromDate(now),
              'updatedAt': Timestamp.fromDate(now),
              'isDeleted': false,
            });

        // 2. Создаем транзакцию с отсутствующей категорией 'cat-missing'
        await firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc('tx-1')
            .set(<String, dynamic>{
              'id': 'tx-1',
              'accountId': 'acc-1',
              'categoryId': 'cat-missing',
              'amount': 15.5,
              'amountMinor': '1550',
              'amountScale': 2,
              'date': Timestamp.fromDate(now),
              'type': TransactionType.expense.storageValue,
              'createdAt': Timestamp.fromDate(now),
              'updatedAt': Timestamp.fromDate(now),
              'isDeleted': false,
            });

        // Синхронизируем первый раз
        await service.synchronizeOnLogin(
          user: const AuthUser(
            uid: userId,
            email: 'missing@test.com',
            isAnonymous: false,
          ),
        );

        // Проверяем, что в БД создался local-only placeholder
        final db.CategoryRow? placeholder = await categoryDao.findById(
          'cat-missing',
        );
        expect(placeholder, isNotNull);
        expect(placeholder!.name, 'Категория недоступна (cat-missing)');
        expect(placeholder.isSystem, isTrue);
        expect(placeholder.isDeleted, isTrue);

        // Проверяем, что categoryId в транзакции НЕ занулился
        final db.TransactionRow? tx = await transactionDao.findById('tx-1');
        expect(tx, isNotNull);
        expect(tx!.categoryId, 'cat-missing');

        // Проверяем наличие конфликта в SyncConflictDao
        final SyncConflictDao conflictDao = SyncConflictDao(database);
        List<db.SyncConflictRow> conflicts = await conflictDao
            .getPendingConflicts();
        expect(conflicts.length, 1);
        expect(conflicts[0].conflictType, 'missingOptionalReference');
        expect(conflicts[0].entityId, 'cat-missing');
        expect(conflicts[0].status, 'pending');

        // Синхронизируем повторно и проверяем, что дубликат конфликта не создается
        await service.synchronizeOnLogin(
          user: const AuthUser(
            uid: userId,
            email: 'missing@test.com',
            isAnonymous: false,
          ),
        );

        conflicts = await conflictDao.getPendingConflicts();
        expect(conflicts.length, 1);
      },
    );

    test(
      'Восстановление категории при повторном синк-запросе помечает конфликт resolved/referenceRestored',
      () async {
        final AuthSyncService service = harness.buildService();
        const String userId = 'user-restore-test';
        final DateTime now = DateTime.utc(2026, 6, 13, 12);

        // 1. Создаем аккаунт и транзакцию с отсутствующей категорией
        await firestore
            .collection('users')
            .doc(userId)
            .collection('accounts')
            .doc('acc-1')
            .set(<String, dynamic>{
              'id': 'acc-1',
              'name': 'Карта',
              'balance': 100,
              'balanceMinor': '10000',
              'openingBalance': 100,
              'openingBalanceMinor': '10000',
              'currency': 'RUB',
              'currencyScale': 2,
              'type': 'checking',
              'createdAt': Timestamp.fromDate(now),
              'updatedAt': Timestamp.fromDate(now),
              'isDeleted': false,
            });

        await firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc('tx-1')
            .set(<String, dynamic>{
              'id': 'tx-1',
              'accountId': 'acc-1',
              'categoryId': 'cat-restore',
              'amount': 15.5,
              'amountMinor': '1550',
              'amountScale': 2,
              'date': Timestamp.fromDate(now),
              'type': TransactionType.expense.storageValue,
              'createdAt': Timestamp.fromDate(now),
              'updatedAt': Timestamp.fromDate(now),
              'isDeleted': false,
            });

        // Первый синк (создает placeholder и конфликт)
        await service.synchronizeOnLogin(
          user: const AuthUser(
            uid: userId,
            email: 'restore@test.com',
            isAnonymous: false,
          ),
        );

        final SyncConflictDao conflictDao = SyncConflictDao(database);
        List<db.SyncConflictRow> pending = await conflictDao
            .getPendingConflicts();
        expect(pending.length, 1);
        expect(pending[0].status, 'pending');

        // 2. Теперь категория появляется на сервере (восстановлена)
        await firestore
            .collection('users')
            .doc(userId)
            .collection('categories')
            .doc('cat-restore')
            .set(<String, dynamic>{
              'id': 'cat-restore',
              'name': 'Авто',
              'type': 'expense',
              'createdAt': Timestamp.fromDate(now),
              'updatedAt': Timestamp.fromDate(
                now.add(const Duration(minutes: 5)),
              ),
              'isDeleted': false,
              'isSystem': false,
              'isHidden': false,
              'isFavorite': false,
            });

        // Второй синк
        await service.synchronizeOnLogin(
          user: const AuthUser(
            uid: userId,
            email: 'restore@test.com',
            isAnonymous: false,
          ),
        );

        // Проверяем, что плейсхолдер перезаписался реальной категорией
        final db.CategoryRow? category = await categoryDao.findById(
          'cat-restore',
        );
        expect(category, isNotNull);
        expect(category!.name, 'Авто');
        expect(category.isSystem, isFalse);
        expect(category.isDeleted, isFalse);

        // Проверяем, что конфликт перешел в resolved / referenceRestored
        pending = await conflictDao.getPendingConflicts();
        expect(pending, isEmpty);

        final db.SyncConflictRow? conflict = await conflictDao.getConflictByKey(
          'missing_category_cat-restore',
        );
        expect(conflict, isNotNull);
        expect(conflict!.status, 'resolved');
        expect(conflict.resolution, 'referenceRestored');
        expect(conflict.resolvedAt, isNotNull);
      },
    );

    test(
      'Deleted category keeps original name in history and missing category shows placeholder name',
      () async {
        final AuthSyncService service = harness.buildService();
        const String userId = 'user-history-test';
        final DateTime now = DateTime.utc(2026, 6, 13, 12);

        // 1. Создаем аккаунт
        await firestore
            .collection('users')
            .doc(userId)
            .collection('accounts')
            .doc('acc-1')
            .set(<String, dynamic>{
              'id': 'acc-1',
              'name': 'Карта',
              'balance': 100,
              'balanceMinor': '10000',
              'openingBalance': 100,
              'openingBalanceMinor': '10000',
              'currency': 'RUB',
              'currencyScale': 2,
              'type': 'checking',
              'createdAt': Timestamp.fromDate(now),
              'updatedAt': Timestamp.fromDate(now),
              'isDeleted': false,
            });

        // 2. Создаем удаленную remote-категорию "Еда"
        await firestore
            .collection('users')
            .doc(userId)
            .collection('categories')
            .doc('cat-deleted')
            .set(<String, dynamic>{
              'id': 'cat-deleted',
              'name': 'Еда',
              'type': 'expense',
              'createdAt': Timestamp.fromDate(now),
              'updatedAt': Timestamp.fromDate(now),
              'isDeleted': true,
              'isSystem': false,
              'isHidden': false,
              'isFavorite': false,
            });

        // 3. Создаем транзакции:
        // tx-1 ссылается на удаленную категорию 'cat-deleted'
        await firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc('tx-1')
            .set(<String, dynamic>{
              'id': 'tx-1',
              'accountId': 'acc-1',
              'categoryId': 'cat-deleted',
              'amount': 15.5,
              'amountMinor': '1550',
              'amountScale': 2,
              'date': Timestamp.fromDate(now),
              'type': TransactionType.expense.storageValue,
              'createdAt': Timestamp.fromDate(now),
              'updatedAt': Timestamp.fromDate(now),
              'isDeleted': false,
            });

        // tx-2 ссылается на вообще отсутствующую категорию 'cat-missing'
        await firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc('tx-2')
            .set(<String, dynamic>{
              'id': 'tx-2',
              'accountId': 'acc-1',
              'categoryId': 'cat-missing',
              'amount': 20.0,
              'amountMinor': '2000',
              'amountScale': 2,
              'date': Timestamp.fromDate(now),
              'type': TransactionType.expense.storageValue,
              'createdAt': Timestamp.fromDate(now),
              'updatedAt': Timestamp.fromDate(now),
              'isDeleted': false,
            });

        // Синхронизируем
        await service.synchronizeOnLogin(
          user: const AuthUser(
            uid: userId,
            email: 'history@test.com',
            isAnonymous: false,
          ),
        );

        // Получаем все категории из БД (имитируем allTransactionsCategoriesProvider)
        final List<Category> allCategoriesInDb = await categoryDao
            .getAllCategories();
        final Map<String, Category> categoriesMap = <String, Category>{
          for (final Category c in allCategoriesInDb) c.id: c,
        };

        // Загружаем транзакции из БД
        final db.TransactionRow? tx1 = await transactionDao.findById('tx-1');
        final db.TransactionRow? tx2 = await transactionDao.findById('tx-2');

        expect(tx1, isNotNull);
        expect(tx2, isNotNull);

        // Имитируем логику отображения имени категории в истории:
        // final Category? category = transaction.categoryId == null ? null : categories[transaction.categoryId!];
        // final String categoryName = category?.name ?? strings.homeTransactionsUncategorized;
        final Category? categoryForTx1 = categoriesMap[tx1!.categoryId];
        final Category? categoryForTx2 = categoriesMap[tx2!.categoryId];

        // Для удаленной категории имя в истории должно остаться оригинальным ("Еда")
        expect(categoryForTx1, isNotNull);
        expect(categoryForTx1!.name, 'Еда');

        // Для отсутствующей категории должен сработать placeholder с именем "Категория недоступна"
        expect(categoryForTx2, isNotNull);
        expect(categoryForTx2!.name, 'Категория недоступна (cat-missing)');
      },
    );

    test(
      'Несколько missing categoryId создают несколько placeholder и НЕ дедуплицируются в одну категорию',
      () async {
        final AuthSyncService service = harness.buildService();
        const String userId = 'user-multi-missing-test';
        final DateTime now = DateTime.utc(2026, 6, 13, 12);

        // 1. Создаем аккаунт
        await firestore
            .collection('users')
            .doc(userId)
            .collection('accounts')
            .doc('acc-1')
            .set(<String, dynamic>{
              'id': 'acc-1',
              'name': 'Карта',
              'balance': 100,
              'balanceMinor': '10000',
              'openingBalance': 100,
              'openingBalanceMinor': '10000',
              'currency': 'RUB',
              'currencyScale': 2,
              'type': 'checking',
              'createdAt': Timestamp.fromDate(now),
              'updatedAt': Timestamp.fromDate(now),
              'isDeleted': false,
            });

        // 2. Создаем две транзакции с разными отсутствующими категориями
        await firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc('tx-1')
            .set(<String, dynamic>{
              'id': 'tx-1',
              'accountId': 'acc-1',
              'categoryId': 'cat-missing-1',
              'amount': 10.0,
              'amountMinor': '1000',
              'amountScale': 2,
              'date': Timestamp.fromDate(now),
              'type': TransactionType.expense.storageValue,
              'createdAt': Timestamp.fromDate(now),
              'updatedAt': Timestamp.fromDate(now),
              'isDeleted': false,
            });

        await firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc('tx-2')
            .set(<String, dynamic>{
              'id': 'tx-2',
              'accountId': 'acc-1',
              'categoryId': 'cat-missing-2',
              'amount': 20.0,
              'amountMinor': '2000',
              'amountScale': 2,
              'date': Timestamp.fromDate(now),
              'type': TransactionType.expense.storageValue,
              'createdAt': Timestamp.fromDate(now),
              'updatedAt': Timestamp.fromDate(now),
              'isDeleted': false,
            });

        // Синхронизируем
        await service.synchronizeOnLogin(
          user: const AuthUser(
            uid: userId,
            email: 'multimissing@test.com',
            isAnonymous: false,
          ),
        );

        // Проверяем, что создано ДВЕ записи-плейсхолдера в categories
        final db.CategoryRow? placeholder1 = await categoryDao.findById(
          'cat-missing-1',
        );
        final db.CategoryRow? placeholder2 = await categoryDao.findById(
          'cat-missing-2',
        );

        expect(placeholder1, isNotNull);
        expect(placeholder2, isNotNull);
        expect(placeholder1!.name, 'Категория недоступна (cat-missing-1)');
        expect(placeholder2!.name, 'Категория недоступна (cat-missing-2)');

        // Убеждаемся, что они не слились в один и не дедуплицировались (оба ID присутствуют в БД)
        final List<Category> allCategories = await categoryDao
            .getAllCategories();
        final List<Category> placeholders = allCategories
            .where((Category c) => c.isMissingReferencePlaceholder)
            .toList();

        expect(placeholders.length, 2);
        expect(placeholders.map((Category c) => c.id).toSet(), <String>{
          'cat-missing-1',
          'cat-missing-2',
        });
      },
    );

    test(
      'Deleted system category не считается missing-reference placeholder, если имя не совпадает',
      () async {
        final DateTime now = DateTime.utc(2026, 6, 13, 12);

        // 1. Создаем удаленную системную категорию, но с другим именем
        final Category normalDeletedSystemCategory = Category(
          id: 'cat-sys-del',
          name: 'Системная категория',
          type: 'expense',
          isSystem: true,
          isDeleted: true,
          createdAt: now,
          updatedAt: now,
        );

        // 2. Создаем плейсхолдер
        final Category missingPlaceholder = Category(
          id: 'cat-missing-ph',
          name: 'Категория недоступна (cat-missing-ph)',
          type: 'expense',
          isSystem: true,
          isDeleted: true,
          createdAt: now,
          updatedAt: now,
        );

        // Проверяем предикат
        expect(
          normalDeletedSystemCategory.isMissingReferencePlaceholder,
          isFalse,
        );
        expect(missingPlaceholder.isMissingReferencePlaceholder, isTrue);
      },
    );
  });
}
