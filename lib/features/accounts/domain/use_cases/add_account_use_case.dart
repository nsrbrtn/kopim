import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';

class AddAccountUseCase {
  AddAccountUseCase(this._repository);

  final AccountRepository _repository;

  Future<void> call(AccountEntity account) {
    return _repository.upsert(account);
  }
}
