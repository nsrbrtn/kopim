import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/accounts/domain/usecases/watch_accounts_use_case.dart';

/// Default implementation that proxies to the local repository stream.
class WatchAccountsUseCaseImpl implements WatchAccountsUseCase {
  WatchAccountsUseCaseImpl({required AccountRepository repository})
      : _repository = repository;

  final AccountRepository _repository;

  @override
  Stream<List<AccountEntity>> call() {
    return _repository.watchAccounts();
  }
}
