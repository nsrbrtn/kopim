import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';

class TransactionTagsDao {
  TransactionTagsDao(this._db);

  final db.AppDatabase _db;

  Stream<List<db.TransactionTagRow>> watchLinksByTransaction(
    String transactionId,
  ) {
    final SimpleSelectStatement<db.$TransactionTagsTable, db.TransactionTagRow>
    query = _db.select(_db.transactionTags)
      ..where(
        (db.$TransactionTagsTable tbl) =>
            tbl.transactionId.equals(transactionId),
      );
    return query.watch();
  }

  Future<List<db.TransactionTagRow>> getLinksByTransaction(
    String transactionId,
  ) {
    final SimpleSelectStatement<db.$TransactionTagsTable, db.TransactionTagRow>
    query = _db.select(_db.transactionTags)
      ..where(
        (db.$TransactionTagsTable tbl) =>
            tbl.transactionId.equals(transactionId),
      );
    return query.get();
  }

  Stream<List<db.TagRow>> watchTagsForTransaction(String transactionId) {
    final List<Join> joins = <Join>[
      innerJoin(
        _db.transactionTags,
        _db.transactionTags.tagId.equalsExp(_db.tags.id),
      ),
    ];
    final List<OrderingTerm> orderBy = <OrderingTerm>[
      OrderingTerm(expression: _db.tags.name),
    ];
    final JoinedSelectStatement<HasResultSet, dynamic> query =
        _db.select(_db.tags).join(joins)
          ..where(_db.tags.isDeleted.equals(false))
          ..where(_db.transactionTags.isDeleted.equals(false))
          ..where(_db.transactionTags.transactionId.equals(transactionId))
          ..orderBy(orderBy);
    return query.watch().map(
      (List<TypedResult> rows) =>
          rows.map((TypedResult row) => row.readTable(_db.tags)).toList(),
    );
  }

  Future<List<db.TagRow>> getTagsForTransaction(String transactionId) async {
    final List<Join> joins = <Join>[
      innerJoin(
        _db.transactionTags,
        _db.transactionTags.tagId.equalsExp(_db.tags.id),
      ),
    ];
    final List<OrderingTerm> orderBy = <OrderingTerm>[
      OrderingTerm(expression: _db.tags.name),
    ];
    final JoinedSelectStatement<HasResultSet, dynamic> query =
        _db.select(_db.tags).join(joins)
          ..where(_db.tags.isDeleted.equals(false))
          ..where(_db.transactionTags.isDeleted.equals(false))
          ..where(_db.transactionTags.transactionId.equals(transactionId))
          ..orderBy(orderBy);
    final List<TypedResult> rows = await query.get();
    return rows
        .map((TypedResult row) => row.readTable(_db.tags))
        .toList();
  }

  Future<List<db.TransactionTagRow>> getAllTransactionTags() {
    return _db.select(_db.transactionTags).get();
  }

  Future<void> upsert(TransactionTagEntity link) {
    return _db
        .into(_db.transactionTags)
        .insertOnConflictUpdate(_mapToCompanion(link));
  }

  Future<void> upsertAll(List<TransactionTagEntity> links) async {
    if (links.isEmpty) return;
    await _db.transaction(() async {
      await _db.batch((Batch batch) {
        batch.insertAllOnConflictUpdate(
          _db.transactionTags,
          links.map(_mapToCompanion).toList(),
        );
      });
    });
  }

  Future<void> markDeleted({
    required String transactionId,
    required String tagId,
    required DateTime updatedAt,
  }) async {
    await (_db.update(
      _db.transactionTags,
    )..where(
            (db.$TransactionTagsTable tbl) =>
                tbl.transactionId.equals(transactionId) &
                tbl.tagId.equals(tagId),
          ))
        .write(
          db.TransactionTagsCompanion(
            isDeleted: const Value<bool>(true),
            updatedAt: Value<DateTime>(updatedAt),
          ),
        );
  }

  db.TransactionTagsCompanion _mapToCompanion(TransactionTagEntity link) {
    return db.TransactionTagsCompanion(
      transactionId: Value<String>(link.transactionId),
      tagId: Value<String>(link.tagId),
      createdAt: Value<DateTime>(link.createdAt),
      updatedAt: Value<DateTime>(link.updatedAt),
      isDeleted: Value<bool>(link.isDeleted),
    );
  }

  TransactionTagEntity mapRowToEntity(db.TransactionTagRow row) {
    return TransactionTagEntity(
      transactionId: row.transactionId,
      tagId: row.tagId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
    );
  }
}
