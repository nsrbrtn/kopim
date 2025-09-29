import 'package:kopim/features/accounts/domain/entities/account_entity.dart';

/// Watches active accounts stored locally, emitting updates when data changes.
abstract class WatchAccountsUseCase {
  /// Returns a stream of active accounts sorted according to persistence layer.
  Stream<List<AccountEntity>> call();
}
