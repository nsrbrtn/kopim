import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';

class AccountDao {
  AccountDao(this._db);

  final db.AppDatabase _db;

  Stream<List<db.AccountRow>> watchActiveAccounts() {
    final SimpleSelectStatement<db.$AccountsTable, db.AccountRow> query =
        _db.select(_db.accounts)
          ..where((db.$AccountsTable tbl) => tbl.isDeleted.equals(false));
    return query.watch();
  }

  Future<List<db.AccountRow>> getActiveAccounts() {
    final SimpleSelectStatement<db.$AccountsTable, db.AccountRow> query =
        _db.select(_db.accounts)
          ..where((db.$AccountsTable tbl) => tbl.isDeleted.equals(false));
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

  Future<void> upsertAll(List<AccountEntity> accounts) async {
    if (accounts.isEmpty) return;
    await _db.batch((Batch batch) {
      batch.insertAllOnConflictUpdate(
        _db.accounts,
        accounts.map(_mapToCompanion).toList(),
      );
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
    return db.AccountsCompanion(
      id: Value<String>(account.id),
      name: Value<String>(account.name),
      balance: Value<double>(account.balance),
      currency: Value<String>(account.currency),
      type: Value<String>(account.type),
      createdAt: Value<DateTime>(account.createdAt),
      updatedAt: Value<DateTime>(account.updatedAt),
      isDeleted: Value<bool>(account.isDeleted),
    );
  }

  AccountEntity _mapRowToEntity(db.AccountRow row) {
    return AccountEntity(
      id: row.id,
      name: row.name,
      balance: row.balance,
      currency: row.currency,
      type: row.type,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
    );
  }
}
