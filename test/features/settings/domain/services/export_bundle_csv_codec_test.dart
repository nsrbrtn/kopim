import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_csv_decoder.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_csv_encoder.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

void main() {
  const ExportBundleCsvEncoder encoder = ExportBundleCsvEncoder();
  const ExportBundleCsvDecoder decoder = ExportBundleCsvDecoder();

  test('encodes and decodes CSV bundle with escaped fields', () {
    final ExportBundle bundle = ExportBundle(
      schemaVersion: '1.0.0',
      generatedAt: DateTime.utc(2024, 2, 10, 12, 30),
      accounts: <AccountEntity>[
        AccountEntity(
          id: 'a1',
          name: 'Main account',
          balanceMinor: BigInt.from(120050),
          currency: 'USD',
          currencyScale: 2,
          type: 'checking',
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 2, 1),
          isPrimary: true,
        ),
      ],
      categories: <Category>[
        Category(
          id: 'c1',
          name: 'Food',
          type: 'expense',
          icon: const PhosphorIconDescriptor(
            name: 'fork-knife',
            style: PhosphorIconStyle.bold,
          ),
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 1, 2),
          isFavorite: true,
        ),
      ],
      transactions: <TransactionEntity>[
        TransactionEntity(
          id: 't1',
          accountId: 'a1',
          categoryId: 'c1',
          amountMinor: BigInt.from(1240),
          amountScale: 2,
          date: DateTime.utc(2024, 2, 9),
          note: 'Lunch, cafe\nSecond line',
          type: 'expense',
          createdAt: DateTime.utc(2024, 2, 9),
          updatedAt: DateTime.utc(2024, 2, 9),
        ),
      ],
    );

    final Uint8List bytes = encoder.encode(bundle).bytes;
    final ExportBundle decoded = decoder.decode(bytes);

    expect(decoded, bundle);
  });

  test('fails when schema version is missing', () {
    const String csv = '#kopim-export\n#generated_at,2024-01-01T00:00:00Z';
    final Uint8List bytes = Uint8List.fromList(utf8.encode(csv));

    expect(() => decoder.decode(bytes), throwsFormatException);
  });
}
