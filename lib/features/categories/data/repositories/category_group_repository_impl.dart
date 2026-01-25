import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/categories/data/sources/local/category_group_dao.dart';
import 'package:kopim/features/categories/data/sources/local/category_group_link_dao.dart';
import 'package:kopim/features/categories/domain/entities/category_group.dart';
import 'package:kopim/features/categories/domain/entities/category_group_link.dart';
import 'package:kopim/features/categories/domain/repositories/category_group_repository.dart';

class CategoryGroupRepositoryImpl implements CategoryGroupRepository {
  CategoryGroupRepositoryImpl({
    required db.AppDatabase database,
    required CategoryGroupDao groupDao,
    required CategoryGroupLinkDao linkDao,
    required OutboxDao outboxDao,
  }) : _database = database,
       _groupDao = groupDao,
       _linkDao = linkDao,
       _outboxDao = outboxDao;

  final db.AppDatabase _database;
  final CategoryGroupDao _groupDao;
  final CategoryGroupLinkDao _linkDao;
  final OutboxDao _outboxDao;

  static const String _groupEntityType = 'category_group';
  static const String _linkEntityType = 'category_group_link';

  @override
  Stream<List<CategoryGroup>> watchGroups() {
    return _groupDao.watchActiveGroups().map(
      (List<db.CategoryGroupRow> rows) =>
          rows.map(_groupDao.mapRowToEntity).toList(growable: false),
    );
  }

  @override
  Future<List<CategoryGroup>> loadGroups() async {
    final List<db.CategoryGroupRow> rows = await _groupDao.getActiveGroups();
    return rows.map(_groupDao.mapRowToEntity).toList(growable: false);
  }

  @override
  Future<CategoryGroup?> findById(String id) async {
    final db.CategoryGroupRow? row = await _groupDao.findById(id);
    if (row == null) return null;
    return _groupDao.mapRowToEntity(row);
  }

  @override
  Future<CategoryGroup?> findByName(String name) async {
    final db.CategoryGroupRow? row = await _groupDao.findByName(name);
    if (row == null) return null;
    return _groupDao.mapRowToEntity(row);
  }

  @override
  Future<void> upsertGroup(CategoryGroup group) async {
    final DateTime now = DateTime.now();
    final CategoryGroup toPersist = group.copyWith(updatedAt: now);
    await _database.transaction(() async {
      await _groupDao.upsert(toPersist);
      await _outboxDao.enqueue(
        entityType: _groupEntityType,
        entityId: toPersist.id,
        operation: OutboxOperation.upsert,
        payload: _mapGroupPayload(toPersist),
      );
    });
  }

  @override
  Future<void> softDeleteGroup(String id) async {
    final DateTime now = DateTime.now();
    await _database.transaction(() async {
      await _groupDao.markDeleted(id, now);
      final db.CategoryGroupRow? row = await _groupDao.findById(id);
      if (row == null) return;
      final CategoryGroup deleted = _groupDao
          .mapRowToEntity(row)
          .copyWith(isDeleted: true, updatedAt: now);
      final List<db.CategoryGroupLinkRow> links = await _linkDao
          .getLinksForGroup(id);
      for (final db.CategoryGroupLinkRow link in links) {
        if (link.isDeleted) {
          continue;
        }
        await _linkDao.markDeleted(
          groupId: link.groupId,
          categoryId: link.categoryId,
          updatedAt: now,
        );
        await _outboxDao.enqueue(
          entityType: _linkEntityType,
          entityId: '${link.groupId}:${link.categoryId}',
          operation: OutboxOperation.delete,
          payload: _mapLinkPayload(
            _linkDao
                .mapRowToEntity(link)
                .copyWith(isDeleted: true, updatedAt: now),
          ),
        );
      }
      await _outboxDao.enqueue(
        entityType: _groupEntityType,
        entityId: id,
        operation: OutboxOperation.delete,
        payload: _mapGroupPayload(deleted),
      );
    });
  }

  @override
  Future<void> updateGroupOrders(List<String> orderedIds) async {
    if (orderedIds.isEmpty) return;
    final DateTime now = DateTime.now();
    final List<db.CategoryGroupRow> rows = await _groupDao.getActiveGroups();
    final Map<String, int> orders = <String, int>{};
    final Map<String, CategoryGroup> updatedGroups = <String, CategoryGroup>{};
    for (int index = 0; index < orderedIds.length; index++) {
      orders[orderedIds[index]] = index;
    }
    for (final db.CategoryGroupRow row in rows) {
      final int? order = orders[row.id];
      if (order == null || row.sortOrder == order) {
        continue;
      }
      final CategoryGroup updated = _groupDao
          .mapRowToEntity(row)
          .copyWith(sortOrder: order, updatedAt: now);
      updatedGroups[row.id] = updated;
    }
    if (updatedGroups.isEmpty) return;
    await _database.transaction(() async {
      await _groupDao.updateSortOrders(
        updatedGroups.map(
          (String id, CategoryGroup group) =>
              MapEntry<String, int>(id, group.sortOrder),
        ),
        now,
      );
      for (final CategoryGroup group in updatedGroups.values) {
        await _outboxDao.enqueue(
          entityType: _groupEntityType,
          entityId: group.id,
          operation: OutboxOperation.upsert,
          payload: _mapGroupPayload(group),
        );
      }
    });
  }

  @override
  Stream<List<CategoryGroupLink>> watchLinks() {
    return _linkDao.watchActiveLinks().map(
      (List<db.CategoryGroupLinkRow> rows) =>
          rows.map(_linkDao.mapRowToEntity).toList(growable: false),
    );
  }

  @override
  Future<List<CategoryGroupLink>> loadLinks() async {
    return _linkDao.getActiveLinks().then(
      (List<db.CategoryGroupLinkRow> rows) =>
          rows.map(_linkDao.mapRowToEntity).toList(growable: false),
    );
  }

  @override
  Future<List<CategoryGroupLink>> loadLinksForGroup(String groupId) async {
    final List<db.CategoryGroupLinkRow> rows = await _linkDao.getLinksForGroup(
      groupId,
    );
    return rows.map(_linkDao.mapRowToEntity).toList(growable: false);
  }

  @override
  Future<void> upsertLink(CategoryGroupLink link) async {
    final DateTime now = DateTime.now();
    final CategoryGroupLink toPersist = link.copyWith(updatedAt: now);
    await _database.transaction(() async {
      await _linkDao.upsert(toPersist);
      await _outboxDao.enqueue(
        entityType: _linkEntityType,
        entityId: '${link.groupId}:${link.categoryId}',
        operation: OutboxOperation.upsert,
        payload: _mapLinkPayload(toPersist),
      );
    });
  }

  @override
  Future<void> upsertLinks(List<CategoryGroupLink> links) async {
    if (links.isEmpty) return;
    final DateTime now = DateTime.now();
    final List<CategoryGroupLink> toPersist = links
        .map((CategoryGroupLink link) => link.copyWith(updatedAt: now))
        .toList(growable: false);
    await _database.transaction(() async {
      await _linkDao.upsertAll(toPersist);
      for (final CategoryGroupLink link in toPersist) {
        await _outboxDao.enqueue(
          entityType: _linkEntityType,
          entityId: '${link.groupId}:${link.categoryId}',
          operation: OutboxOperation.upsert,
          payload: _mapLinkPayload(link),
        );
      }
    });
  }

  @override
  Future<void> markLinkDeleted({
    required String groupId,
    required String categoryId,
    required DateTime updatedAt,
  }) async {
    await _database.transaction(() async {
      await _linkDao.markDeleted(
        groupId: groupId,
        categoryId: categoryId,
        updatedAt: updatedAt,
      );
      final db.CategoryGroupLinkRow? row = await _linkDao.findLink(
        groupId: groupId,
        categoryId: categoryId,
      );
      final DateTime createdAt = row?.createdAt ?? updatedAt;
      await _outboxDao.enqueue(
        entityType: _linkEntityType,
        entityId: '$groupId:$categoryId',
        operation: OutboxOperation.delete,
        payload: _mapLinkPayload(
          CategoryGroupLink(
            groupId: groupId,
            categoryId: categoryId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: true,
          ),
        ),
      );
    });
  }

  Map<String, dynamic> _mapGroupPayload(CategoryGroup group) {
    final Map<String, dynamic> json = group.toJson();
    json['createdAt'] = group.createdAt.toIso8601String();
    json['updatedAt'] = group.updatedAt.toIso8601String();
    return json;
  }

  Map<String, dynamic> _mapLinkPayload(CategoryGroupLink link) {
    final Map<String, dynamic> json = link.toJson();
    json['createdAt'] = link.createdAt.toIso8601String();
    json['updatedAt'] = link.updatedAt.toIso8601String();
    return json;
  }
}
