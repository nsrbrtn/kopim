import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';

class AccountDao {
  AccountDao(this._db);

  final db.AppDatabase _db;

  Stream<List<db.AccountRow>> watchActiveAccounts() {
    final SimpleSelectStatement<db.$AccountsTable, db.AccountRow> query =
        _db.select(_db.accounts)
          ..where((db.$AccountsTable tbl) => tbl.isDeleted.equals(false));
    query.orderBy(<OrderingTerm Function(db.$AccountsTable tbl)>[
      (db.$AccountsTable tbl) =>
          OrderingTerm(expression: tbl.isPrimary, mode: OrderingMode.desc),
      (db.$AccountsTable tbl) =>
          OrderingTerm(expression: tbl.name, mode: OrderingMode.asc),
    ]);
    return query.watch();
  }

  Future<List<db.AccountRow>> getActiveAccounts() {
    final SimpleSelectStatement<db.$AccountsTable, db.AccountRow> query =
        _db.select(_db.accounts)
          ..where((db.$AccountsTable tbl) => tbl.isDeleted.equals(false))
          ..orderBy(<OrderingTerm Function(db.$AccountsTable tbl)>[
            (db.$AccountsTable tbl) => OrderingTerm(
              expression: tbl.isPrimary,
              mode: OrderingMode.desc,
            ),
            (db.$AccountsTable tbl) =>
                OrderingTerm(expression: tbl.name, mode: OrderingMode.asc),
          ]);
    return query.get();
  }

  Future<List<AccountEntity>> getAllAccounts() async {
    final List<db.AccountRow> rows = await _db.select(_db.accounts).get();
    return rows.map(_mapRowToEntity).toList();
  }

  Future<db.AccountRow?> findById(String id) {
    final SimpleSelectStatement<db.$AccountsTable, db.AccountRow> query =
        _db.select(_db.accounts)
          ..where((db.$AccountsTable tbl) => tbl.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<void> upsert(AccountEntity account) {
    return _db
        .into(_db.accounts)
        .insertOnConflictUpdate(_mapToCompanion(account));
  }

  Future<void> clearPrimaryExcept(String accountId, DateTime updatedAt) async {
    await (_db.update(_db.accounts)..where(
          (db.$AccountsTable tbl) =>
              tbl.id.equals(accountId).not() & tbl.isPrimary.equals(true),
        ))
        .write(
          db.AccountsCompanion(
            isPrimary: const Value<bool>(false),
            updatedAt: Value<DateTime>(updatedAt),
          ),
        );
  }

  Future<void> upsertAll(List<AccountEntity> accounts) async {
    if (accounts.isEmpty) return;
    await _db.transaction(() async {
      await _db.batch((Batch batch) {
        batch.insertAllOnConflictUpdate(
          _db.accounts,
          accounts.map(_mapToCompanion).toList(),
        );
      });
    });
  }

  Future<void> markDeleted(String id, DateTime deletedAt) async {
    await (_db.update(
      _db.accounts,
    )..where((db.$AccountsTable tbl) => tbl.id.equals(id))).write(
      db.AccountsCompanion(
        isDeleted: const Value<bool>(true),
        updatedAt: Value<DateTime>(deletedAt),
      ),
    );
  }

  db.AccountsCompanion _mapToCompanion(AccountEntity account) {
    final int scale =
        account.currencyScale ?? resolveCurrencyScale(account.currency);
    final MoneyAmount balance = account.balanceAmount;
    final MoneyAmount opening = account.openingBalanceAmount;
    final Money balanceMoney = Money(
      minor: balance.minor,
      currency: account.currency,
      scale: scale,
    );
    final Money openingMoney = Money(
      minor: opening.minor,
      currency: account.currency,
      scale: scale,
    );
    return db.AccountsCompanion(
      id: Value<String>(account.id),
      name: Value<String>(account.name),
      balance: Value<double>(balanceMoney.toDouble()),
      balanceMinor: Value<String>(balance.minor.toString()),
      openingBalance: Value<double>(openingMoney.toDouble()),
      openingBalanceMinor: Value<String>(opening.minor.toString()),
      currency: Value<String>(account.currency),
      currencyScale: Value<int>(scale),
      type: Value<String>(account.type),
      color: Value<String?>(account.color),
      gradientId: Value<String?>(account.gradientId),
      createdAt: Value<DateTime>(account.createdAt),
      updatedAt: Value<DateTime>(account.updatedAt),
      isDeleted: Value<bool>(account.isDeleted),
      isPrimary: Value<bool>(account.isPrimary),
      isHidden: Value<bool>(account.isHidden),
      iconName: Value<String?>(account.iconName),
      iconStyle: Value<String?>(account.iconStyle),
    );
  }

  AccountEntity _mapRowToEntity(db.AccountRow row) {
    return AccountEntity(
      id: row.id,
      name: row.name,
      balanceMinor: BigInt.parse(row.balanceMinor),
      openingBalanceMinor: BigInt.parse(row.openingBalanceMinor),
      currency: row.currency,
      currencyScale: row.currencyScale,
      type: row.type,
      color: row.color,
      gradientId: row.gradientId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
      isPrimary: row.isPrimary,
      isHidden: row.isHidden,
      iconName: row.iconName,
      iconStyle: row.iconStyle,
    );
  }
}
