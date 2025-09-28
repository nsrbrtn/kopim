import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';

class AccountDao {
  AccountDao(this._db);

  final db.AppDatabase _db;

  Stream<List<db.AccountRow>> watchActiveAccounts() {
    final query = _db.select(_db.accounts)
      ..where((tbl) => tbl.isDeleted.equals(false));
    return query.watch();
  }

  Future<List<db.AccountRow>> getActiveAccounts() {
    final query = _db.select(_db.accounts)
      ..where((tbl) => tbl.isDeleted.equals(false));
    return query.get();
  }

  Future<db.AccountRow?> findById(String id) {
    final query = _db.select(_db.accounts)..where((tbl) => tbl.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<void> upsert(AccountEntity account) {
    return _db
        .into(_db.accounts)
        .insertOnConflictUpdate(_mapToCompanion(account));
  }

  Future<void> upsertAll(List<AccountEntity> accounts) async {
    if (accounts.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.accounts,
        accounts.map(_mapToCompanion).toList(),
      );
    });
  }

  Future<void> markDeleted(String id, DateTime deletedAt) async {
    await (_db.update(_db.accounts)..where((tbl) => tbl.id.equals(id))).write(
      db.AccountsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(deletedAt),
      ),
    );
  }

  db.AccountsCompanion _mapToCompanion(AccountEntity account) {
    return db.AccountsCompanion(
      id: Value(account.id),
      name: Value(account.name),
      balance: Value(account.balance),
      currency: Value(account.currency),
      type: Value(account.type),
      createdAt: Value(account.createdAt),
      updatedAt: Value(account.updatedAt),
      isDeleted: Value(account.isDeleted),
    );
  }
}
