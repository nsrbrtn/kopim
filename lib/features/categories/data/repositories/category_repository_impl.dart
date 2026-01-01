import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/entities/category_tree_node.dart';
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
      (List<db.CategoryRow> rows) =>
          rows.map(_mapToDomain).toList(growable: false),
    );
  }

  @override
  Stream<List<CategoryTreeNode>> watchCategoryTree() {
    return _categoryDao.watchActiveCategories().map(_mapRowsToTree);
  }

  @override
  Future<List<Category>> loadCategories() async {
    final List<db.CategoryRow> rows = await _categoryDao.getActiveCategories();
    return rows.map(_mapToDomain).toList(growable: false);
  }

  @override
  Future<List<CategoryTreeNode>> loadCategoryTree() async {
    final List<db.CategoryRow> rows = await _categoryDao.getActiveCategories();
    return _mapRowsToTree(rows);
  }

  @override
  Future<Category?> findById(String id) async {
    final db.CategoryRow? row = await _categoryDao.findById(id);
    if (row == null) return null;
    return _mapToDomain(row);
  }

  @override
  Future<Category?> findByName(String name) async {
    final db.CategoryRow? row = await _categoryDao.findByName(name);
    if (row == null) return null;
    return _mapToDomain(row);
  }

  @override
  Future<void> upsert(Category category) async {
    final DateTime now = DateTime.now();
    final Category toPersist = category.copyWith(updatedAt: now);
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
    final DateTime now = DateTime.now();
    await _database.transaction(() async {
      await _categoryDao.markDeleted(id, now);
      final db.CategoryRow? row = await _categoryDao.findById(id);
      if (row == null) return;
      final Category deleted = _mapToDomain(
        row,
      ).copyWith(isDeleted: true, updatedAt: now);
      final List<Category> allCategories = await _categoryDao
          .getAllCategories();
      final List<Category> descendants = _collectDescendants(id, allCategories);
      for (final Category child in descendants) {
        if (child.isDeleted) {
          continue;
        }
        await _categoryDao.markDeleted(child.id, now);
        final Map<String, dynamic> childPayload = _mapCategoryPayload(
          child.copyWith(isDeleted: true, updatedAt: now),
        );
        await _outboxDao.enqueue(
          entityType: _entityType,
          entityId: child.id,
          operation: OutboxOperation.delete,
          payload: childPayload,
        );
      }
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: id,
        operation: OutboxOperation.delete,
        payload: _mapCategoryPayload(deleted),
      );
    });
  }

  Map<String, dynamic> _mapCategoryPayload(Category category) {
    final Map<String, dynamic> json = category.toJson();
    json['iconName'] = category.icon?.name;
    json['iconStyle'] = category.icon?.style.label;
    json['parentId'] = category.parentId;
    json['createdAt'] = category.createdAt.toIso8601String();
    json['updatedAt'] = category.updatedAt.toIso8601String();
    json['isSystem'] = category.isSystem;
    json['isFavorite'] = category.isFavorite;
    return json;
  }

  Category _mapToDomain(db.CategoryRow row) {
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
      isFavorite: row.isFavorite,
    );
  }

  List<CategoryTreeNode> _mapRowsToTree(List<db.CategoryRow> rows) {
    final List<Category> categories = rows
        .map(_mapToDomain)
        .toList(growable: false);
    return _buildTree(categories);
  }

  List<CategoryTreeNode> _buildTree(List<Category> categories) {
    final List<Category> sorted = List<Category>.from(categories)
      ..sort(
        (Category a, Category b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    final Map<String, List<Category>> childrenByParent =
        <String, List<Category>>{};
    final Map<String, Category> byId = <String, Category>{
      for (final Category category in sorted) category.id: category,
    };

    for (final Category category in sorted) {
      final String? parentId = category.parentId;
      if (parentId == null || parentId.isEmpty) {
        continue;
      }
      childrenByParent.putIfAbsent(parentId, () => <Category>[]).add(category);
    }

    final List<CategoryTreeNode> result = <CategoryTreeNode>[];
    final Set<String> visited = <String>{};

    CategoryTreeNode buildNode(Category category) {
      if (!visited.add(category.id)) {
        return CategoryTreeNode(category: category);
      }
      final List<Category> children =
          List<Category>.from(
            childrenByParent[category.id] ?? const <Category>[],
          )..sort(
            (Category a, Category b) =>
                a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
      return CategoryTreeNode(
        category: category,
        children: children.map(buildNode).toList(growable: false),
      );
    }

    for (final Category category in sorted) {
      if (category.parentId == null || category.parentId!.isEmpty) {
        result.add(buildNode(category));
      }
    }

    for (final Category category in sorted) {
      if (visited.contains(category.id)) {
        continue;
      }
      // Orphaned categories (missing parent) should still be surfaced at root.
      final String? parentId = category.parentId;
      if (parentId != null &&
          parentId.isNotEmpty &&
          !byId.containsKey(parentId)) {
        result.add(buildNode(category));
      }
    }

    return result;
  }

  List<Category> _collectDescendants(
    String parentId,
    List<Category> categories,
  ) {
    final Map<String, List<Category>> childrenByParent =
        <String, List<Category>>{};
    for (final Category category in categories) {
      if (category.parentId == null || category.parentId!.isEmpty) {
        continue;
      }
      childrenByParent
          .putIfAbsent(category.parentId!, () => <Category>[])
          .add(category);
    }

    final List<Category> result = <Category>[];
    final Set<String> visited = <String>{};

    void visit(String currentParent) {
      final List<Category> children =
          childrenByParent[currentParent] ?? const <Category>[];
      for (final Category child in children) {
        if (!visited.add(child.id)) {
          continue;
        }
        result.add(child);
        visit(child.id);
      }
    }

    visit(parentId);
    return result;
  }
}
