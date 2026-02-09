import 'dart:convert';
import 'dart:typed_data';

import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/entities/exported_file.dart';
import 'package:kopim/features/settings/domain/services/csv_codec.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

/// Кодирует `ExportBundle` в CSV-файл с секциями.
class ExportBundleCsvEncoder {
  const ExportBundleCsvEncoder();

  ExportedFile encode(ExportBundle bundle) {
    final List<List<String>> rows = <List<String>>[
      <String>['#kopim-export'],
      <String>['#schema_version', bundle.schemaVersion],
      <String>['#generated_at', bundle.generatedAt.toIso8601String()],
    ];

    _addAccounts(rows, bundle.accounts);
    _addCategories(rows, bundle.categories);
    _addTransactions(rows, bundle.transactions);

    final String csv = CsvCodec.encode(rows);
    final Uint8List bytes = Uint8List.fromList(utf8.encode(csv));

    final String timestamp = bundle.generatedAt.toIso8601String().replaceAll(
      ':',
      '-',
    );
    final String fileName = 'kopim-export-$timestamp.csv';

    return ExportedFile(fileName: fileName, mimeType: 'text/csv', bytes: bytes);
  }

  void _addAccounts(List<List<String>> rows, List<AccountEntity> accounts) {
    rows
      ..add(<String>['#accounts'])
      ..add(<String>[
        'id',
        'name',
        'balance',
        'opening_balance',
        'balance_minor',
        'opening_balance_minor',
        'currency_scale',
        'currency',
        'type',
        'created_at',
        'updated_at',
        'color',
        'gradient_id',
        'icon_name',
        'icon_style',
        'is_deleted',
        'is_primary',
      ]);

    for (final AccountEntity account in accounts) {
      final MoneyAmount balance = account.balanceAmount;
      final MoneyAmount openingBalance = account.openingBalanceAmount;
      rows.add(<String>[
        account.id,
        account.name,
        balance.toDouble().toString(),
        openingBalance.toDouble().toString(),
        balance.minor.toString(),
        openingBalance.minor.toString(),
        account.currencyScale?.toString() ?? '',
        account.currency,
        account.type,
        account.createdAt.toIso8601String(),
        account.updatedAt.toIso8601String(),
        account.color ?? '',
        account.gradientId ?? '',
        account.iconName ?? '',
        account.iconStyle ?? '',
        _bool(account.isDeleted),
        _bool(account.isPrimary),
      ]);
    }
  }

  void _addCategories(List<List<String>> rows, List<Category> categories) {
    rows
      ..add(<String>['#categories'])
      ..add(<String>[
        'id',
        'name',
        'type',
        'icon_json',
        'color',
        'parent_id',
        'created_at',
        'updated_at',
        'is_deleted',
        'is_system',
        'is_hidden',
        'is_favorite',
      ]);

    for (final Category category in categories) {
      rows.add(<String>[
        category.id,
        category.name,
        category.type,
        _encodeIcon(category.icon),
        category.color ?? '',
        category.parentId ?? '',
        category.createdAt.toIso8601String(),
        category.updatedAt.toIso8601String(),
        _bool(category.isDeleted),
        _bool(category.isSystem),
        _bool(category.isHidden),
        _bool(category.isFavorite),
      ]);
    }
  }

  void _addTransactions(
    List<List<String>> rows,
    List<TransactionEntity> transactions,
  ) {
    rows
      ..add(<String>['#transactions'])
      ..add(<String>[
        'id',
        'account_id',
        'category_id',
        'saving_goal_id',
        'amount',
        'amount_minor',
        'amount_scale',
        'date',
        'note',
        'type',
        'created_at',
        'updated_at',
        'is_deleted',
      ]);

    for (final TransactionEntity transaction in transactions) {
      final MoneyAmount amount = transaction.amountValue.abs();
      rows.add(<String>[
        transaction.id,
        transaction.accountId,
        transaction.categoryId ?? '',
        transaction.savingGoalId ?? '',
        amount.toDouble().toString(),
        amount.minor.toString(),
        amount.scale.toString(),
        transaction.date.toIso8601String(),
        transaction.note ?? '',
        transaction.type,
        transaction.createdAt.toIso8601String(),
        transaction.updatedAt.toIso8601String(),
        _bool(transaction.isDeleted),
      ]);
    }
  }

  String _encodeIcon(PhosphorIconDescriptor? icon) {
    if (icon == null || icon.isEmpty) {
      return '';
    }
    return jsonEncode(icon.toJson());
  }

  String _bool(bool value) => value ? 'true' : 'false';
}
