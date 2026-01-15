import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';

abstract class TransactionTagsRepository {
  Stream<List<TagEntity>> watchTagsForTransaction(String transactionId);
  Future<List<TagEntity>> loadTagsForTransaction(String transactionId);
  Future<List<String>> getTagIdsForTransaction(String transactionId);
  Future<List<TransactionTagEntity>> loadAllTransactionTags();
  Future<void> upsertAll(List<TransactionTagEntity> links);
  Future<void> setTransactionTags(String transactionId, List<String> tagIds);
}
