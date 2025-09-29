import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';

class WatchAccountsUseCase {
  WatchAccountsUseCase(this._repository);

  final AccountRepository _repository;

  Stream<List<AccountEntity>> call() {
    return _repository.watchAccounts();
  }
}
