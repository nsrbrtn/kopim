import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/tags/data/sources/local/tag_dao.dart';
import 'package:kopim/features/tags/data/sources/local/transaction_tags_dao.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/tags/domain/repositories/transaction_tags_repository.dart';

class TransactionTagsRepositoryImpl implements TransactionTagsRepository {
  TransactionTagsRepositoryImpl({
    required db.AppDatabase database,
    required TransactionTagsDao transactionTagsDao,
    required TagDao tagDao,
    required OutboxDao outboxDao,
  }) : _database = database,
       _transactionTagsDao = transactionTagsDao,
       _tagDao = tagDao,
       _outboxDao = outboxDao;

  final db.AppDatabase _database;
  final TransactionTagsDao _transactionTagsDao;
  final TagDao _tagDao;
  final OutboxDao _outboxDao;

  static const String _entityType = 'transaction_tag';

  @override
  Stream<List<TagEntity>> watchTagsForTransaction(String transactionId) {
    return _transactionTagsDao
        .watchTagsForTransaction(transactionId)
        .map(
          (List<db.TagRow> rows) =>
              rows.map(_tagDao.mapRowToEntity).toList(growable: false),
        );
  }

  @override
  Future<List<TagEntity>> loadTagsForTransaction(String transactionId) async {
    final List<db.TagRow> rows = await _transactionTagsDao
        .getTagsForTransaction(transactionId);
    return rows.map(_tagDao.mapRowToEntity).toList(growable: false);
  }

  @override
  Future<List<String>> getTagIdsForTransaction(String transactionId) async {
    final List<db.TransactionTagRow> links = await _transactionTagsDao
        .getLinksByTransaction(transactionId);
    return links
        .where((db.TransactionTagRow link) => !link.isDeleted)
        .map((db.TransactionTagRow link) => link.tagId)
        .toList(growable: false);
  }

  @override
  Future<List<TransactionTagEntity>> loadAllTransactionTags() async {
    final List<db.TransactionTagRow> rows = await _transactionTagsDao
        .getAllTransactionTags();
    return rows
        .map(_transactionTagsDao.mapRowToEntity)
        .toList(growable: false);
  }

  @override
  Future<void> upsertAll(List<TransactionTagEntity> links) async {
    await _transactionTagsDao.upsertAll(links);
  }

  @override
  Future<void> setTransactionTags(
    String transactionId,
    List<String> tagIds,
  ) async {
    final Set<String> uniqueIds = tagIds
        .map((String id) => id.trim())
        .where((String id) => id.isNotEmpty)
        .toSet();
    final DateTime now = DateTime.now();
    await _database.transaction(() async {
      final List<db.TransactionTagRow> existingLinks = await _transactionTagsDao
          .getLinksByTransaction(transactionId);
      final Map<String, db.TransactionTagRow> byTagId =
          <String, db.TransactionTagRow>{
            for (final db.TransactionTagRow link in existingLinks) link.tagId:
              link,
          };
      final Set<String> activeExisting = existingLinks
          .where((db.TransactionTagRow link) => !link.isDeleted)
          .map((db.TransactionTagRow link) => link.tagId)
          .toSet();

      final Set<String> toAdd = uniqueIds.difference(activeExisting);
      final Set<String> toRemove = activeExisting.difference(uniqueIds);

      for (final String tagId in toAdd) {
        final db.TransactionTagRow? previous = byTagId[tagId];
        final DateTime createdAt = previous?.createdAt ?? now;
        final TransactionTagEntity link = TransactionTagEntity(
          transactionId: transactionId,
          tagId: tagId,
          createdAt: createdAt,
          updatedAt: now,
          isDeleted: false,
        );
        await _transactionTagsDao.upsert(link);
        await _outboxDao.enqueue(
          entityType: _entityType,
          entityId: _composeEntityId(transactionId, tagId),
          operation: OutboxOperation.upsert,
          payload: _mapPayload(link),
        );
      }

      for (final String tagId in toRemove) {
        final db.TransactionTagRow? previous = byTagId[tagId];
        final DateTime createdAt = previous?.createdAt ?? now;
        final TransactionTagEntity link = TransactionTagEntity(
          transactionId: transactionId,
          tagId: tagId,
          createdAt: createdAt,
          updatedAt: now,
          isDeleted: true,
        );
        await _transactionTagsDao.upsert(link);
        await _outboxDao.enqueue(
          entityType: _entityType,
          entityId: _composeEntityId(transactionId, tagId),
          operation: OutboxOperation.delete,
          payload: _mapPayload(link),
        );
      }
    });
  }

  String _composeEntityId(String transactionId, String tagId) {
    final List<int> bytes = utf8.encode('$transactionId::$tagId');
    return sha1.convert(bytes).toString();
  }

  Map<String, dynamic> _mapPayload(TransactionTagEntity link) {
    final Map<String, dynamic> json = link.toJson();
    json['createdAt'] = link.createdAt.toIso8601String();
    json['updatedAt'] = link.updatedAt.toIso8601String();
    return json;
  }
}
