import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/tags/domain/entities/tag.dart';

class TagDao {
  TagDao(this._db);

  final db.AppDatabase _db;

  Stream<List<db.TagRow>> watchActiveTags() {
    final SimpleSelectStatement<db.$TagsTable, db.TagRow> query =
        _db.select(_db.tags)
          ..where((db.$TagsTable tbl) => tbl.isDeleted.equals(false))
          ..orderBy(<OrderingTerm Function(db.$TagsTable tbl)>[
            (db.$TagsTable tbl) =>
                OrderingTerm(expression: tbl.name, mode: OrderingMode.asc),
          ]);
    return query.watch();
  }

  Future<List<db.TagRow>> getActiveTags() {
    final SimpleSelectStatement<db.$TagsTable, db.TagRow> query =
        _db.select(_db.tags)
          ..where((db.$TagsTable tbl) => tbl.isDeleted.equals(false))
          ..orderBy(<OrderingTerm Function(db.$TagsTable tbl)>[
            (db.$TagsTable tbl) =>
                OrderingTerm(expression: tbl.name, mode: OrderingMode.asc),
          ]);
    return query.get();
  }

  Future<List<TagEntity>> getAllTags() async {
    final List<db.TagRow> rows = await _db.select(_db.tags).get();
    return rows.map(mapRowToEntity).toList();
  }

  Future<db.TagRow?> findById(String id) {
    final SimpleSelectStatement<db.$TagsTable, db.TagRow> query = _db.select(
      _db.tags,
    )..where((db.$TagsTable tbl) => tbl.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<db.TagRow?> findByName(String name) {
    final SimpleSelectStatement<db.$TagsTable, db.TagRow> query = _db.select(
      _db.tags,
    )..where((db.$TagsTable tbl) => tbl.name.equals(name));
    return query.getSingleOrNull();
  }

  Future<void> upsert(TagEntity tag) {
    return _db.into(_db.tags).insertOnConflictUpdate(_mapToCompanion(tag));
  }

  Future<void> upsertAll(List<TagEntity> tags) async {
    if (tags.isEmpty) return;
    await _db.transaction(() async {
      await _db.batch((Batch batch) {
        batch.insertAllOnConflictUpdate(
          _db.tags,
          tags.map(_mapToCompanion).toList(),
        );
      });
    });
  }

  Future<void> markDeleted(String id, DateTime deletedAt) async {
    await (_db.update(
      _db.tags,
    )..where((db.$TagsTable tbl) => tbl.id.equals(id))).write(
      db.TagsCompanion(
        isDeleted: const Value<bool>(true),
        updatedAt: Value<DateTime>(deletedAt),
      ),
    );
  }

  db.TagsCompanion _mapToCompanion(TagEntity tag) {
    return db.TagsCompanion(
      id: Value<String>(tag.id),
      name: Value<String>(tag.name),
      color: Value<String>(tag.color),
      createdAt: Value<DateTime>(tag.createdAt),
      updatedAt: Value<DateTime>(tag.updatedAt),
      isDeleted: Value<bool>(tag.isDeleted),
    );
  }

  TagEntity mapRowToEntity(db.TagRow row) {
    return TagEntity(
      id: row.id,
      name: row.name,
      color: row.color,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
    );
  }
}
