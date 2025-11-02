import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/repositories/export_data_repository.dart';
import 'package:kopim/features/settings/domain/use_cases/prepare_export_bundle_use_case.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

/// Реализация сборки экспортного бандла на основе локального репозитория.
class PrepareExportBundleUseCaseImpl implements PrepareExportBundleUseCase {
  PrepareExportBundleUseCaseImpl({
    required ExportDataRepository repository,
    DateTime Function()? clock,
    String? schemaVersion,
  }) : _repository = repository,
       _clock = clock ?? DateTime.now,
       _schemaVersion = schemaVersion ?? _defaultSchemaVersion;

  final ExportDataRepository _repository;
  final DateTime Function() _clock;
  final String _schemaVersion;

  static const String _defaultSchemaVersion = '1.0.0';

  @override
  Future<ExportBundle> call() async {
    final DateTime generatedAt = _clock().toUtc();

    final Future<List<AccountEntity>> accountsFuture = _repository
        .fetchAccounts();
    final Future<List<TransactionEntity>> transactionsFuture = _repository
        .fetchTransactions();
    final Future<List<Category>> categoriesFuture = _repository
        .fetchCategories();

    final List<AccountEntity> accounts = await accountsFuture;
    final List<TransactionEntity> transactions = await transactionsFuture;
    final List<Category> categories = await categoriesFuture;

    return ExportBundle(
      schemaVersion: _schemaVersion,
      generatedAt: generatedAt,
      accounts: accounts,
      transactions: transactions,
      categories: categories,
    );
  }
}
