import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

/// Контракт на получение полного снимка локальных данных для экспорта.
abstract class ExportDataRepository {
  /// Возвращает все счета, включая скрытые/удалённые, если они присутствуют.
  Future<List<AccountEntity>> fetchAccounts();

  /// Возвращает все транзакции без фильтрации по состоянию.
  Future<List<TransactionEntity>> fetchTransactions();

  /// Возвращает все категории с метаданными.
  Future<List<Category>> fetchCategories();
}
