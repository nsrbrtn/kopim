import 'package:kopim/features/accounts/domain/entities/account_entity.dart';

abstract class AccountRepository {
  Stream<List<AccountEntity>> watchAccounts();
  Future<List<AccountEntity>> loadAccounts();
  Future<AccountEntity?> findById(String id);
  Future<void> upsert(AccountEntity account);
  Future<void> softDelete(String id);
}
