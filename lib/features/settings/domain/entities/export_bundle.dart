import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

part 'export_bundle.freezed.dart';
part 'export_bundle.g.dart';

/// Снимок пользовательских данных, подготовленный для экспорта.
@freezed
abstract class ExportBundle with _$ExportBundle {
  const ExportBundle._();

  const factory ExportBundle({
    /// Версия схемы экспортируемых данных.
    required String schemaVersion,

    /// Временная метка формирования бандла.
    required DateTime generatedAt,

    /// Набор локальных счетов.
    @Default(<AccountEntity>[]) List<AccountEntity> accounts,

    /// Набор локальных транзакций.
    @Default(<TransactionEntity>[]) List<TransactionEntity> transactions,

    /// Набор локальных категорий.
    @Default(<Category>[]) List<Category> categories,
  }) = _ExportBundle;

  factory ExportBundle.fromJson(Map<String, Object?> json) =>
      _$ExportBundleFromJson(json);
}
