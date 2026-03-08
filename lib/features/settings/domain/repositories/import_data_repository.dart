import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

/// Репозиторий, отвечающий за сохранение импортируемых данных.
abstract class ImportDataRepository {
  Future<void> importData({
    required List<AccountEntity> accounts,
    required List<Category> categories,
    required List<SavingGoal> savingGoals,
    required List<TransactionEntity> transactions,
  });
}
