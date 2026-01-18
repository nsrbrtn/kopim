import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/credits/data/sources/local/credit_dao.dart';
import 'package:kopim/features/settings/data/repositories/import_data_repository_impl.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

void main() {
  late db.AppDatabase database;
  late AccountDao accountDao;
  late CategoryDao categoryDao;
  late CreditDao creditDao;
  late TransactionDao transactionDao;
  late ImportDataRepositoryImpl repository;

  setUp(() {
    database = db.AppDatabase.connect(
      DatabaseConnection(NativeDatabase.memory()),
    );
    accountDao = AccountDao(database);
    categoryDao = CategoryDao(database);
    creditDao = CreditDao(database);
    transactionDao = TransactionDao(database);
    repository = ImportDataRepositoryImpl(
      accountDao: accountDao,
      categoryDao: categoryDao,
      creditDao: creditDao,
      transactionDao: transactionDao,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('пересчитывает балансы после импорта транзакций', () async {
    final DateTime now = DateTime.utc(2024, 6, 1);
    final AccountEntity account1 = AccountEntity(
      id: 'acc-1',
      name: 'Main',
      balance: 60,
      currency: 'USD',
      type: 'card',
      createdAt: now,
      updatedAt: now,
    );
    final AccountEntity account2 = AccountEntity(
      id: 'acc-2',
      name: 'Cash',
      balance: 10,
      currency: 'USD',
      type: 'cash',
      createdAt: now,
      updatedAt: now,
    );

    await repository.upsertAccounts(<AccountEntity>[account1, account2]);
    await repository.upsertCategories(<Category>[]);

    final List<TransactionEntity> transactions = <TransactionEntity>[
      TransactionEntity(
        id: 'tx-1',
        accountId: 'acc-1',
        amount: 100,
        date: now,
        type: TransactionType.income.storageValue,
        createdAt: now,
        updatedAt: now,
      ),
      TransactionEntity(
        id: 'tx-2',
        accountId: 'acc-1',
        amount: 30,
        date: now,
        type: TransactionType.expense.storageValue,
        createdAt: now,
        updatedAt: now,
      ),
      TransactionEntity(
        id: 'tx-3',
        accountId: 'acc-1',
        transferAccountId: 'acc-2',
        amount: 10,
        date: now,
        type: TransactionType.transfer.storageValue,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await repository.upsertTransactions(transactions);

    final List<AccountEntity> accounts = await accountDao.getAllAccounts();
    final AccountEntity updated1 = accounts.firstWhere(
      (AccountEntity account) => account.id == 'acc-1',
    );
    final AccountEntity updated2 = accounts.firstWhere(
      (AccountEntity account) => account.id == 'acc-2',
    );

    expect(updated1.balance, closeTo(60, 1e-9));
    expect(updated2.balance, closeTo(10, 1e-9));
  });
}
