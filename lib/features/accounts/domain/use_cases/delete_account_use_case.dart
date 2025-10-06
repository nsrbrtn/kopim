import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';

class DeleteAccountUseCase {
  DeleteAccountUseCase(this._repository);

  final AccountRepository _repository;

  Future<void> call(String id) {
    return _repository.softDelete(id);
  }
}
