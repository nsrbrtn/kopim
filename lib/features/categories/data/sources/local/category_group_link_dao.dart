import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/categories/domain/entities/category_group_link.dart';

class CategoryGroupLinkDao {
  CategoryGroupLinkDao(this._db);

  final db.AppDatabase _db;

  Stream<List<db.CategoryGroupLinkRow>> watchActiveLinks() {
    final SimpleSelectStatement<
      db.$CategoryGroupLinksTable,
      db.CategoryGroupLinkRow
    >
    query = _db.select(_db.categoryGroupLinks)
      ..where((db.$CategoryGroupLinksTable tbl) => tbl.isDeleted.equals(false));
    return query.watch();
  }

  Future<List<db.CategoryGroupLinkRow>> getActiveLinks() {
    final SimpleSelectStatement<
      db.$CategoryGroupLinksTable,
      db.CategoryGroupLinkRow
    >
    query = _db.select(_db.categoryGroupLinks)
      ..where((db.$CategoryGroupLinksTable tbl) => tbl.isDeleted.equals(false));
    return query.get();
  }

  Future<List<db.CategoryGroupLinkRow>> getLinksForGroup(String groupId) {
    final SimpleSelectStatement<
      db.$CategoryGroupLinksTable,
      db.CategoryGroupLinkRow
    >
    query = _db.select(_db.categoryGroupLinks)
      ..where((db.$CategoryGroupLinksTable tbl) => tbl.groupId.equals(groupId));
    return query.get();
  }

  Future<db.CategoryGroupLinkRow?> findLink({
    required String groupId,
    required String categoryId,
  }) {
    final SimpleSelectStatement<
      db.$CategoryGroupLinksTable,
      db.CategoryGroupLinkRow
    >
    query = _db.select(_db.categoryGroupLinks)
      ..where(
        (db.$CategoryGroupLinksTable tbl) =>
            tbl.groupId.equals(groupId) & tbl.categoryId.equals(categoryId),
      );
    return query.getSingleOrNull();
  }

  Future<List<CategoryGroupLink>> getAllLinks() async {
    final List<db.CategoryGroupLinkRow> rows = await _db
        .select(_db.categoryGroupLinks)
        .get();
    return rows.map(mapRowToEntity).toList();
  }

  Future<void> upsert(CategoryGroupLink link) {
    return _db
        .into(_db.categoryGroupLinks)
        .insertOnConflictUpdate(_mapToCompanion(link));
  }

  Future<void> upsertAll(List<CategoryGroupLink> links) async {
    if (links.isEmpty) return;
    await _db.transaction(() async {
      await _db.batch((Batch batch) {
        batch.insertAllOnConflictUpdate(
          _db.categoryGroupLinks,
          links.map(_mapToCompanion).toList(),
        );
      });
    });
  }

  Future<void> markDeleted({
    required String groupId,
    required String categoryId,
    required DateTime updatedAt,
  }) async {
    await (_db.update(_db.categoryGroupLinks)..where(
          (db.$CategoryGroupLinksTable tbl) =>
              tbl.groupId.equals(groupId) & tbl.categoryId.equals(categoryId),
        ))
        .write(
          db.CategoryGroupLinksCompanion(
            isDeleted: const Value<bool>(true),
            updatedAt: Value<DateTime>(updatedAt),
          ),
        );
  }

  db.CategoryGroupLinksCompanion _mapToCompanion(CategoryGroupLink link) {
    return db.CategoryGroupLinksCompanion(
      groupId: Value<String>(link.groupId),
      categoryId: Value<String>(link.categoryId),
      createdAt: Value<DateTime>(link.createdAt),
      updatedAt: Value<DateTime>(link.updatedAt),
      isDeleted: Value<bool>(link.isDeleted),
    );
  }

  CategoryGroupLink mapRowToEntity(db.CategoryGroupLinkRow row) {
    return CategoryGroupLink(
      groupId: row.groupId,
      categoryId: row.categoryId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
    );
  }
}
