import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/categories/domain/entities/category_group.dart';

class CategoryGroupDao {
  CategoryGroupDao(this._db);

  final db.AppDatabase _db;

  Stream<List<db.CategoryGroupRow>> watchActiveGroups() {
    final SimpleSelectStatement<db.$CategoryGroupsTable, db.CategoryGroupRow>
    query = _db.select(_db.categoryGroups)
      ..where((db.$CategoryGroupsTable tbl) => tbl.isDeleted.equals(false))
      ..orderBy(<OrderingTerm Function(db.$CategoryGroupsTable tbl)>[
        (db.$CategoryGroupsTable tbl) =>
            OrderingTerm(expression: tbl.sortOrder, mode: OrderingMode.asc),
        (db.$CategoryGroupsTable tbl) =>
            OrderingTerm(expression: tbl.name, mode: OrderingMode.asc),
      ]);
    return query.watch();
  }

  Future<List<db.CategoryGroupRow>> getActiveGroups() {
    final SimpleSelectStatement<db.$CategoryGroupsTable, db.CategoryGroupRow>
    query = _db.select(_db.categoryGroups)
      ..where((db.$CategoryGroupsTable tbl) => tbl.isDeleted.equals(false))
      ..orderBy(<OrderingTerm Function(db.$CategoryGroupsTable tbl)>[
        (db.$CategoryGroupsTable tbl) =>
            OrderingTerm(expression: tbl.sortOrder, mode: OrderingMode.asc),
        (db.$CategoryGroupsTable tbl) =>
            OrderingTerm(expression: tbl.name, mode: OrderingMode.asc),
      ]);
    return query.get();
  }

  Future<List<CategoryGroup>> getAllGroups() async {
    final List<db.CategoryGroupRow> rows = await _db
        .select(_db.categoryGroups)
        .get();
    return rows.map(mapRowToEntity).toList();
  }

  Future<db.CategoryGroupRow?> findById(String id) {
    final SimpleSelectStatement<db.$CategoryGroupsTable, db.CategoryGroupRow>
    query = _db.select(_db.categoryGroups)
      ..where((db.$CategoryGroupsTable tbl) => tbl.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<db.CategoryGroupRow?> findByName(String name) {
    final SimpleSelectStatement<db.$CategoryGroupsTable, db.CategoryGroupRow>
    query = _db.select(_db.categoryGroups)
      ..where((db.$CategoryGroupsTable tbl) => tbl.name.equals(name));
    return query.getSingleOrNull();
  }

  Future<void> upsert(CategoryGroup group) {
    return _db
        .into(_db.categoryGroups)
        .insertOnConflictUpdate(_mapToCompanion(group));
  }

  Future<void> upsertAll(List<CategoryGroup> groups) async {
    if (groups.isEmpty) return;
    await _db.transaction(() async {
      await _db.batch((Batch batch) {
        batch.insertAllOnConflictUpdate(
          _db.categoryGroups,
          groups.map(_mapToCompanion).toList(),
        );
      });
    });
  }

  Future<void> markDeleted(String id, DateTime deletedAt) async {
    await (_db.update(
      _db.categoryGroups,
    )..where((db.$CategoryGroupsTable tbl) => tbl.id.equals(id))).write(
      db.CategoryGroupsCompanion(
        isDeleted: const Value<bool>(true),
        updatedAt: Value<DateTime>(deletedAt),
      ),
    );
  }

  Future<void> updateSortOrders(
    Map<String, int> orders,
    DateTime updatedAt,
  ) async {
    if (orders.isEmpty) return;
    await _db.batch((Batch batch) {
      orders.forEach((String id, int order) {
        batch.update(
          _db.categoryGroups,
          db.CategoryGroupsCompanion(
            sortOrder: Value<int>(order),
            updatedAt: Value<DateTime>(updatedAt),
          ),
          where: (db.$CategoryGroupsTable tbl) => tbl.id.equals(id),
        );
      });
    });
  }

  db.CategoryGroupsCompanion _mapToCompanion(CategoryGroup group) {
    return db.CategoryGroupsCompanion(
      id: Value<String>(group.id),
      name: Value<String>(group.name),
      sortOrder: Value<int>(group.sortOrder),
      createdAt: Value<DateTime>(group.createdAt),
      updatedAt: Value<DateTime>(group.updatedAt),
      isDeleted: Value<bool>(group.isDeleted),
    );
  }

  CategoryGroup mapRowToEntity(db.CategoryGroupRow row) {
    return CategoryGroup(
      id: row.id,
      name: row.name,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
    );
  }
}
