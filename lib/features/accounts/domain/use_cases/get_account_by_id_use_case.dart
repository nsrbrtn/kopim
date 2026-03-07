import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';

class GetAccountByIdUseCase {
  GetAccountByIdUseCase(this._repository);

  final AccountRepository _repository;

  Future<AccountEntity?> call(String id) {
    return _repository.findById(id);
  }
}
