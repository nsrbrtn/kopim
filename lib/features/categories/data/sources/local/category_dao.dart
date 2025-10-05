import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';

class CategoryDao {
  CategoryDao(this._db);

  final db.AppDatabase _db;

  Stream<List<db.CategoryRow>> watchActiveCategories() {
    final SimpleSelectStatement<db.$CategoriesTable, db.CategoryRow> query =
        _db.select(_db.categories)
          ..where((db.$CategoriesTable tbl) => tbl.isDeleted.equals(false))
          ..orderBy(<OrderingTerm Function(db.$CategoriesTable tbl)>[
            (db.$CategoriesTable tbl) =>
                OrderingTerm(expression: tbl.name, mode: OrderingMode.asc),
          ]);
    return query.watch();
  }

  Future<List<db.CategoryRow>> getActiveCategories() {
    final SimpleSelectStatement<db.$CategoriesTable, db.CategoryRow> query =
        _db.select(_db.categories)
          ..where((db.$CategoriesTable tbl) => tbl.isDeleted.equals(false))
          ..orderBy(<OrderingTerm Function(db.$CategoriesTable tbl)>[
            (db.$CategoriesTable tbl) =>
                OrderingTerm(expression: tbl.name, mode: OrderingMode.asc),
          ]);
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

  Future<db.CategoryRow?> findByName(String name) {
    final SimpleSelectStatement<db.$CategoriesTable, db.CategoryRow> query =
        _db.select(_db.categories)
          ..where((db.$CategoriesTable tbl) => tbl.name.equals(name));
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

  Future<void> markChildrenDeleted(String parentId, DateTime deletedAt) async {
    await (_db.update(
      _db.categories,
    )..where((db.$CategoriesTable tbl) => tbl.parentId.equals(parentId))).write(
      db.CategoriesCompanion(
        isDeleted: const Value<bool>(true),
        updatedAt: Value<DateTime>(deletedAt),
      ),
    );
  }

  db.CategoriesCompanion _mapToCompanion(Category category) {
    final PhosphorIconDescriptor? descriptor =
        category.icon != null && category.icon!.isNotEmpty
        ? category.icon
        : null;
    return db.CategoriesCompanion(
      id: Value<String>(category.id),
      name: Value<String>(category.name),
      type: Value<String>(category.type),
      icon: Value<String?>(descriptor?.name),
      iconName: Value<String?>(descriptor?.name),
      iconStyle: Value<String?>(descriptor?.style.label),
      color: Value<String?>(category.color),
      parentId: Value<String?>(category.parentId),
      createdAt: Value<DateTime>(category.createdAt),
      updatedAt: Value<DateTime>(category.updatedAt),
      isDeleted: Value<bool>(category.isDeleted),
      isSystem: Value<bool>(category.isSystem),
    );
  }

  Category _mapRowToEntity(db.CategoryRow row) {
    PhosphorIconDescriptor? descriptor;
    if (row.iconName != null && row.iconName!.isNotEmpty) {
      descriptor = PhosphorIconDescriptor(
        name: row.iconName!,
        style: PhosphorIconStyleX.fromName(row.iconStyle),
      );
    } else if (row.icon != null && row.icon!.isNotEmpty) {
      descriptor = PhosphorIconDescriptor(name: row.icon!);
    }
    return Category(
      id: row.id,
      name: row.name,
      type: row.type,
      icon: descriptor,
      color: row.color,
      parentId: row.parentId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
      isSystem: row.isSystem,
    );
  }
}
