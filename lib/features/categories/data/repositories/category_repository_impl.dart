import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl({
    required db.AppDatabase database,
    required CategoryDao categoryDao,
    required OutboxDao outboxDao,
  }) : _database = database,
       _categoryDao = categoryDao,
       _outboxDao = outboxDao;

  final db.AppDatabase _database;
  final CategoryDao _categoryDao;
  final OutboxDao _outboxDao;

  static const String _entityType = 'category';

  @override
  Stream<List<Category>> watchCategories() {
    return _categoryDao.watchActiveCategories().map(
      (rows) => rows.map(_mapToDomain).toList(growable: false),
    );
  }

  @override
  Future<List<Category>> loadCategories() async {
    final rows = await _categoryDao.getActiveCategories();
    return rows.map(_mapToDomain).toList(growable: false);
  }

  @override
  Future<Category?> findById(String id) async {
    final row = await _categoryDao.findById(id);
    if (row == null) return null;
    return _mapToDomain(row);
  }

  @override
  Future<void> upsert(Category category) async {
    final now = DateTime.now();
    final toPersist = category.copyWith(updatedAt: now);
    await _database.transaction(() async {
      await _categoryDao.upsert(toPersist);
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: toPersist.id,
        operation: OutboxOperation.upsert,
        payload: _mapCategoryPayload(toPersist),
      );
    });
  }

  @override
  Future<void> softDelete(String id) async {
    final now = DateTime.now();
    await _database.transaction(() async {
      await _categoryDao.markDeleted(id, now);
      final row = await _categoryDao.findById(id);
      if (row == null) return;
      final payload = _mapCategoryPayload(
        _mapToDomain(row).copyWith(isDeleted: true, updatedAt: now),
      );
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: id,
        operation: OutboxOperation.delete,
        payload: payload,
      );
    });
  }

  Map<String, dynamic> _mapCategoryPayload(Category category) {
    final json = category.toJson();
    json['createdAt'] = category.createdAt.toIso8601String();
    json['updatedAt'] = category.updatedAt.toIso8601String();
    return json;
  }

  Category _mapToDomain(db.CategoryRow row) {
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
