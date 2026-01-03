import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/repositories/transaction_tags_repository.dart';

class WatchTransactionTagsUseCase {
  WatchTransactionTagsUseCase(this._repository);

  final TransactionTagsRepository _repository;

  Stream<List<TagEntity>> call(String transactionId) {
    return _repository.watchTagsForTransaction(transactionId);
  }
}
