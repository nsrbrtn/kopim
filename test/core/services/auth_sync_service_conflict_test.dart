// test/core/services/auth_sync_service_conflict_test.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/sync/sync_conflict_dao.dart';
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/auth_sync_service.dart';
import 'package:kopim/core/services/sync/sync_conflict_types.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/data/sources/remote/category_remote_data_source.dart';
import 'package:mocktail/mocktail.dart';
import 'support/auth_sync_test_harness.dart';

class MockCategoryRemoteDataSource extends Mock
    implements CategoryRemoteDataSource {}

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

  group('AuthSyncService - Тесты Login Sync Metadata (TASK-002)', () {
    test(
      '1. Pre-pull metadata registry success - успешное чтение реестра без fallback',
      () async {
        final AuthSyncService service = harness.buildService();
        const String userId = 'user-registry-success';
        final DateTime now = DateTime.utc(2026, 6, 14, 12);

        // 1. Запишем реестр в Firestore
        await firestore
            .collection('users')
            .doc(userId)
            .collection('sync_registry')
            .doc('category')
            .set(<String, dynamic>{
              'metadata': <String, dynamic>{
                'cat-1': <String, dynamic>{
                  'updatedAt': Timestamp.fromDate(now),
                  'isDeleted': false,
                },
              },
            });

        // 2. Создаем категорию на сервере, чтобы fullPullAndMerge нашел её
        await harness.seedRemoteSnapshot(
          userId: userId,
          categories: <Category>[
            Category(
              id: 'cat-1',
              name: 'Еда',
              type: 'expense',
              createdAt: now,
              updatedAt: now,
            ),
          ],
        );

        // 3. Запускаем синхронизацию
        await service.synchronizeOnLogin(
          user: const AuthUser(
            uid: userId,
            email: 'test@example.com',
            isAnonymous: false,
          ),
        );

        // Убеждаемся, что категория появилась локально
        final db.CategoryRow? localCategory = await categoryDao.findById(
          'cat-1',
        );
        expect(localCategory, isNotNull);
        expect(localCategory!.name, 'Еда');
      },
    );

    test(
      '2. Fallback to full snapshot & Bootstrap - наполнение пустого реестра на сервере',
      () async {
        final AuthSyncService service = harness.buildService();
        const String userId = 'user-fallback-bootstrap';
        final DateTime now = DateTime.utc(2026, 6, 14, 12);

        // 1. Категория и транзакция на сервере
        await harness.seedRemoteSnapshot(
          userId: userId,
          categories: <Category>[
            Category(
              id: 'cat-1',
              name: 'Категория 1',
              type: 'expense',
              createdAt: now,
              updatedAt: now,
            ),
          ],
        );

        // Убедимся, что коллекция sync_registry пуста
        final QuerySnapshot<Map<String, dynamic>> registryDocsBefore =
            await firestore
                .collection('users')
                .doc(userId)
                .collection('sync_registry')
                .get();
        expect(registryDocsBefore.docs, isEmpty);

        // 2. Запускаем синхронизацию (это вызовет fallback и bootstrap)
        await service.synchronizeOnLogin(
          user: const AuthUser(
            uid: userId,
            email: 'test@example.com',
            isAnonymous: false,
          ),
        );

        // 3. После синхронизации реестр должен наполниться на сервере (bootstrap)
        final QuerySnapshot<Map<String, dynamic>> registryDocsAfter =
            await firestore
                .collection('users')
                .doc(userId)
                .collection('sync_registry')
                .get();
        expect(registryDocsAfter.docs, isNotEmpty);

        final DocumentSnapshot<Map<String, dynamic>> categoryDoc =
            await firestore
                .collection('users')
                .doc(userId)
                .collection('sync_registry')
                .doc('category')
                .get();
        expect(categoryDoc.exists, isTrue);
        final Map<String, dynamic>? metadata =
            categoryDoc.data()?['metadata'] as Map<String, dynamic>?;
        expect(metadata, isNotNull);
        expect(metadata!['cat-1'], isNotNull);
      },
    );

    test(
      '3. Registry document size / sharding - транзакции распределяются по шардам на основе stableHash',
      () async {
        final AuthSyncService service = harness.buildService();
        const String userId = 'user-sharding-test';
        final DateTime now = DateTime.utc(2026, 6, 14, 12);

        // Подготовим аккаунт и категорию
        final AccountEntity account = AccountEntity(
          id: 'acc-1',
          name: 'Карта',
          balanceMinor: BigInt.zero,
          openingBalanceMinor: BigInt.zero,
          currency: 'RUB',
          currencyScale: 2,
          type: 'checking',
          createdAt: now,
          updatedAt: now,
          isDeleted: false,
        );

        final Category category = Category(
          id: 'cat-1',
          name: 'Еда',
          type: 'expense',
          createdAt: now,
          updatedAt: now,
        );

        // Подготовим 30 транзакций
        final List<TransactionEntity> transactions = <TransactionEntity>[];
        for (int i = 0; i < 30; i++) {
          transactions.add(
            TransactionEntity(
              id: 'tx-uuid-test-$i',
              accountId: 'acc-1',
              categoryId: 'cat-1',
              amountMinor: BigInt.from(1000),
              amountScale: 2,
              date: now,
              type: TransactionType.expense.storageValue,
              createdAt: now,
              updatedAt: now,
            ),
          );
        }

        await harness.seedRemoteSnapshot(
          userId: userId,
          accounts: <AccountEntity>[account],
          categories: <Category>[category],
          transactions: transactions,
        );

        // Запустим синхронизацию
        await service.synchronizeOnLogin(
          user: const AuthUser(
            uid: userId,
            email: 'test@example.com',
            isAnonymous: false,
          ),
        );

        // Проверим, что создано несколько документов transactions_XX
        final QuerySnapshot<Map<String, dynamic>> registryDocs = await firestore
            .collection('users')
            .doc(userId)
            .collection('sync_registry')
            .get();

        final Iterable<QueryDocumentSnapshot<Map<String, dynamic>>>
        transactionShards = registryDocs.docs.where(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              doc.id.startsWith('transactions_'),
        );
        expect(
          transactionShards.length,
          greaterThan(1),
        ); // Есть распределение по шардам
      },
    );

    test(
      '4. Base metadata conflict - изменение updatedAt на сервере создает конфликт',
      () async {
        final AuthSyncService service = harness.buildService();
        const String userId = 'user-base-conflict';
        harness.setActiveCloudUid(userId);
        final DateTime now = DateTime.utc(2026, 6, 14, 12);
        final DateTime localBaseTime = now.subtract(
          const Duration(minutes: 10),
        );
        final DateTime remoteServerTime = now;

        // 1. Запишем реестр в Firestore с новым remoteServerTime
        await firestore
            .collection('users')
            .doc(userId)
            .collection('sync_registry')
            .doc('category')
            .set(<String, dynamic>{
              'metadata': <String, dynamic>{
                'cat-1': <String, dynamic>{
                  'updatedAt': Timestamp.fromDate(remoteServerTime),
                  'isDeleted': false,
                },
              },
            });

        await harness.seedRemoteSnapshot(
          userId: userId,
          categories: <Category>[
            Category(
              id: 'cat-1',
              name: 'Server Name',
              type: 'expense',
              createdAt: now,
              updatedAt: remoteServerTime,
            ),
          ],
        );

        // 2. Локально добавляем запись в outbox со старым baseRemoteUpdatedAt
        final Category localCategory = Category(
          id: 'cat-1',
          name: 'Local Changed Name',
          type: 'expense',
          createdAt: now,
          updatedAt: now.add(const Duration(minutes: 2)),
        );
        await categoryDao.upsert(localCategory);
        await harness.outboxDao.enqueue(
          entityType: 'category',
          entityId: 'cat-1',
          operation: OutboxOperation.upsert,
          payload: localCategory.toJson(),
          baseRemoteUpdatedAt: localBaseTime,
          baseRemoteIsDeleted: false,
        );

        // 3. Запускаем синхронизацию
        await service.synchronizeOnLogin(
          user: const AuthUser(
            uid: userId,
            email: 'test@example.com',
            isAnonymous: false,
          ),
        );

        // Проверяем конфликт
        final SyncConflictDao syncConflictDao = SyncConflictDao(database);
        final List<db.SyncConflictRow> conflicts = await syncConflictDao
            .getPendingConflicts();
        expect(conflicts.length, 1);
        expect(conflicts.first.entityId, 'cat-1');
        expect(
          conflicts.first.conflictType,
          SyncConflictType.updateUpdate.value,
        );

        // Убеждаемся, что на сервере имя осталось оригинальным (не перезаписалось)
        final Map<String, dynamic>? remoteDoc = await harness
            .fetchRemoteDocData(
              userId: userId,
              entityType: 'category',
              entityId: 'cat-1',
            );
        expect(remoteDoc?['name'], 'Server Name');
      },
    );

    test(
      '5. Conflict preserves local payload after full pull - сохранение localPayloadJson в sync_conflicts',
      () async {
        final AuthSyncService service = harness.buildService();
        const String userId = 'user-preserve-payload';
        harness.setActiveCloudUid(userId);
        final DateTime now = DateTime.utc(2026, 6, 14, 12);
        final DateTime localBaseTime = now.subtract(
          const Duration(minutes: 10),
        );
        final DateTime remoteServerTime = now;

        await firestore
            .collection('users')
            .doc(userId)
            .collection('sync_registry')
            .doc('category')
            .set(<String, dynamic>{
              'metadata': <String, dynamic>{
                'cat-1': <String, dynamic>{
                  'updatedAt': Timestamp.fromDate(remoteServerTime),
                  'isDeleted': false,
                },
              },
            });

        await harness.seedRemoteSnapshot(
          userId: userId,
          categories: <Category>[
            Category(
              id: 'cat-1',
              name: 'Server Name',
              type: 'expense',
              createdAt: now,
              updatedAt: remoteServerTime,
            ),
          ],
        );

        final Category localCategory = Category(
          id: 'cat-1',
          name: 'My Local Modified Name',
          type: 'expense',
          createdAt: now,
          updatedAt: now.add(const Duration(minutes: 2)),
        );
        await categoryDao.upsert(localCategory);
        await harness.outboxDao.enqueue(
          entityType: 'category',
          entityId: 'cat-1',
          operation: OutboxOperation.upsert,
          payload: localCategory.toJson(),
          baseRemoteUpdatedAt: localBaseTime,
        );

        await service.synchronizeOnLogin(
          user: const AuthUser(
            uid: userId,
            email: 'test@example.com',
            isAnonymous: false,
          ),
        );

        final SyncConflictDao syncConflictDao = SyncConflictDao(database);
        final List<db.SyncConflictRow> conflicts = await syncConflictDao
            .getPendingConflicts();
        expect(conflicts.length, 1);
        expect(conflicts.first.localPayloadJson, isNotNull);
        final Map<String, dynamic> decoded =
            jsonDecode(conflicts.first.localPayloadJson!)
                as Map<String, dynamic>;
        expect(decoded['name'], 'My Local Modified Name');
      },
    );

    test(
      '6. TASK-001B invariant - placeholder-категории не записываются в реестр при bootstrap',
      () async {
        final AuthSyncService service = harness.buildService();
        const String userId = 'user-placeholder-invariant';
        final DateTime now = DateTime.utc(2026, 6, 14, 12);

        final Category normalCategory = Category(
          id: 'cat-normal',
          name: 'Еда',
          type: 'expense',
          createdAt: now,
          updatedAt: now,
        );
        final Category placeholderCategory = Category(
          id: 'cat-missing-1',
          name: 'Категория недоступна (cat-missing-1)',
          type: 'expense',
          isSystem: true,
          isDeleted: true,
          createdAt: now,
          updatedAt: now,
        );

        await categoryDao.upsert(normalCategory);
        await categoryDao.upsert(placeholderCategory);

        await service.bootstrapRegistryForTest(userId);

        final DocumentSnapshot<Map<String, dynamic>> categoryDoc =
            await firestore
                .collection('users')
                .doc(userId)
                .collection('sync_registry')
                .doc('category')
                .get();
        expect(categoryDoc.exists, isTrue);
        final Map<String, dynamic>? metadata =
            categoryDoc.data()?['metadata'] as Map<String, dynamic>?;
        expect(metadata, isNotNull);
        expect(metadata!['cat-normal'], isNotNull);
        expect(metadata['cat-missing-1'], isNull); // Плейсхолдер исключен!
      },
    );

    test(
      '7. Race between metadata pull and push (RegistryConflictException recovery) - транзакционный откат при изменении реестра во время push',
      () async {
        const String userId = 'user-race-test';
        harness.setActiveCloudUid(userId);
        final DateTime now = DateTime.utc(2026, 6, 14, 12);
        final DateTime baseTime = now.subtract(const Duration(minutes: 5));

        // 1. Создаем мок CategoryRemoteDataSource для перехвата fetchRemoteSnapshot
        final MockCategoryRemoteDataSource mockCategoryRemote =
            MockCategoryRemoteDataSource();
        final AuthSyncService service = harness.buildService(
          categoryRemoteDataSource: mockCategoryRemote,
        );

        // При fetchAll (вызывается из fallback _fetchRemoteSnapshot) мы симулируем запись нового updatedAt в реестр
        when(() => mockCategoryRemote.fetchAll(userId)).thenAnswer((_) async {
          await firestore
              .collection('users')
              .doc(userId)
              .collection('sync_registry')
              .doc('category')
              .set(<String, dynamic>{
                'metadata': <String, dynamic>{
                  'cat-1': <String, dynamic>{
                    'updatedAt': Timestamp.fromDate(
                      now,
                    ), // Новое время на сервере!
                    'isDeleted': false,
                  },
                },
              });
          return <Category>[
            Category(
              id: 'cat-1',
              name: 'Server Name',
              type: 'expense',
              createdAt: now,
              updatedAt: baseTime,
            ),
          ];
        });

        // Также замокаем upsertInTransaction, чтобы он просто успешно завершался
        when(
          () => mockCategoryRemote.upsertInTransaction(any(), any(), any()),
        ).thenAnswer((_) async {});

        // 2. Локально добавляем запись в outbox, которая считает, что baseRemoteUpdatedAt == baseTime
        final Category localCategory = Category(
          id: 'cat-1',
          name: 'Local Changed Name',
          type: 'expense',
          createdAt: now,
          updatedAt: now,
        );
        await categoryDao.upsert(localCategory);
        await harness.outboxDao.enqueue(
          entityType: 'category',
          entityId: 'cat-1',
          operation: OutboxOperation.upsert,
          payload: localCategory.toJson(),
          baseRemoteUpdatedAt: baseTime,
          baseRemoteIsDeleted: false,
        );

        // 3. Запускаем синхронизацию.
        // pullRemoteRegistry уходит в fallback, т.к. реестр пуст.
        // fetchRemoteSnapshot вызывает mockCategoryRemote.getAll, который обновляет реестр на сервере.
        // classify считает запись safe, т.к. в snapshot updatedAt равен baseTime.
        // Во время транзакции push-а считывается свежий реестр, видит несовпадение и выбрасывает RegistryConflictException.
        await service.synchronizeOnLogin(
          user: const AuthUser(
            uid: userId,
            email: 'test@example.com',
            isAnonymous: false,
          ),
        );

        // 4. Проверяем, что локально создан pending конфликт
        final SyncConflictDao syncConflictDao = SyncConflictDao(database);
        final List<db.SyncConflictRow> conflicts = await syncConflictDao
            .getPendingConflicts();
        expect(conflicts.length, 1);
        expect(conflicts.first.entityId, 'cat-1');
        expect(
          conflicts.first.conflictType,
          SyncConflictType.updateUpdate.value,
        );
      },
    );

    test(
      '8. Batch size dynamic resizing - при RESOURCE_EXHAUSTED батч делится пополам',
      () async {
        const String userId = 'user-resizing-test';
        harness.setActiveCloudUid(userId);
        final DateTime now = DateTime.utc(2026, 6, 14, 12);

        // 1. Создаем мок CategoryRemoteDataSource для выброса исключения
        final MockCategoryRemoteDataSource mockCategoryRemote =
            MockCategoryRemoteDataSource();
        final AuthSyncService service = harness.buildService(
          categoryRemoteDataSource: mockCategoryRemote,
        );
        service.pushBatchSize = 100;

        int upsertAttempts = 0;
        bool hasFailed = false;
        when(
          () => mockCategoryRemote.fetchAll(userId),
        ).thenAnswer((_) async => <Category>[]);
        when(
          () => mockCategoryRemote.upsertInTransaction(any(), any(), any()),
        ).thenAnswer((Invocation invocation) {
          upsertAttempts++;
          // При самом первом вызове (в первом батче размера 100) выбрасываем RESOURCE_EXHAUSTED.
          // Это вызовет уменьшение батча до 50.
          if (!hasFailed) {
            hasFailed = true;
            throw FirebaseException(
              plugin: 'firestore',
              code: 'resource-exhausted',
              message: 'RESOURCE_EXHAUSTED: Too many writes',
            );
          }
          // При повторных попытках (батч 50) пропускаем успешно
        });

        // 2. Локально добавляем 100 категорий в outbox
        for (int i = 0; i < 100; i++) {
          final Category cat = Category(
            id: 'cat-res-$i',
            name: 'Cat $i',
            type: 'expense',
            createdAt: now,
            updatedAt: now,
          );
          await categoryDao.upsert(cat);
          await harness.outboxDao.enqueue(
            entityType: 'category',
            entityId: 'cat-res-$i',
            operation: OutboxOperation.upsert,
            payload: cat.toJson(),
            baseRemoteUpdatedAt: now,
          );
        }

        // 3. Запускаем синхронизацию
        await service.synchronizeOnLogin(
          user: const AuthUser(
            uid: userId,
            email: 'test@example.com',
            isAnonymous: false,
          ),
        );

        // Проверяем, что все 100 элементов были успешно запушены после ресайза (outbox пуст)
        final List<db.OutboxEntryRow> pending = await harness.outboxDao
            .fetchPending();
        final List<db.OutboxEntryRow> pendingCategories = pending
            .where((db.OutboxEntryRow e) => e.entityType == 'category')
            .toList();
        expect(pendingCategories, isEmpty);
        expect(upsertAttempts, greaterThan(100)); // Была вторая попытка
      },
    );

    test(
      '9. Old outbox entry without baseRemoteUpdatedAt - старая запись outbox считает конфликт при наличии реестра на сервере',
      () async {
        final AuthSyncService service = harness.buildService();
        const String userId = 'user-legacy-outbox-conflict';
        harness.setActiveCloudUid(userId);
        final DateTime now = DateTime.utc(2026, 6, 14, 12);

        // Реестр на сервере
        await firestore
            .collection('users')
            .doc(userId)
            .collection('sync_registry')
            .doc('category')
            .set(<String, dynamic>{
              'metadata': <String, dynamic>{
                'cat-legacy': <String, dynamic>{
                  'updatedAt': Timestamp.fromDate(now),
                  'isDeleted': false,
                },
              },
            });

        await harness.seedRemoteSnapshot(
          userId: userId,
          categories: <Category>[
            Category(
              id: 'cat-legacy',
              name: 'Server Category',
              type: 'expense',
              createdAt: now,
              updatedAt: now,
            ),
          ],
        );

        // Outbox локально с baseRemoteUpdatedAt = null
        final Category localCategory = Category(
          id: 'cat-legacy',
          name: 'Legacy Changed Name',
          type: 'expense',
          createdAt: now,
          updatedAt: now,
        );
        await categoryDao.upsert(localCategory);
        await harness.outboxDao.enqueue(
          entityType: 'category',
          entityId: 'cat-legacy',
          operation: OutboxOperation.upsert,
          payload: localCategory.toJson(),
          baseRemoteUpdatedAt: null, // Legacy запись
        );

        await service.synchronizeOnLogin(
          user: const AuthUser(
            uid: userId,
            email: 'test@example.com',
            isAnonymous: false,
          ),
        );

        // Должен создаться конфликт
        final SyncConflictDao syncConflictDao = SyncConflictDao(database);
        final List<db.SyncConflictRow> conflicts = await syncConflictDao
            .getPendingConflicts();
        expect(conflicts.length, 1);
        expect(conflicts.first.entityId, 'cat-legacy');
        expect(
          conflicts.first.conflictType,
          SyncConflictType.updateUpdate.value,
        );
      },
    );

    test(
      '10. Invariants test - ключи реестра map-safe для UUID, плейсхолдеров и составных ID',
      () async {
        final AuthSyncService service = harness.buildService();
        const String userId = 'user-invariants-test';
        final DateTime now = DateTime.utc(2026, 6, 14, 12);

        // 1. Создаем локальные сущности
        final AccountEntity account = AccountEntity(
          id: 'acc-uuid-1',
          name: 'Тестовый счет',
          balanceMinor: BigInt.zero,
          openingBalanceMinor: BigInt.zero,
          currency: 'RUB',
          currencyScale: 2,
          type: 'checking',
          createdAt: now,
          updatedAt: now,
          isDeleted: false,
        );

        final Category placeholder = Category(
          id: 'cat-missing-1',
          name: 'Категория недоступна (cat-missing-1)',
          type: 'expense',
          isSystem: true,
          isDeleted: true,
          createdAt: now,
          updatedAt: now,
        );

        final TransactionEntity transaction = TransactionEntity(
          id: 'tx-uuid-5678',
          accountId: 'acc-uuid-1',
          categoryId: 'cat-missing-1',
          amountMinor: BigInt.from(1000),
          amountScale: 2,
          date: now,
          type: TransactionType.expense.storageValue,
          createdAt: now,
          updatedAt: now,
        );

        final TagEntity tag = TagEntity(
          id: 'tag-uuid-1234',
          name: 'Тег',
          color: 'blue',
          createdAt: now,
          updatedAt: now,
        );

        final TransactionTagEntity txTag = TransactionTagEntity(
          transactionId: 'tx-uuid-5678',
          tagId: 'tag-uuid-1234',
          createdAt: now,
          updatedAt: now,
        );

        await harness.accountDao.upsert(account);
        await categoryDao.upsert(placeholder);
        await harness.transactionDao.upsert(transaction);
        await harness.tagDao.upsert(tag);
        await harness.transactionTagsDao.upsert(txTag);

        // 2. Запускаем bootstrap реестра
        await service.bootstrapRegistryForTest(userId);

        // Проверим, что placeholder категории НЕ попал в реестр категорий
        final DocumentSnapshot<Map<String, dynamic>> categoryDoc =
            await firestore
                .collection('users')
                .doc(userId)
                .collection('sync_registry')
                .doc('category')
                .get();
        if (categoryDoc.exists) {
          final Map<String, dynamic>? metadata =
              categoryDoc.data()?['metadata'] as Map<String, dynamic>?;
          expect(metadata?['cat-missing-1'], isNull);
        }

        // Проверим, что тег попал в реестр тегов
        final DocumentSnapshot<Map<String, dynamic>> tagDoc = await firestore
            .collection('users')
            .doc(userId)
            .collection('sync_registry')
            .doc('tag')
            .get();
        expect(tagDoc.exists, isTrue);
        final Map<String, dynamic>? tagMetadata =
            tagDoc.data()?['metadata'] as Map<String, dynamic>?;
        expect(tagMetadata?['tag-uuid-1234'], isNotNull);

        // Проверим, что составной ключ тега транзакции попал в реестр шардированных тегов транзакций
        final QuerySnapshot<Map<String, dynamic>> registryDocs = await firestore
            .collection('users')
            .doc(userId)
            .collection('sync_registry')
            .get();

        final Iterable<QueryDocumentSnapshot<Map<String, dynamic>>>
        txTagShards = registryDocs.docs.where(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              doc.id.startsWith('transaction_tags_'),
        );
        expect(txTagShards, isNotEmpty);
        final Map<String, dynamic>? metadataMap =
            txTagShards.first.data()['metadata'] as Map<String, dynamic>?;
        expect(metadataMap?['tx-uuid-5678::tag-uuid-1234'], isNotNull);
      },
    );
  });
}
