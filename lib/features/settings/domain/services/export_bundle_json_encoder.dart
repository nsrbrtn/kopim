import 'dart:convert';
import 'dart:typed_data';

import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/settings/domain/entities/exported_file.dart';

/// Кодирует `ExportBundle` в читаемый JSON-файл.
class ExportBundleJsonEncoder {
  const ExportBundleJsonEncoder({this.indent = '  '});

  /// Отступ для форматированного JSON.
  final String indent;

  /// Создаёт DTO файла, готового к сохранению.
  ExportedFile encode(ExportBundle bundle) {
    final Map<String, dynamic> payload = <String, dynamic>{
      'schemaVersion': bundle.schemaVersion,
      'generatedAt': bundle.generatedAt.toIso8601String(),
      'accounts': bundle.accounts.map(_mapAccount).toList(growable: false),
      'transactions': bundle.transactions
          .map(_mapTransaction)
          .toList(growable: false),
      'categories': bundle.categories
          .map((Category category) => category.toJson())
          .toList(growable: false),
    };

    final JsonEncoder encoder = JsonEncoder.withIndent(indent);
    final String jsonString = encoder.convert(payload);
    final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));

    final String timestamp = bundle.generatedAt.toIso8601String().replaceAll(
      ':',
      '-',
    );

    final String fileName = 'kopim-export-$timestamp.json';

    return ExportedFile(
      fileName: fileName,
      mimeType: 'application/json',
      bytes: bytes,
    );
  }

  Map<String, dynamic> _mapAccount(AccountEntity account) {
    final MoneyAmount balance = account.balanceAmount;
    final MoneyAmount openingBalance = account.openingBalanceAmount;
    return <String, dynamic>{
      'id': account.id,
      'name': account.name,
      'balance': balance.toDouble(),
      'balanceMinor': balance.minor.toString(),
      'openingBalance': openingBalance.toDouble(),
      'openingBalanceMinor': openingBalance.minor.toString(),
      'currency': account.currency,
      'currencyScale': account.currencyScale,
      'type': account.type,
      'createdAt': account.createdAt.toIso8601String(),
      'updatedAt': account.updatedAt.toIso8601String(),
      'color': account.color,
      'gradientId': account.gradientId,
      'iconName': account.iconName,
      'iconStyle': account.iconStyle,
      'isDeleted': account.isDeleted,
      'isPrimary': account.isPrimary,
      'isHidden': account.isHidden,
    }..removeWhere((String key, Object? value) => value == null);
  }

  Map<String, dynamic> _mapTransaction(TransactionEntity transaction) {
    final MoneyAmount amount = transaction.amountValue.abs();
    return <String, dynamic>{
      'id': transaction.id,
      'accountId': transaction.accountId,
      'transferAccountId': transaction.transferAccountId,
      'categoryId': transaction.categoryId,
      'savingGoalId': transaction.savingGoalId,
      'amount': amount.toDouble(),
      'amountMinor': amount.minor.toString(),
      'amountScale': amount.scale,
      'date': transaction.date.toIso8601String(),
      'note': transaction.note,
      'type': transaction.type,
      'createdAt': transaction.createdAt.toIso8601String(),
      'updatedAt': transaction.updatedAt.toIso8601String(),
      'isDeleted': transaction.isDeleted,
    }..removeWhere((String key, Object? value) => value == null);
  }
}
