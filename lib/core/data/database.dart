// lib/core/data/database.dart
import 'package:drift/drift.dart';
import 'package:kopim/core/data/converters/json_map_list_converter.dart';
import 'package:kopim/core/data/converters/string_list_converter.dart';
import 'package:kopim/features/upcoming_payments/data/drift/tables/payment_reminders_table.dart';
import 'package:kopim/features/upcoming_payments/data/drift/tables/upcoming_payments_table.dart';

part 'database.g.dart';

@DataClassName('AccountRow')
class Accounts extends Table {
  TextColumn get id => text().withLength(min: 1, max: 50)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get balance => real()();
  TextColumn get currency => text().withLength(min: 3, max: 3)();
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
  RealColumn get spent => real().withDefault(const Constant<double>(0))();
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
  int get schemaVersion => 30;

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
}
