import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/categories/domain/entities/category.dart';

class CategoryDao {
  CategoryDao(this._db);

  final db.AppDatabase _db;

  Stream<List<db.CategoryRow>> watchActiveCategories() {
    final SimpleSelectStatement<db.$CategoriesTable, db.CategoryRow> query =
        _db.select(_db.categories)
          ..where((db.$CategoriesTable tbl) => tbl.isDeleted.equals(false));
    return query.watch();
  }

  Future<List<db.CategoryRow>> getActiveCategories() {
    final SimpleSelectStatement<db.$CategoriesTable, db.CategoryRow> query =
        _db.select(_db.categories)
          ..where((db.$CategoriesTable tbl) => tbl.isDeleted.equals(false));
    return query.get();
  }

  Future<List<Category>> getAllCategories() async {
    final List<db.CategoryRow> rows = await _db.select(_db.categories).get();
    return rows.map(_mapRowToEntity).toList();
  }

  Future<db.CategoryRow?> findById(String id) {
    final SimpleSelectStatement<db.$CategoriesTable, db.CategoryRow> query =
        _db.select(_db.categories)
          ..where((db.$CategoriesTable tbl) => tbl.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<void> upsert(Category category) {
    return _db
        .into(_db.categories)
        .insertOnConflictUpdate(_mapToCompanion(category));
  }

  Future<void> upsertAll(List<Category> categories) async {
    if (categories.isEmpty) return;
    await _db.batch((Batch batch) {
      batch.insertAllOnConflictUpdate(
        _db.categories,
        categories.map(_mapToCompanion).toList(),
      );
    });
  }

  Future<void> markDeleted(String id, DateTime deletedAt) async {
    await (_db.update(
      _db.categories,
    )..where((db.$CategoriesTable tbl) => tbl.id.equals(id))).write(
      db.CategoriesCompanion(
        isDeleted: const Value<bool>(true),
        updatedAt: Value<DateTime>(deletedAt),
      ),
    );
  }

  db.CategoriesCompanion _mapToCompanion(Category category) {
    return db.CategoriesCompanion(
      id: Value<String>(category.id),
      name: Value<String>(category.name),
      type: Value<String>(category.type),
      icon: Value<String?>(category.icon),
      color: Value<String?>(category.color),
      createdAt: Value<DateTime>(category.createdAt),
      updatedAt: Value<DateTime>(category.updatedAt),
      isDeleted: Value<bool>(category.isDeleted),
    );
  }

  Category _mapRowToEntity(db.CategoryRow row) {
    return Category(
      id: row.id,
      name: row.name,
      type: row.type,
      icon: row.icon,
      color: row.color,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
    );
  }
}
