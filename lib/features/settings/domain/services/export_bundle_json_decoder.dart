import 'dart:convert';
import 'dart:typed_data';

import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

/// Декодирует JSON-представление экспортированного бандла обратно в модель.
class ExportBundleJsonDecoder {
  const ExportBundleJsonDecoder();

  /// Преобразует набор байтов JSON в [`ExportBundle`].
  ExportBundle decode(Uint8List bytes) {
    try {
      final String jsonString = utf8.decode(bytes);
      final Map<String, Object?> jsonMap =
          json.decode(jsonString) as Map<String, Object?>;
      return _parse(jsonMap);
    } on FormatException catch (error) {
      throw FormatException(
        'Некорректный формат файла экспорта: ${error.message}',
      );
    } on Object catch (error) {
      throw FormatException('Не удалось разобрать файл экспорта: $error');
    }
  }

  ExportBundle _parse(Map<String, Object?> jsonMap) {
    final String schemaVersion =
        (jsonMap['schemaVersion'] as String?)?.trim() ?? '';
    if (schemaVersion.isEmpty) {
      throw const FormatException('Не найдена версия схемы экспорта.');
    }
    final String? generatedAtRaw = jsonMap['generatedAt'] as String?;
    if (generatedAtRaw == null || generatedAtRaw.isEmpty) {
      throw const FormatException('Не найдена дата генерации экспорта.');
    }
    final DateTime generatedAt = DateTime.parse(generatedAtRaw);

    final List<AccountEntity> accounts = _parseAccounts(
      jsonMap['accounts'],
    );
    final List<TransactionEntity> transactions = _parseTransactions(
      jsonMap['transactions'],
    );
    final List<Category> categories = _parseCategories(
      jsonMap['categories'],
    );

    return ExportBundle(
      schemaVersion: schemaVersion,
      generatedAt: generatedAt,
      accounts: accounts,
      transactions: transactions,
      categories: categories,
    );
  }

  List<AccountEntity> _parseAccounts(Object? raw) {
    if (raw is! List) return const <AccountEntity>[];
    return raw
        .whereType<Map<String, Object?>>()
        .map((Map<String, Object?> data) {
          final String currency = _readString(data, 'currency');
          final int scale =
              _readInt(data['currencyScale']) ?? resolveCurrencyScale(currency);
          final double legacyBalance = _readDouble(data, 'balance');
          final double legacyOpening = _readDouble(data, 'openingBalance');
          final BigInt? balanceMinor = _readBigInt(data['balanceMinor']);
          final BigInt? openingMinor = _readBigInt(data['openingBalanceMinor']);
          final BigInt resolvedBalanceMinor = balanceMinor ??
              Money.fromDouble(legacyBalance, currency: currency, scale: scale)
                  .minor;
          final BigInt resolvedOpeningMinor = openingMinor ??
              Money.fromDouble(legacyOpening, currency: currency, scale: scale)
                  .minor;
          return AccountEntity(
            id: _readString(data, 'id'),
            name: _readString(data, 'name'),
            balanceMinor: resolvedBalanceMinor,
            openingBalanceMinor: resolvedOpeningMinor,
            currency: currency,
            currencyScale: scale,
            type: _readString(data, 'type'),
            createdAt: _readDate(data, 'createdAt'),
            updatedAt: _readDate(data, 'updatedAt'),
            color: _readOptionalString(data, 'color'),
            gradientId: _readOptionalString(data, 'gradientId'),
            iconName: _readOptionalString(data, 'iconName'),
            iconStyle: _readOptionalString(data, 'iconStyle'),
            isDeleted: _readBool(data, 'isDeleted'),
            isPrimary: _readBool(data, 'isPrimary'),
            isHidden: _readBool(data, 'isHidden'),
          );
        })
        .toList(growable: false);
  }

  List<TransactionEntity> _parseTransactions(Object? raw) {
    if (raw is! List) return const <TransactionEntity>[];
    return raw
        .whereType<Map<String, Object?>>()
        .map((Map<String, Object?> data) {
          final int scale = _readInt(data['amountScale']) ?? 2;
          final double legacyAmount = _readDouble(data, 'amount');
          final BigInt? amountMinor = _readBigInt(data['amountMinor']);
          final BigInt resolvedMinor = amountMinor ??
              Money.fromDouble(legacyAmount, currency: 'XXX', scale: scale).minor;
          return TransactionEntity(
            id: _readString(data, 'id'),
            accountId: _readString(data, 'accountId'),
            transferAccountId: _readOptionalString(data, 'transferAccountId'),
            categoryId: _readOptionalString(data, 'categoryId'),
            savingGoalId: _readOptionalString(data, 'savingGoalId'),
            amountMinor: resolvedMinor,
            amountScale: scale,
            date: _readDate(data, 'date'),
            note: _readOptionalString(data, 'note'),
            type: _readString(data, 'type'),
            createdAt: _readDate(data, 'createdAt'),
            updatedAt: _readDate(data, 'updatedAt'),
            isDeleted: _readBool(data, 'isDeleted'),
          );
        })
        .toList(growable: false);
  }

  List<Category> _parseCategories(Object? raw) {
    if (raw is! List) return const <Category>[];
    return raw
        .whereType<Map<String, Object?>>()
        .map(Category.fromJson)
        .toList(growable: false);
  }

  String _readString(Map<String, Object?> data, String key) {
    final String value = data[key]?.toString().trim() ?? '';
    if (value.isEmpty) {
      throw FormatException('Пустое значение для $key.');
    }
    return value;
  }

  String? _readOptionalString(Map<String, Object?> data, String key) {
    final String? value = data[key]?.toString().trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  double _readDouble(Map<String, Object?> data, String key) {
    final Object? value = data[key];
    if (value is num) {
      return value.toDouble();
    }
    return double.parse(value?.toString() ?? '0');
  }

  int? _readInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  BigInt? _readBigInt(Object? value) {
    if (value == null) return null;
    if (value is BigInt) return value;
    if (value is int) return BigInt.from(value);
    if (value is num) return BigInt.from(value.toInt());
    return BigInt.tryParse(value.toString());
  }

  DateTime _readDate(Map<String, Object?> data, String key) {
    final String raw = _readString(data, key);
    return DateTime.parse(raw);
  }

  bool _readBool(Map<String, Object?> data, String key) {
    final Object? raw = data[key];
    if (raw is bool) return raw;
    if (raw == null) return false;
    final String normalized = raw.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }
    throw FormatException('Некорректное значение $key: $raw.');
  }
}
