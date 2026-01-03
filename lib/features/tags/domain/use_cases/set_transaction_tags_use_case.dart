import 'package:kopim/features/tags/domain/repositories/transaction_tags_repository.dart';

class SetTransactionTagsUseCase {
  SetTransactionTagsUseCase(this._repository);

  final TransactionTagsRepository _repository;

  Future<void> call({
    required String transactionId,
    required List<String> tagIds,
  }) {
    return _repository.setTransactionTags(transactionId, tagIds);
  }
}
