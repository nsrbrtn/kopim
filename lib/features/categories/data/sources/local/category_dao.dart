import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/categories/domain/entities/category.dart';

class CategoryDao {
  CategoryDao(this._db);

  final db.AppDatabase _db;

  Stream<List<db.CategoryRow>> watchActiveCategories() {
    final query = _db.select(_db.categories)
      ..where((tbl) => tbl.isDeleted.equals(false));
    return query.watch();
  }

  Future<List<db.CategoryRow>> getActiveCategories() {
    final query = _db.select(_db.categories)
      ..where((tbl) => tbl.isDeleted.equals(false));
    return query.get();
  }

  Future<db.CategoryRow?> findById(String id) {
    final query = _db.select(_db.categories)..where((tbl) => tbl.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<void> upsert(Category category) {
    return _db
        .into(_db.categories)
        .insertOnConflictUpdate(_mapToCompanion(category));
  }

  Future<void> upsertAll(List<Category> categories) async {
    if (categories.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.categories,
        categories.map(_mapToCompanion).toList(),
      );
    });
  }

  Future<void> markDeleted(String id, DateTime deletedAt) async {
    await (_db.update(_db.categories)..where((tbl) => tbl.id.equals(id))).write(
      db.CategoriesCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(deletedAt),
      ),
    );
  }

  db.CategoriesCompanion _mapToCompanion(Category category) {
    return db.CategoriesCompanion(
      id: Value(category.id),
      name: Value(category.name),
      type: Value(category.type),
      icon: Value(category.icon),
      color: Value(category.color),
      createdAt: Value(category.createdAt),
      updatedAt: Value(category.updatedAt),
      isDeleted: Value(category.isDeleted),
    );
  }
}
