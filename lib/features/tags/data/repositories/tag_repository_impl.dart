import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/tags/data/sources/local/tag_dao.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/repositories/tag_repository.dart';

class TagRepositoryImpl implements TagRepository {
  TagRepositoryImpl({
    required db.AppDatabase database,
    required TagDao tagDao,
    required OutboxDao outboxDao,
  }) : _database = database,
       _tagDao = tagDao,
       _outboxDao = outboxDao;

  final db.AppDatabase _database;
  final TagDao _tagDao;
  final OutboxDao _outboxDao;

  static const String _entityType = 'tag';

  @override
  Stream<List<TagEntity>> watchTags({bool includeArchived = false}) {
    final Stream<List<db.TagRow>> stream = includeArchived
        ? (_database.select(_database.tags)
          ..orderBy(<OrderingTerm Function(db.$TagsTable tbl)>[
            (db.$TagsTable tbl) =>
                OrderingTerm(expression: tbl.name, mode: OrderingMode.asc),
          ])).watch()
        : _tagDao.watchActiveTags();
    return stream.map(
      (List<db.TagRow> rows) =>
          rows.map(_tagDao.mapRowToEntity).toList(growable: false),
    );
  }

  @override
  Future<List<TagEntity>> loadTags({bool includeArchived = false}) async {
    final List<db.TagRow> rows = includeArchived
        ? await (_database.select(_database.tags)
              ..orderBy(<OrderingTerm Function(db.$TagsTable tbl)>[
                (db.$TagsTable tbl) =>
                    OrderingTerm(expression: tbl.name, mode: OrderingMode.asc),
              ]))
            .get()
        : await _tagDao.getActiveTags();
    return rows.map(_tagDao.mapRowToEntity).toList(growable: false);
  }

  @override
  Future<TagEntity?> findById(String id) async {
    final db.TagRow? row = await _tagDao.findById(id);
    return row == null ? null : _tagDao.mapRowToEntity(row);
  }

  @override
  Future<TagEntity?> findByName(String name) async {
    final db.TagRow? row = await _tagDao.findByName(name);
    return row == null ? null : _tagDao.mapRowToEntity(row);
  }

  @override
  Future<void> upsert(TagEntity tag) async {
    final DateTime now = DateTime.now();
    final TagEntity toPersist = tag.copyWith(updatedAt: now);
    await _database.transaction(() async {
      await _tagDao.upsert(toPersist);
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: toPersist.id,
        operation: OutboxOperation.upsert,
        payload: _mapTagPayload(toPersist),
      );
    });
  }

  @override
  Future<void> softDelete(String id) async {
    final DateTime now = DateTime.now();
    await _database.transaction(() async {
      await _tagDao.markDeleted(id, now);
      final db.TagRow? row = await _tagDao.findById(id);
      if (row == null) return;
      final TagEntity deleted = _tagDao.mapRowToEntity(
        row,
      ).copyWith(isDeleted: true, updatedAt: now);
      await _outboxDao.enqueue(
        entityType: _entityType,
        entityId: id,
        operation: OutboxOperation.delete,
        payload: _mapTagPayload(deleted),
      );
    });
  }

  Map<String, dynamic> _mapTagPayload(TagEntity tag) {
    final Map<String, dynamic> json = tag.toJson();
    json['createdAt'] = tag.createdAt.toIso8601String();
    json['updatedAt'] = tag.updatedAt.toIso8601String();
    return json;
  }
}
