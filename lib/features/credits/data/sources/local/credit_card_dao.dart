import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';

class CreditCardDao {
  CreditCardDao(this._db);

  final db.AppDatabase _db;

  Stream<List<db.CreditCardRow>> watchActiveCreditCards() {
    final SimpleSelectStatement<db.CreditCards, db.CreditCardRow> query =
        _db.select(_db.creditCards)
          ..where((db.CreditCards tbl) => tbl.isDeleted.equals(false));
    return query.watch();
  }

  Future<List<db.CreditCardRow>> getActiveCreditCards() {
    final SimpleSelectStatement<db.CreditCards, db.CreditCardRow> query =
        _db.select(_db.creditCards)
          ..where((db.CreditCards tbl) => tbl.isDeleted.equals(false));
    return query.get();
  }

  Future<List<db.CreditCardRow>> getAllCreditCards() {
    return _db.select(_db.creditCards).get();
  }

  Future<db.CreditCardRow?> findById(String id) {
    final SimpleSelectStatement<db.CreditCards, db.CreditCardRow> query =
        _db.select(_db.creditCards)
          ..where((db.CreditCards tbl) => tbl.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<db.CreditCardRow?> findByAccountId(String accountId) {
    final SimpleSelectStatement<db.CreditCards, db.CreditCardRow> query =
        _db.select(_db.creditCards)
          ..where((db.CreditCards tbl) => tbl.accountId.equals(accountId));
    return query.getSingleOrNull();
  }

  Future<void> upsert(CreditCardEntity creditCard) {
    return _db
        .into(_db.creditCards)
        .insertOnConflictUpdate(_mapToCompanion(creditCard));
  }

  Future<void> upsertAll(List<CreditCardEntity> creditCards) {
    if (creditCards.isEmpty) return Future<void>.value();
    return _db.batch((Batch batch) {
      batch.insertAllOnConflictUpdate(
        _db.creditCards,
        creditCards.map(_mapToCompanion).toList(),
      );
    });
  }

  Future<void> markDeleted(String id, DateTime deletedAt) async {
    final UpdateStatement<db.CreditCards, db.CreditCardRow> query = _db.update(
      _db.creditCards,
    )..where((db.CreditCards tbl) => tbl.id.equals(id));
    await query.write(
      db.CreditCardsCompanion(
        isDeleted: const Value<bool>(true),
        updatedAt: Value<DateTime>(deletedAt),
      ),
    );
  }

  db.CreditCardsCompanion _mapToCompanion(CreditCardEntity creditCard) {
    final int scale =
        (creditCard.creditLimitScale ?? 0) > 0
            ? creditCard.creditLimitScale!
            : 2;
    final BigInt creditLimitMinor =
        creditCard.creditLimitMinor ??
        Money.fromDouble(creditCard.creditLimit, currency: 'XXX', scale: scale)
            .minor;
    return db.CreditCardsCompanion(
      id: Value<String>(creditCard.id),
      accountId: Value<String>(creditCard.accountId),
      creditLimit: Value<double>(creditCard.creditLimit),
      creditLimitMinor: Value<String>(creditLimitMinor.toString()),
      creditLimitScale: Value<int>(scale),
      statementDay: Value<int>(creditCard.statementDay),
      paymentDueDays: Value<int>(creditCard.paymentDueDays),
      interestRateAnnual: Value<double>(creditCard.interestRateAnnual),
      createdAt: Value<DateTime>(creditCard.createdAt),
      updatedAt: Value<DateTime>(creditCard.updatedAt),
      isDeleted: Value<bool>(creditCard.isDeleted),
    );
  }

  CreditCardEntity mapRowToEntity(db.CreditCardRow row) {
    return CreditCardEntity(
      id: row.id,
      accountId: row.accountId,
      creditLimit: row.creditLimit,
      creditLimitMinor: BigInt.parse(row.creditLimitMinor),
      creditLimitScale: row.creditLimitScale,
      statementDay: row.statementDay,
      paymentDueDays: row.paymentDueDays,
      interestRateAnnual: row.interestRateAnnual,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
    );
  }
}
