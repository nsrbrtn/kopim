import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';

class CreditDao {
  CreditDao(this._db);

  final db.AppDatabase _db;

  Stream<List<db.CreditRow>> watchActiveCredits() {
    final SimpleSelectStatement<db.Credits, db.CreditRow> query = _db.select(
      _db.credits,
    )..where((db.Credits tbl) => tbl.isDeleted.equals(false));
    return query.watch();
  }

  Future<List<db.CreditRow>> getActiveCredits() {
    final SimpleSelectStatement<db.Credits, db.CreditRow> query = _db.select(
      _db.credits,
    )..where((db.Credits tbl) => tbl.isDeleted.equals(false));
    return query.get();
  }

  Future<db.CreditRow?> findById(String id) {
    final SimpleSelectStatement<db.Credits, db.CreditRow> query = _db.select(
      _db.credits,
    )..where((db.Credits tbl) => tbl.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<db.CreditRow?> findByAccountId(String accountId) {
    final SimpleSelectStatement<db.Credits, db.CreditRow> query = _db.select(
      _db.credits,
    )..where((db.Credits tbl) => tbl.accountId.equals(accountId));
    return query.getSingleOrNull();
  }

  Future<db.CreditRow?> findByCategoryId(String categoryId) {
    final SimpleSelectStatement<db.Credits, db.CreditRow> query = _db.select(
      _db.credits,
    )..where((db.Credits tbl) => tbl.categoryId.equals(categoryId));
    return query.getSingleOrNull();
  }

  Future<List<db.CreditRow>> getAllCredits() {
    return _db.select(_db.credits).get();
  }

  Future<void> upsert(CreditEntity credit) {
    return _db
        .into(_db.credits)
        .insertOnConflictUpdate(_mapToCompanion(credit));
  }

  Future<void> upsertAll(List<CreditEntity> credits) {
    if (credits.isEmpty) return Future<void>.value();
    return _db.batch((Batch batch) {
      batch.insertAllOnConflictUpdate(
        _db.credits,
        credits.map(_mapToCompanion).toList(),
      );
    });
  }

  Future<void> markDeleted(String id, DateTime deletedAt) async {
    final UpdateStatement<db.Credits, db.CreditRow> query = _db.update(
      _db.credits,
    )..where((db.Credits tbl) => tbl.id.equals(id));
    await query.write(
      db.CreditsCompanion(
        isDeleted: const Value<bool>(true),
        updatedAt: Value<DateTime>(deletedAt),
      ),
    );
  }

  db.CreditsCompanion _mapToCompanion(CreditEntity credit) {
    final MoneyAmount totalAmount = credit.totalAmountValue;
    final Money money = Money(
      minor: totalAmount.minor,
      currency: 'XXX',
      scale: totalAmount.scale,
    );
    return db.CreditsCompanion(
      id: Value<String>(credit.id),
      accountId: Value<String>(credit.accountId),
      categoryId: Value<String?>(credit.categoryId),
      totalAmount: Value<double>(money.toDouble()),
      totalAmountMinor: Value<String>(totalAmount.minor.toString()),
      totalAmountScale: Value<int>(totalAmount.scale),
      interestRate: Value<double>(credit.interestRate),
      termMonths: Value<int>(credit.termMonths),
      startDate: Value<DateTime>(credit.startDate),
      paymentDay: Value<int>(credit.paymentDay),
      createdAt: Value<DateTime>(credit.createdAt),
      updatedAt: Value<DateTime>(credit.updatedAt),
      isDeleted: Value<bool>(credit.isDeleted),
    );
  }

  CreditEntity mapRowToEntity(db.CreditRow row) {
    return CreditEntity(
      id: row.id,
      accountId: row.accountId,
      categoryId: row.categoryId,
      totalAmountMinor: BigInt.parse(row.totalAmountMinor),
      totalAmountScale: row.totalAmountScale,
      interestRate: row.interestRate,
      termMonths: row.termMonths,
      startDate: row.startDate,
      paymentDay: row.paymentDay,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
    );
  }
}
