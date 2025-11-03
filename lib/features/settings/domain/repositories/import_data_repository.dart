import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

/// Репозиторий, отвечающий за сохранение импортируемых данных.
abstract class ImportDataRepository {
  Future<void> upsertAccounts(List<AccountEntity> accounts);

  Future<void> upsertCategories(List<Category> categories);

  Future<void> upsertTransactions(List<TransactionEntity> transactions);
}
