import 'package:kopim/features/tags/domain/repositories/transaction_tags_repository.dart';

class GetTransactionTagIdsUseCase {
  GetTransactionTagIdsUseCase(this._repository);

  final TransactionTagsRepository _repository;

  Future<List<String>> call(String transactionId) {
    return _repository.getTagIdsForTransaction(transactionId);
  }
}
