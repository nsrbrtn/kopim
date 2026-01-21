import 'dart:convert';
import 'dart:typed_data';

import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/services/csv_codec.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

/// Декодирует CSV-представление экспортированного бандла обратно в модель.
class ExportBundleCsvDecoder {
  const ExportBundleCsvDecoder();

  ExportBundle decode(Uint8List bytes) {
    try {
      final String csvString = utf8.decode(bytes);
      final List<List<String>> rows = CsvCodec.decode(csvString);
      return _parse(rows);
    } on FormatException catch (error) {
      throw FormatException(
        'Некорректный формат CSV-файла экспорта: ${error.message}',
      );
    } on Object catch (error) {
      throw FormatException('Не удалось разобрать CSV-файл экспорта: $error');
    }
  }

  ExportBundle _parse(List<List<String>> rows) {
    String? schemaVersion;
    DateTime? generatedAt;
    final List<AccountEntity> accounts = <AccountEntity>[];
    final List<Category> categories = <Category>[];
    final List<TransactionEntity> transactions = <TransactionEntity>[];

    int index = 0;
    while (index < rows.length) {
      final List<String> row = rows[index];
      if (_isEmptyRow(row)) {
        index += 1;
        continue;
      }
      final String marker = row.first.trim();
      if (!marker.startsWith('#')) {
        index += 1;
        continue;
      }

      switch (marker) {
        case '#kopim-export':
          index += 1;
          break;
        case '#schema_version':
          schemaVersion = _readMetaValue(row, marker);
          index += 1;
          break;
        case '#generated_at':
          generatedAt = DateTime.parse(_readMetaValue(row, marker));
          index += 1;
          break;
        case '#accounts':
          index = _parseAccounts(rows, index + 1, accounts);
          break;
        case '#categories':
          index = _parseCategories(rows, index + 1, categories);
          break;
        case '#transactions':
          index = _parseTransactions(rows, index + 1, transactions);
          break;
        default:
          index += 1;
          break;
      }
    }

    if (schemaVersion == null || schemaVersion.isEmpty) {
      throw const FormatException('Не найдена версия схемы экспорта.');
    }
    if (generatedAt == null) {
      throw const FormatException('Не найдена дата генерации экспорта.');
    }

    return ExportBundle(
      schemaVersion: schemaVersion,
      generatedAt: generatedAt,
      accounts: accounts,
      categories: categories,
      transactions: transactions,
    );
  }

  int _parseAccounts(
    List<List<String>> rows,
    int startIndex,
    List<AccountEntity> accounts,
  ) {
    final _SectionHeader header = _readHeader(rows, startIndex, '#accounts');
    int index = header.nextIndex;
    while (index < rows.length && !_isSectionMarker(rows[index])) {
      final List<String> row = rows[index];
      if (_isEmptyRow(row)) {
        index += 1;
        continue;
      }
      accounts.add(() {
        final String currency = _readRequired(header.columns, row, 'currency');
        final int scale =
            _readOptionalInt(header.columns, row, 'currency_scale') ??
            resolveCurrencyScale(currency);
        final double legacyBalance = _readDouble(
          header.columns,
          row,
          'balance',
        );
        final double legacyOpening = _readOptionalDouble(
          header.columns,
          row,
          'opening_balance',
        );
        final BigInt? balanceMinor = _readOptionalBigInt(
          header.columns,
          row,
          'balance_minor',
        );
        final BigInt? openingMinor = _readOptionalBigInt(
          header.columns,
          row,
          'opening_balance_minor',
        );
        final BigInt resolvedBalanceMinor =
            balanceMinor ??
            Money.fromDouble(
              legacyBalance,
              currency: currency,
              scale: scale,
            ).minor;
        final BigInt resolvedOpeningMinor =
            openingMinor ??
            Money.fromDouble(
              legacyOpening,
              currency: currency,
              scale: scale,
            ).minor;
        return AccountEntity(
          id: _readRequired(header.columns, row, 'id'),
          name: _readRequired(header.columns, row, 'name'),
          balanceMinor: resolvedBalanceMinor,
          openingBalanceMinor: resolvedOpeningMinor,
          currency: currency,
          currencyScale: scale,
          type: _readRequired(header.columns, row, 'type'),
          createdAt: _readDate(header.columns, row, 'created_at'),
          updatedAt: _readDate(header.columns, row, 'updated_at'),
          color: _readOptional(header.columns, row, 'color'),
          gradientId: _readOptional(header.columns, row, 'gradient_id'),
          iconName: _readOptional(header.columns, row, 'icon_name'),
          iconStyle: _readOptional(header.columns, row, 'icon_style'),
          isDeleted: _readBool(header.columns, row, 'is_deleted'),
          isPrimary: _readBool(header.columns, row, 'is_primary'),
        );
      }());
      index += 1;
    }
    return index;
  }

  int _parseCategories(
    List<List<String>> rows,
    int startIndex,
    List<Category> categories,
  ) {
    final _SectionHeader header = _readHeader(rows, startIndex, '#categories');
    int index = header.nextIndex;
    while (index < rows.length && !_isSectionMarker(rows[index])) {
      final List<String> row = rows[index];
      if (_isEmptyRow(row)) {
        index += 1;
        continue;
      }
      categories.add(
        Category(
          id: _readRequired(header.columns, row, 'id'),
          name: _readRequired(header.columns, row, 'name'),
          type: _readRequired(header.columns, row, 'type'),
          icon: _readIcon(header.columns, row, 'icon_json'),
          color: _readOptional(header.columns, row, 'color'),
          parentId: _readOptional(header.columns, row, 'parent_id'),
          createdAt: _readDate(header.columns, row, 'created_at'),
          updatedAt: _readDate(header.columns, row, 'updated_at'),
          isDeleted: _readBool(header.columns, row, 'is_deleted'),
          isSystem: _readBool(header.columns, row, 'is_system'),
          isFavorite: _readBool(header.columns, row, 'is_favorite'),
        ),
      );
      index += 1;
    }
    return index;
  }

  int _parseTransactions(
    List<List<String>> rows,
    int startIndex,
    List<TransactionEntity> transactions,
  ) {
    final _SectionHeader header = _readHeader(
      rows,
      startIndex,
      '#transactions',
    );
    int index = header.nextIndex;
    while (index < rows.length && !_isSectionMarker(rows[index])) {
      final List<String> row = rows[index];
      if (_isEmptyRow(row)) {
        index += 1;
        continue;
      }
      transactions.add(() {
        final int scale =
            _readOptionalInt(header.columns, row, 'amount_scale') ?? 2;
        final double legacyAmount = _readDouble(header.columns, row, 'amount');
        final BigInt? amountMinor = _readOptionalBigInt(
          header.columns,
          row,
          'amount_minor',
        );
        final BigInt resolvedMinor =
            amountMinor ??
            Money.fromDouble(legacyAmount, currency: 'XXX', scale: scale).minor;
        return TransactionEntity(
          id: _readRequired(header.columns, row, 'id'),
          accountId: _readRequired(header.columns, row, 'account_id'),
          categoryId: _readOptional(header.columns, row, 'category_id'),
          savingGoalId: _readOptional(header.columns, row, 'saving_goal_id'),
          amountMinor: resolvedMinor,
          amountScale: scale,
          date: _readDate(header.columns, row, 'date'),
          note: _readOptional(header.columns, row, 'note'),
          type: _readRequired(header.columns, row, 'type'),
          createdAt: _readDate(header.columns, row, 'created_at'),
          updatedAt: _readDate(header.columns, row, 'updated_at'),
          isDeleted: _readBool(header.columns, row, 'is_deleted'),
        );
      }());
      index += 1;
    }
    return index;
  }

  _SectionHeader _readHeader(
    List<List<String>> rows,
    int startIndex,
    String sectionName,
  ) {
    if (startIndex >= rows.length) {
      throw FormatException('Отсутствует заголовок секции $sectionName.');
    }
    final List<String> headerRow = rows[startIndex];
    if (_isEmptyRow(headerRow) || _isSectionMarker(headerRow)) {
      throw FormatException('Пустой заголовок секции $sectionName.');
    }
    final Map<String, int> columns = <String, int>{};
    for (int index = 0; index < headerRow.length; index += 1) {
      final String key = headerRow[index].trim().toLowerCase();
      if (key.isEmpty) {
        continue;
      }
      columns[key] = index;
    }
    return _SectionHeader(columns: columns, nextIndex: startIndex + 1);
  }

  bool _isSectionMarker(List<String> row) {
    if (_isEmptyRow(row)) {
      return false;
    }
    return row.first.trim().startsWith('#');
  }

  bool _isEmptyRow(List<String> row) {
    return row.isEmpty || row.every((String cell) => cell.trim().isEmpty);
  }

  String _readMetaValue(List<String> row, String marker) {
    if (row.length < 2) {
      throw FormatException('Отсутствует значение для $marker.');
    }
    return row[1].trim();
  }

  String _readRequired(Map<String, int> columns, List<String> row, String key) {
    final int? index = columns[key];
    if (index == null) {
      throw FormatException('Отсутствует колонка $key.');
    }
    final String value = _readCell(row, index);
    if (value.isEmpty) {
      throw FormatException('Пустое значение для $key.');
    }
    return value;
  }

  String _readCell(List<String> row, int index) {
    if (index < 0 || index >= row.length) {
      return '';
    }
    return row[index].trim();
  }

  String? _readOptional(
    Map<String, int> columns,
    List<String> row,
    String key,
  ) {
    final int? index = columns[key];
    if (index == null) {
      return null;
    }
    final String value = _readCell(row, index);
    return value.isEmpty ? null : value;
  }

  double _readDouble(Map<String, int> columns, List<String> row, String key) {
    final String raw = _readRequired(columns, row, key);
    return double.parse(raw.trim());
  }

  double _readOptionalDouble(
    Map<String, int> columns,
    List<String> row,
    String key, {
    double fallback = 0,
  }) {
    final int? index = columns[key];
    if (index == null) {
      return fallback;
    }
    final String raw = _readCell(row, index);
    if (raw.isEmpty) {
      return fallback;
    }
    return double.parse(raw.trim());
  }

  int? _readOptionalInt(
    Map<String, int> columns,
    List<String> row,
    String key,
  ) {
    final int? index = columns[key];
    if (index == null) {
      return null;
    }
    final String raw = _readCell(row, index);
    if (raw.isEmpty) {
      return null;
    }
    return int.tryParse(raw.trim());
  }

  BigInt? _readOptionalBigInt(
    Map<String, int> columns,
    List<String> row,
    String key,
  ) {
    final int? index = columns[key];
    if (index == null) {
      return null;
    }
    final String raw = _readCell(row, index);
    if (raw.isEmpty) {
      return null;
    }
    return BigInt.tryParse(raw.trim());
  }

  DateTime _readDate(Map<String, int> columns, List<String> row, String key) {
    final String raw = _readRequired(columns, row, key);
    return DateTime.parse(raw.trim());
  }

  bool _readBool(Map<String, int> columns, List<String> row, String key) {
    final String? raw = _readOptional(columns, row, key);
    if (raw == null || raw.isEmpty) {
      return false;
    }
    final String normalized = raw.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }
    throw FormatException('Некорректное значение $key: $raw.');
  }

  PhosphorIconDescriptor? _readIcon(
    Map<String, int> columns,
    List<String> row,
    String key,
  ) {
    final String? raw = _readOptional(columns, row, key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Некорректный формат иконки категории.');
    }
    return PhosphorIconDescriptor.fromJson(decoded);
  }
}

class _SectionHeader {
  const _SectionHeader({required this.columns, required this.nextIndex});

  final Map<String, int> columns;
  final int nextIndex;
}
