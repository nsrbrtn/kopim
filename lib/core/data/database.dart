// lib/core/data/database.dart
import 'package:drift/drift.dart';
import 'package:kopim/core/data/converters/json_map_list_converter.dart';
import 'package:kopim/core/data/converters/string_list_converter.dart';
import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/upcoming_payments/data/drift/tables/payment_reminders_table.dart';
import 'package:kopim/features/upcoming_payments/data/drift/tables/upcoming_payments_table.dart';

part 'database.g.dart';

@DataClassName('AccountRow')
class Accounts extends Table {
  TextColumn get id => text().withLength(min: 1, max: 50)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get balance => real()();
  TextColumn get balanceMinor =>
      text().named('balance_minor').withDefault(const Constant<String>('0'))();
  RealColumn get openingBalance =>
      real().named('opening_balance').withDefault(const Constant<double>(0))();
  TextColumn get openingBalanceMinor => text()
      .named('opening_balance_minor')
      .withDefault(const Constant<String>('0'))();
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  IntColumn get currencyScale =>
      integer().named('currency_scale').withDefault(const Constant<int>(2))();
  TextColumn get type => text().withLength(min: 1, max: 50)();
  TextColumn get color => text().nullable()();
  TextColumn get gradientId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant<bool>(false))();
  BoolColumn get isPrimary =>
      boolean().withDefault(const Constant<bool>(false))();
  BoolColumn get isHidden =>
      boolean().withDefault(const Constant<bool>(false))();
  TextColumn get iconName => text().nullable()();
  TextColumn get iconStyle => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text().withLength(min: 1, max: 50)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get type => text().withLength(min: 1, max: 50)();
  TextColumn get icon => text().nullable()();
  TextColumn get iconStyle => text().nullable()();
  TextColumn get iconName => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get parentId => text().nullable().customConstraint(
    'REFERENCES categories(id) ON DELETE SET NULL',
  )();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant<bool>(false))();
  BoolColumn get isSystem =>
      boolean().withDefault(const Constant<bool>(false))();
  BoolColumn get isFavorite =>
      boolean().withDefault(const Constant<bool>(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('TagRow')
class Tags extends Table {
  TextColumn get id => text().withLength(min: 1, max: 50)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get color => text().withLength(min: 1, max: 16)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant<bool>(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('TransactionRow')
class Transactions extends Table {
  TextColumn get id => text().withLength(min: 1, max: 50)();
  TextColumn get accountId =>
      text().references(Accounts, #id, onDelete: KeyAction.cascade)();
  TextColumn get transferAccountId => text()
      .references(Accounts, #id, onDelete: KeyAction.setNull)
      .nullable()();
  TextColumn get categoryId => text()
      .references(Categories, #id, onDelete: KeyAction.setNull)
      .nullable()();
  RealColumn get amount => real()();
  TextColumn get amountMinor =>
      text().named('amount_minor').withDefault(const Constant<String>('0'))();
  IntColumn get amountScale =>
      integer().named('amount_scale').withDefault(const Constant<int>(2))();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  TextColumn get type => text().withLength(min: 1, max: 50)();
  TextColumn get savingGoalId => text().nullable().customConstraint(
    'REFERENCES saving_goals(id) ON DELETE SET NULL',
  )();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant<bool>(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('TransactionTagRow')
class TransactionTags extends Table {
  TextColumn get transactionId =>
      text().references(Transactions, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant<bool>(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{transactionId, tagId};
}

@DataClassName('OutboxEntryRow')
class OutboxEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text().withLength(min: 1, max: 50)();
  TextColumn get entityId => text().withLength(min: 1, max: 50)();
  TextColumn get operation => text().withLength(min: 1, max: 20)();
  TextColumn get payload => text()();
  TextColumn get status =>
      text().withDefault(const Constant<String>('pending'))();
  IntColumn get attemptCount => integer().withDefault(const Constant<int>(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get sentAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
}

@DataClassName('ProfileRow')
class Profiles extends Table {
  TextColumn get uid => text().withLength(min: 1, max: 64)();
  TextColumn get name => text().withLength(min: 0, max: 120).nullable()();
  TextColumn get currency => text().withLength(min: 3, max: 3).nullable()();
  TextColumn get locale => text().withLength(min: 2, max: 10).nullable()();
  TextColumn get photoUrl => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{uid};
}

@DataClassName('BudgetRow')
class Budgets extends Table {
  TextColumn get id => text().withLength(min: 1, max: 60)();
  TextColumn get title => text().withLength(min: 1, max: 160)();
  TextColumn get period => text().withLength(min: 1, max: 20)();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  RealColumn get amount => real()();
  TextColumn get amountMinor =>
      text().named('amount_minor').withDefault(const Constant<String>('0'))();
  IntColumn get amountScale =>
      integer().named('amount_scale').withDefault(const Constant<int>(2))();
  TextColumn get scope => text().withLength(min: 1, max: 32)();
  TextColumn get categories =>
      text().map(const StringListConverter()).clientDefault(() => '[]')();
  TextColumn get accounts =>
      text().map(const StringListConverter()).clientDefault(() => '[]')();
  TextColumn get categoryAllocations =>
      text().map(const JsonMapListConverter()).clientDefault(() => '[]')();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant<bool>(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('BudgetInstanceRow')
class BudgetInstances extends Table {
  TextColumn get id => text().withLength(min: 1, max: 80)();
  TextColumn get budgetId =>
      text().references(Budgets, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get periodStart => dateTime()();
  DateTimeColumn get periodEnd => dateTime()();
  RealColumn get amount => real()();
  TextColumn get amountMinor =>
      text().named('amount_minor').withDefault(const Constant<String>('0'))();
  RealColumn get spent => real().withDefault(const Constant<double>(0))();
  TextColumn get spentMinor =>
      text().named('spent_minor').withDefault(const Constant<String>('0'))();
  IntColumn get amountScale =>
      integer().named('amount_scale').withDefault(const Constant<int>(2))();
  TextColumn get status => text()
      .withLength(min: 1, max: 20)
      .withDefault(const Constant<String>('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('SavingGoalRow')
class SavingGoals extends Table {
  TextColumn get id => text().withLength(min: 1, max: 50)();
  TextColumn get userId => text().withLength(min: 1, max: 64)();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  IntColumn get targetAmount => integer()();
  IntColumn get currentAmount =>
      integer().withDefault(const Constant<int>(0))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('GoalContributionRow')
class GoalContributions extends Table {
  TextColumn get id => text().withLength(min: 1, max: 50)();
  TextColumn get goalId =>
      text().references(SavingGoals, #id, onDelete: KeyAction.cascade)();
  TextColumn get transactionId =>
      text().references(Transactions, #id, onDelete: KeyAction.cascade)();
  IntColumn get amount => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('DebtRow')
class Debts extends Table {
  TextColumn get id => text().withLength(min: 1, max: 50)();
  TextColumn get accountId =>
      text().references(Accounts, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 120).nullable()();
  RealColumn get amount => real()();
  TextColumn get amountMinor =>
      text().named('amount_minor').withDefault(const Constant<String>('0'))();
  IntColumn get amountScale =>
      integer().named('amount_scale').withDefault(const Constant<int>(2))();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant<bool>(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('CreditRow')
class Credits extends Table {
  TextColumn get id => text().withLength(min: 1, max: 50)();
  TextColumn get accountId =>
      text().references(Accounts, #id, onDelete: KeyAction.cascade)();
  TextColumn get categoryId => text().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();
  RealColumn get totalAmount => real()();
  TextColumn get totalAmountMinor => text()
      .named('total_amount_minor')
      .withDefault(const Constant<String>('0'))();
  IntColumn get totalAmountScale => integer()
      .named('total_amount_scale')
      .withDefault(const Constant<int>(2))();
  RealColumn get interestRate => real()();
  IntColumn get termMonths => integer()();
  DateTimeColumn get startDate => dateTime()();
  IntColumn get paymentDay => integer().withDefault(const Constant<int>(1))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant<bool>(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('CreditCardRow')
class CreditCards extends Table {
  TextColumn get id => text().withLength(min: 1, max: 50)();
  TextColumn get accountId =>
      text().references(Accounts, #id, onDelete: KeyAction.cascade)();
  RealColumn get creditLimit => real()();
  TextColumn get creditLimitMinor => text()
      .named('credit_limit_minor')
      .withDefault(const Constant<String>('0'))();
  IntColumn get creditLimitScale => integer()
      .named('credit_limit_scale')
      .withDefault(const Constant<int>(2))();
  IntColumn get statementDay => integer()();
  IntColumn get paymentDueDays => integer()();
  RealColumn get interestRateAnnual => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant<bool>(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DriftDatabase(
  tables: <Type>[
    Accounts,
    Categories,
    Tags,
    Transactions,
    TransactionTags,
    OutboxEntries,
    Profiles,
    Budgets,
    BudgetInstances,
    SavingGoals,
    GoalContributions,
    UpcomingPayments,
    PaymentReminders,
    Debts,
    Credits,
    CreditCards,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.connect(DatabaseConnection super.connection);

  @override
  int get schemaVersion => 35;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await m.createIndex(
        Index(
          'budget_instances_budget_period_idx',
          'CREATE INDEX IF NOT EXISTS budget_instances_budget_period_idx '
              'ON budget_instances(budget_id, period_start)',
        ),
      );
      await m.createIndex(
        Index(
          'saving_goals_status_updated_idx',
          'CREATE INDEX IF NOT EXISTS saving_goals_status_updated_idx '
              'ON saving_goals(archived_at, updated_at DESC)',
        ),
      );
      await m.createIndex(
        Index(
          'categories_name_unique',
          'CREATE UNIQUE INDEX IF NOT EXISTS categories_name_unique '
              'ON categories(name)',
        ),
      );
      await m.createIndex(
        Index(
          'goal_contributions_goal_idx',
          'CREATE INDEX IF NOT EXISTS goal_contributions_goal_idx '
              'ON goal_contributions(goal_id)',
        ),
      );
      await m.createIndex(
        Index(
          'transactions_saving_goal_idx',
          'CREATE INDEX IF NOT EXISTS transactions_saving_goal_idx '
              'ON transactions(saving_goal_id)',
        ),
      );
      await m.createIndex(
        Index(
          'transactions_date_account_category_idx',
          'CREATE INDEX IF NOT EXISTS transactions_date_account_category_idx '
              'ON transactions(date, account_id, category_id)',
        ),
      );
      await m.createIndex(
        Index(
          'transactions_account_date_type_idx',
          'CREATE INDEX IF NOT EXISTS transactions_account_date_type_idx '
              'ON transactions(account_id, date, type)',
        ),
      );
      await m.createIndex(
        Index(
          'transactions_category_date_idx',
          'CREATE INDEX IF NOT EXISTS transactions_category_date_idx '
              'ON transactions(category_id, date)',
        ),
      );
      await m.createIndex(
        Index(
          'transactions_transfer_account_idx',
          'CREATE INDEX IF NOT EXISTS transactions_transfer_account_idx '
              'ON transactions(transfer_account_id)',
        ),
      );
      await m.createIndex(
        Index(
          'transaction_tags_transaction_idx',
          'CREATE INDEX IF NOT EXISTS transaction_tags_transaction_idx '
              'ON transaction_tags(transaction_id)',
        ),
      );
      await m.createIndex(
        Index(
          'transaction_tags_tag_idx',
          'CREATE INDEX IF NOT EXISTS transaction_tags_tag_idx '
              'ON transaction_tags(tag_id)',
        ),
      );
      await m.createIndex(
        Index(
          'categories_type_idx',
          'CREATE INDEX IF NOT EXISTS categories_type_idx '
              'ON categories(type)',
        ),
      );
      await m.createIndex(
        Index(
          'categories_parent_idx',
          'CREATE INDEX IF NOT EXISTS categories_parent_idx '
              'ON categories(parent_id)',
        ),
      );
      await m.createIndex(
        Index(
          'accounts_type_idx',
          'CREATE INDEX IF NOT EXISTS accounts_type_idx '
              'ON accounts(type)',
        ),
      );
      await m.createIndex(
        Index(
          'upcoming_payments_next_notify_idx',
          'CREATE INDEX IF NOT EXISTS upcoming_payments_next_notify_idx '
              'ON upcoming_payments(next_notify_at)',
        ),
      );
      await m.createIndex(
        Index(
          'upcoming_payments_next_run_idx',
          'CREATE INDEX IF NOT EXISTS upcoming_payments_next_run_idx '
              'ON upcoming_payments(next_run_at)',
        ),
      );
      await m.createIndex(
        Index(
          'upcoming_payments_day_idx',
          'CREATE INDEX IF NOT EXISTS upcoming_payments_day_idx '
              'ON upcoming_payments(day_of_month)',
        ),
      );
      await m.createIndex(
        Index(
          'payment_reminders_when_idx',
          'CREATE INDEX IF NOT EXISTS payment_reminders_when_idx '
              'ON payment_reminders(when_at)',
        ),
      );
      await m.createIndex(
        Index(
          'credit_cards_account_id_idx',
          'CREATE INDEX IF NOT EXISTS credit_cards_account_id_idx '
              'ON credit_cards(account_id)',
        ),
      );
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(outboxEntries);
        await m.addColumn(accounts, accounts.createdAt);
        await m.addColumn(accounts, accounts.updatedAt);
        await m.addColumn(accounts, accounts.isDeleted);
        await m.addColumn(categories, categories.createdAt);
        await m.addColumn(categories, categories.updatedAt);
        await m.addColumn(categories, categories.isDeleted);
        await m.addColumn(transactions, transactions.createdAt);
        await m.addColumn(transactions, transactions.updatedAt);
        await m.addColumn(transactions, transactions.isDeleted);
      }
      if (from < 31) {
        if (!await _columnExists('accounts', 'opening_balance')) {
          await m.addColumn(accounts, accounts.openingBalance);
        }
        await m.database.customStatement('''
UPDATE accounts
SET opening_balance = balance - (
  COALESCE((SELECT SUM(CASE WHEN type = 'income' THEN ABS(amount) ELSE 0 END)
            FROM transactions
            WHERE is_deleted = 0 AND account_id = accounts.id), 0)
  - COALESCE((SELECT SUM(CASE WHEN type = 'expense' THEN ABS(amount) ELSE 0 END)
              FROM transactions
              WHERE is_deleted = 0 AND account_id = accounts.id), 0)
  - COALESCE((SELECT SUM(CASE WHEN type = 'transfer' THEN ABS(amount) ELSE 0 END)
              FROM transactions
              WHERE is_deleted = 0 AND account_id = accounts.id), 0)
  + COALESCE((SELECT SUM(CASE WHEN type = 'transfer' THEN ABS(amount) ELSE 0 END)
              FROM transactions
              WHERE is_deleted = 0 AND transfer_account_id = accounts.id), 0)
)
''');
      }
      if (from < 32) {
        if (!await _columnExists('accounts', 'balance_minor')) {
          await m.addColumn(accounts, accounts.balanceMinor);
        }
        if (!await _columnExists('accounts', 'opening_balance_minor')) {
          await m.addColumn(accounts, accounts.openingBalanceMinor);
        }
        if (!await _columnExists('accounts', 'currency_scale')) {
          await m.addColumn(accounts, accounts.currencyScale);
        }
        if (!await _columnExists('transactions', 'amount_minor')) {
          await m.addColumn(transactions, transactions.amountMinor);
        }
        if (!await _columnExists('transactions', 'amount_scale')) {
          await m.addColumn(transactions, transactions.amountScale);
        }

        if (await _columnExists('accounts', 'balance_minor') &&
            await _columnExists('accounts', 'opening_balance_minor') &&
            await _columnExists('accounts', 'currency_scale')) {
          final List<QueryRow> accountRows = await m.database
              .customSelect(
                'SELECT id, currency, balance, opening_balance FROM accounts',
              )
              .get();
          final Map<String, int> scalesByAccount = <String, int>{};
          for (final QueryRow row in accountRows) {
            final String accountId = row.read<String>('id');
            final String currency = row.read<String>('currency');
            final double balance = row.read<double>('balance');
            final double openingBalance = row.read<double>('opening_balance');
            final int scale = resolveCurrencyScale(currency);
            scalesByAccount[accountId] = scale;
            final Money balanceMoney = Money.fromDouble(
              balance,
              currency: currency,
              scale: scale,
            );
            final Money openingMoney = Money.fromDouble(
              openingBalance,
              currency: currency,
              scale: scale,
            );
            await m.database.customStatement(
              'UPDATE accounts SET balance_minor = ?, opening_balance_minor = ?, currency_scale = ? WHERE id = ?',
              <Object?>[
                balanceMoney.minor.toString(),
                openingMoney.minor.toString(),
                scale,
                accountId,
              ],
            );
          }

          if (await _columnExists('transactions', 'amount_minor') &&
              await _columnExists('transactions', 'amount_scale')) {
            final List<QueryRow> transactionRows = await m.database
                .customSelect('SELECT id, account_id, amount FROM transactions')
                .get();
            for (final QueryRow row in transactionRows) {
              final String transactionId = row.read<String>('id');
              final String accountId = row.read<String>('account_id');
              final double amount = row.read<double>('amount');
              final int scale = scalesByAccount[accountId] ?? 2;
              final Money money = Money.fromDouble(
                amount.abs(),
                currency: 'XXX',
                scale: scale,
              );
              await m.database.customStatement(
                'UPDATE transactions SET amount_minor = ?, amount_scale = ? WHERE id = ?',
                <Object?>[money.minor.toString(), scale, transactionId],
              );
            }
          }
        }
      }
      if (from < 33) {
        final bool hasBudgetsTable = await _tableExists('budgets');
        final bool hasBudgetInstancesTable = await _tableExists(
          'budget_instances',
        );
        final bool hasUpcomingPaymentsTable = await _tableExists(
          'upcoming_payments',
        );
        final bool hasPaymentRemindersTable = await _tableExists(
          'payment_reminders',
        );

        if (hasBudgetsTable &&
            !await _columnExists('budgets', 'amount_minor')) {
          await m.addColumn(budgets, budgets.amountMinor);
        }
        if (hasBudgetsTable &&
            !await _columnExists('budgets', 'amount_scale')) {
          await m.addColumn(budgets, budgets.amountScale);
        }
        if (hasBudgetInstancesTable &&
            !await _columnExists('budget_instances', 'amount_minor')) {
          await m.addColumn(budgetInstances, budgetInstances.amountMinor);
        }
        if (hasBudgetInstancesTable &&
            !await _columnExists('budget_instances', 'spent_minor')) {
          await m.addColumn(budgetInstances, budgetInstances.spentMinor);
        }
        if (hasBudgetInstancesTable &&
            !await _columnExists('budget_instances', 'amount_scale')) {
          await m.addColumn(budgetInstances, budgetInstances.amountScale);
        }
        if (hasUpcomingPaymentsTable &&
            !await _columnExists('upcoming_payments', 'amount_minor')) {
          await m.addColumn(upcomingPayments, upcomingPayments.amountMinor);
        }
        if (hasUpcomingPaymentsTable &&
            !await _columnExists('upcoming_payments', 'amount_scale')) {
          await m.addColumn(upcomingPayments, upcomingPayments.amountScale);
        }
        if (hasPaymentRemindersTable &&
            !await _columnExists('payment_reminders', 'amount_minor')) {
          await m.addColumn(paymentReminders, paymentReminders.amountMinor);
        }
        if (hasPaymentRemindersTable &&
            !await _columnExists('payment_reminders', 'amount_scale')) {
          await m.addColumn(paymentReminders, paymentReminders.amountScale);
        }

        if (hasBudgetsTable &&
            hasBudgetInstancesTable &&
            hasUpcomingPaymentsTable &&
            hasPaymentRemindersTable &&
            await _columnExists('budgets', 'amount_minor') &&
            await _columnExists('budgets', 'amount_scale') &&
            await _columnExists('budget_instances', 'amount_minor') &&
            await _columnExists('budget_instances', 'spent_minor') &&
            await _columnExists('budget_instances', 'amount_scale') &&
            await _columnExists('upcoming_payments', 'amount_minor') &&
            await _columnExists('upcoming_payments', 'amount_scale') &&
            await _columnExists('payment_reminders', 'amount_minor') &&
            await _columnExists('payment_reminders', 'amount_scale')) {
          final int defaultScale = await _resolveDefaultCurrencyScale(m);

          final List<QueryRow> budgetRows = await m.database
              .customSelect('SELECT id, amount FROM budgets')
              .get();
          for (final QueryRow row in budgetRows) {
            final String id = row.read<String>('id');
            final double amount = row.read<double>('amount');
            final Money money = Money.fromDouble(
              amount,
              currency: 'XXX',
              scale: defaultScale,
            );
            await m.database.customStatement(
              'UPDATE budgets SET amount_minor = ?, amount_scale = ? WHERE id = ?',
              <Object?>[money.minor.toString(), defaultScale, id],
            );
          }

          final List<QueryRow> instanceRows = await m.database
              .customSelect('SELECT id, amount, spent FROM budget_instances')
              .get();
          for (final QueryRow row in instanceRows) {
            final String id = row.read<String>('id');
            final double amount = row.read<double>('amount');
            final double spent = row.read<double>('spent');
            final Money amountMoney = Money.fromDouble(
              amount,
              currency: 'XXX',
              scale: defaultScale,
            );
            final Money spentMoney = Money.fromDouble(
              spent,
              currency: 'XXX',
              scale: defaultScale,
            );
            await m.database.customStatement(
              'UPDATE budget_instances SET amount_minor = ?, spent_minor = ?, amount_scale = ? WHERE id = ?',
              <Object?>[
                amountMoney.minor.toString(),
                spentMoney.minor.toString(),
                defaultScale,
                id,
              ],
            );
          }

          final List<QueryRow> upcomingRows = await m.database.customSelect('''
SELECT up.id AS id, up.amount AS amount, acc.currency AS currency
FROM upcoming_payments up
LEFT JOIN accounts acc ON up.account_id = acc.id
''').get();
          for (final QueryRow row in upcomingRows) {
            final String id = row.read<String>('id');
            final double amount = row.read<double>('amount');
            final String? currency = row.read<String?>('currency');
            final int scale = currency != null
                ? resolveCurrencyScale(currency)
                : defaultScale;
            final Money money = Money.fromDouble(
              amount,
              currency: currency ?? 'XXX',
              scale: scale,
            );
            await m.database.customStatement(
              'UPDATE upcoming_payments SET amount_minor = ?, amount_scale = ? WHERE id = ?',
              <Object?>[money.minor.toString(), scale, id],
            );
          }

          final List<QueryRow> reminderRows = await m.database
              .customSelect('SELECT id, amount FROM payment_reminders')
              .get();
          for (final QueryRow row in reminderRows) {
            final String id = row.read<String>('id');
            final double amount = row.read<double>('amount');
            final Money money = Money.fromDouble(
              amount,
              currency: 'XXX',
              scale: defaultScale,
            );
            await m.database.customStatement(
              'UPDATE payment_reminders SET amount_minor = ?, amount_scale = ? WHERE id = ?',
              <Object?>[money.minor.toString(), defaultScale, id],
            );
          }
        }
      }
      if (from < 34) {
        final List<QueryRow> accountRows = await m.database
            .customSelect('SELECT id, currency, currency_scale FROM accounts')
            .get();
        final Map<String, int> scalesByAccount = <String, int>{};
        for (final QueryRow row in accountRows) {
          final String accountId = row.read<String>('id');
          final String currency = row.read<String>('currency');
          final int? scaleValue = row.read<int?>('currency_scale');
          final int scale = scaleValue ?? resolveCurrencyScale(currency);
          scalesByAccount[accountId] = scale;
        }

        if (await _tableExists('debts')) {
          if (!await _columnExists('debts', 'amount_minor')) {
            await m.addColumn(debts, debts.amountMinor);
          }
          if (!await _columnExists('debts', 'amount_scale')) {
            await m.addColumn(debts, debts.amountScale);
          }
          final List<QueryRow> debtRows = await m.database
              .customSelect('SELECT id, account_id, amount FROM debts')
              .get();
          for (final QueryRow row in debtRows) {
            final String id = row.read<String>('id');
            final String accountId = row.read<String>('account_id');
            final double amount = row.read<double>('amount');
            final int scale = scalesByAccount[accountId] ?? 2;
            final Money money = Money.fromDouble(
              amount,
              currency: 'XXX',
              scale: scale,
            );
            await m.database.customStatement(
              'UPDATE debts SET amount_minor = ?, amount_scale = ? WHERE id = ?',
              <Object?>[money.minor.toString(), scale, id],
            );
          }
        }

        if (await _tableExists('credits')) {
          if (!await _columnExists('credits', 'total_amount_minor')) {
            await m.addColumn(credits, credits.totalAmountMinor);
          }
          if (!await _columnExists('credits', 'total_amount_scale')) {
            await m.addColumn(credits, credits.totalAmountScale);
          }
          final List<QueryRow> creditRows = await m.database
              .customSelect('SELECT id, account_id, total_amount FROM credits')
              .get();
          for (final QueryRow row in creditRows) {
            final String id = row.read<String>('id');
            final String accountId = row.read<String>('account_id');
            final double totalAmount = row.read<double>('total_amount');
            final int scale = scalesByAccount[accountId] ?? 2;
            final Money money = Money.fromDouble(
              totalAmount,
              currency: 'XXX',
              scale: scale,
            );
            await m.database.customStatement(
              'UPDATE credits SET total_amount_minor = ?, total_amount_scale = ? WHERE id = ?',
              <Object?>[money.minor.toString(), scale, id],
            );
          }
        }

        if (await _tableExists('credit_cards')) {
          if (!await _columnExists('credit_cards', 'credit_limit_minor')) {
            await m.addColumn(creditCards, creditCards.creditLimitMinor);
          }
          if (!await _columnExists('credit_cards', 'credit_limit_scale')) {
            await m.addColumn(creditCards, creditCards.creditLimitScale);
          }
          final List<QueryRow> cardRows = await m.database
              .customSelect(
                'SELECT id, account_id, credit_limit FROM credit_cards',
              )
              .get();
          for (final QueryRow row in cardRows) {
            final String id = row.read<String>('id');
            final String accountId = row.read<String>('account_id');
            final double creditLimit = row.read<double>('credit_limit');
            final int scale = scalesByAccount[accountId] ?? 2;
            final Money money = Money.fromDouble(
              creditLimit,
              currency: 'XXX',
              scale: scale,
            );
            await m.database.customStatement(
              'UPDATE credit_cards SET credit_limit_minor = ?, credit_limit_scale = ? WHERE id = ?',
              <Object?>[money.minor.toString(), scale, id],
            );
          }
        }
      }
      if (from < 35) {
        await m.createIndex(
          Index(
            'transactions_account_date_type_idx',
            'CREATE INDEX IF NOT EXISTS transactions_account_date_type_idx '
                'ON transactions(account_id, date, type)',
          ),
        );
        await m.createIndex(
          Index(
            'transactions_category_date_idx',
            'CREATE INDEX IF NOT EXISTS transactions_category_date_idx '
                'ON transactions(category_id, date)',
          ),
        );
        await m.createIndex(
          Index(
            'transactions_transfer_account_idx',
            'CREATE INDEX IF NOT EXISTS transactions_transfer_account_idx '
                'ON transactions(transfer_account_id)',
          ),
        );
        await m.createIndex(
          Index(
            'categories_parent_idx',
            'CREATE INDEX IF NOT EXISTS categories_parent_idx '
                'ON categories(parent_id)',
          ),
        );
      }
      if (from < 3) {
        await m.createTable(profiles);
      }
      if (from < 12) {
        await m.addColumn(profiles, profiles.photoUrl);
      }
      if (from < 4) {
        await m.addColumn(categories, categories.iconStyle);
        await m.addColumn(categories, categories.iconName);
        await m.addColumn(categories, categories.parentId);
        await m.database.customStatement(
          "UPDATE categories SET icon_name = icon WHERE icon_name IS NULL AND icon IS NOT NULL AND icon != ''",
        );
        await m.database.customStatement(
          "UPDATE categories SET icon_style = 'regular' WHERE icon_name IS NOT NULL AND (icon_style IS NULL OR icon_style = '')",
        );
      }
      if (from < 8) {
        final bool hasBudgetsTable = await _tableExists('budgets');
        if (!hasBudgetsTable) {
          await m.createTable(budgets);
        }
        final bool hasBudgetInstancesTable = await _tableExists(
          'budget_instances',
        );
        if (!hasBudgetInstancesTable) {
          await m.createTable(budgetInstances);
        }
        await m.createIndex(
          Index(
            'budget_instances_budget_period_idx',
            'CREATE INDEX IF NOT EXISTS budget_instances_budget_period_idx '
                'ON budget_instances(budget_id, period_start)',
          ),
        );
      }
      if (from < 9) {
        await m.createTable(savingGoals);
        await m.createIndex(
          Index(
            'saving_goals_status_updated_idx',
            'CREATE INDEX IF NOT EXISTS saving_goals_status_updated_idx '
                'ON saving_goals(archived_at, updated_at DESC)',
          ),
        );
      }
      if (from < 10) {
        await m.addColumn(categories, categories.isSystem);
        await m.addColumn(transactions, transactions.savingGoalId);
        await m.createTable(goalContributions);
        await m.createIndex(
          Index(
            'categories_name_unique',
            'CREATE UNIQUE INDEX IF NOT EXISTS categories_name_unique '
                'ON categories(name)',
          ),
        );
        await m.createIndex(
          Index(
            'goal_contributions_goal_idx',
            'CREATE INDEX IF NOT EXISTS goal_contributions_goal_idx '
                'ON goal_contributions(goal_id)',
          ),
        );
        await m.createIndex(
          Index(
            'transactions_saving_goal_idx',
            'CREATE INDEX IF NOT EXISTS transactions_saving_goal_idx '
                'ON transactions(saving_goal_id)',
          ),
        );
      }
      if (from < 11) {
        await m.createIndex(
          Index(
            'transactions_date_account_category_idx',
            'CREATE INDEX IF NOT EXISTS transactions_date_account_category_idx '
                'ON transactions(date, account_id, category_id)',
          ),
        );
        await m.createIndex(
          Index(
            'categories_type_idx',
            'CREATE INDEX IF NOT EXISTS categories_type_idx '
                'ON categories(type)',
          ),
        );
        await m.createIndex(
          Index(
            'accounts_type_idx',
            'CREATE INDEX IF NOT EXISTS accounts_type_idx '
                'ON accounts(type)',
          ),
        );
      }
      if (from < 13) {
        await m.addColumn(accounts, accounts.isPrimary);
        await m.addColumn(categories, categories.isFavorite);
      }
      if (from < 15) {
        await m.createTable(upcomingPayments);
        await m.createTable(paymentReminders);
        await m.createIndex(
          Index(
            'upcoming_payments_next_notify_idx',
            'CREATE INDEX IF NOT EXISTS upcoming_payments_next_notify_idx '
                'ON upcoming_payments(next_notify_at)',
          ),
        );
        await m.createIndex(
          Index(
            'upcoming_payments_next_run_idx',
            'CREATE INDEX IF NOT EXISTS upcoming_payments_next_run_idx '
                'ON upcoming_payments(next_run_at)',
          ),
        );
        await m.createIndex(
          Index(
            'upcoming_payments_day_idx',
            'CREATE INDEX IF NOT EXISTS upcoming_payments_day_idx '
                'ON upcoming_payments(day_of_month)',
          ),
        );
        await m.createIndex(
          Index(
            'payment_reminders_when_idx',
            'CREATE INDEX IF NOT EXISTS payment_reminders_when_idx '
                'ON payment_reminders(when_at)',
          ),
        );
      }
      if (from < 16) {
        await _ensureUpcomingPaymentsIndexes();
      }
      if (from < 17) {
        final bool hasLastNotifiedColumn = await _columnExists(
          'payment_reminders',
          'last_notified_at',
        );
        if (!hasLastNotifiedColumn) {
          await m.addColumn(paymentReminders, paymentReminders.lastNotifiedAt);
        }
      }
      if (from < 18) {
        final bool hasCategoryAllocations = await _columnExists(
          'budgets',
          'category_allocations',
        );
        if (!hasCategoryAllocations) {
          await m.addColumn(budgets, budgets.categoryAllocations);
          await m.database.customStatement(
            "UPDATE budgets SET category_allocations = '[]' "
            "WHERE category_allocations IS NULL OR category_allocations = ''",
          );
        }
      }
      if (from < 19) {
        final bool hasColorColumn = await _columnExists('accounts', 'color');
        if (!hasColorColumn) {
          await m.addColumn(accounts, accounts.color);
        }
      }
      if (from < 20) {
        await m.createTable(credits);
        final bool hasIsHiddenColumn = await _columnExists(
          'accounts',
          'is_hidden',
        );
        if (!hasIsHiddenColumn) {
          await m.addColumn(accounts, accounts.isHidden);
        }
      }
      if (from < 21) {
        if (!await _columnExists('accounts', 'icon_name')) {
          await m.addColumn(accounts, accounts.iconName);
        }
        if (!await _columnExists('accounts', 'icon_style')) {
          await m.addColumn(accounts, accounts.iconStyle);
        }
      }
      if (from < 22) {
        if (!await _tableExists('credits')) {
          await m.createTable(credits);
        }
        if (!await _columnExists('categories', 'icon_name')) {
          await m.addColumn(categories, categories.iconName);
        }
        if (!await _columnExists('categories', 'icon_style')) {
          await m.addColumn(categories, categories.iconStyle);
        }
        if (!await _columnExists('credits', 'category_id')) {
          await m.addColumn(credits, credits.categoryId);
        }
      }
      if (from < 24) {
        await m.database.customStatement(
          'DROP TABLE IF EXISTS recurring_rule_executions',
        );
        await m.database.customStatement(
          'DROP TABLE IF EXISTS recurring_occurrences',
        );
        await m.database.customStatement(
          'DROP TABLE IF EXISTS recurring_rules',
        );
        await m.database.customStatement('DROP TABLE IF EXISTS job_queue');
      }
      if (from < 23) {
        if (!await _columnExists('credits', 'payment_day')) {
          await m.addColumn(credits, credits.paymentDay);
        }
      }
      if (from < 25) {
        if (!await _tableExists('debts')) {
          await m.createTable(debts);
        }
      }
      if (from < 26) {
        if (!await _columnExists('debts', 'name')) {
          await m.addColumn(debts, debts.name);
        }
      }
      if (from < 27) {
        if (!await _columnExists('accounts', 'gradient_id')) {
          await m.addColumn(accounts, accounts.gradientId);
        }
      }
      if (from < 28) {
        if (!await _columnExists('transactions', 'transfer_account_id')) {
          await m.addColumn(transactions, transactions.transferAccountId);
        }
      }
      if (from < 29) {
        if (!await _tableExists('credit_cards')) {
          await m.createTable(creditCards);
        }
        await m.createIndex(
          Index(
            'credit_cards_account_id_idx',
            'CREATE INDEX IF NOT EXISTS credit_cards_account_id_idx '
                'ON credit_cards(account_id)',
          ),
        );
      }
      if (from < 30) {
        if (!await _tableExists('tags')) {
          await m.createTable(tags);
        }
        if (!await _tableExists('transaction_tags')) {
          await m.createTable(transactionTags);
        }
        await m.createIndex(
          Index(
            'transaction_tags_transaction_idx',
            'CREATE INDEX IF NOT EXISTS transaction_tags_transaction_idx '
                'ON transaction_tags(transaction_id)',
          ),
        );
        await m.createIndex(
          Index(
            'transaction_tags_tag_idx',
            'CREATE INDEX IF NOT EXISTS transaction_tags_tag_idx '
                'ON transaction_tags(tag_id)',
          ),
        );
      }
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _ensureUpcomingPaymentsIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS upcoming_payments_next_notify_idx '
      'ON upcoming_payments(next_notify_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS upcoming_payments_next_run_idx '
      'ON upcoming_payments(next_run_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS upcoming_payments_day_idx '
      'ON upcoming_payments(day_of_month)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS payment_reminders_when_idx '
      'ON payment_reminders(when_at)',
    );
  }

  Future<bool> _columnExists(String table, String column) async {
    final List<QueryRow> columns = await customSelect(
      'PRAGMA table_info($table)',
    ).get();
    for (final QueryRow row in columns) {
      if (row.read<String>('name') == column) {
        return true;
      }
    }
    return false;
  }

  Future<bool> _tableExists(String table) async {
    final QueryRow? row = await customSelect(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ? LIMIT 1",
      variables: <Variable<String>>[Variable<String>(table)],
    ).getSingleOrNull();
    return row != null;
  }

  static Future<int> _resolveDefaultCurrencyScale(Migrator m) async {
    try {
      final List<QueryRow> rows = await m.database
          .customSelect('SELECT currency FROM profiles LIMIT 1')
          .get();
      if (rows.isNotEmpty) {
        final String? currency = rows.first.read<String?>('currency');
        if (currency != null && currency.isNotEmpty) {
          return resolveCurrencyScale(currency);
        }
      }
    } catch (_) {
      // ignore: fallback to default scale
    }
    return 2;
  }
}
