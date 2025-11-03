import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/entities/picked_import_file.dart';
import 'package:kopim/features/settings/domain/repositories/import_data_repository.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_json_decoder.dart';
import 'package:kopim/features/settings/domain/services/import_file_picker.dart';
import 'package:kopim/features/settings/domain/use_cases/import_user_data_result.dart';
import 'package:kopim/features/settings/domain/use_cases/import_user_data_use_case_impl.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

class _MockImportFilePicker extends Mock implements ImportFilePicker {}

class _MockExportBundleJsonDecoder extends Mock
    implements ExportBundleJsonDecoder {}

class _MockImportDataRepository extends Mock implements ImportDataRepository {}

void main() {
  late _MockImportFilePicker filePicker;
  late _MockExportBundleJsonDecoder decoder;
  late _MockImportDataRepository repository;
  late ImportUserDataUseCaseImpl useCase;

  setUp(() {
    filePicker = _MockImportFilePicker();
    decoder = _MockExportBundleJsonDecoder();
    repository = _MockImportDataRepository();
    useCase = ImportUserDataUseCaseImpl(
      filePicker: filePicker,
      decoder: decoder,
      repository: repository,
    );
  });

  test('returns cancelled when user dismisses picker', () async {
    when(() => filePicker.pickJsonFile()).thenAnswer((_) async => null);

    final ImportUserDataResult result = await useCase();

    expect(result, const ImportUserDataResult.cancelled());
    verify(() => filePicker.pickJsonFile()).called(1);
    verifyNoMoreInteractions(decoder);
    verifyNoMoreInteractions(repository);
  });

  test('imports bundle and returns success with stats', () async {
    final PickedImportFile pickedFile = PickedImportFile(
      fileName: 'backup.json',
      bytes: Uint8List(0),
    );

    final ExportBundle bundle = ExportBundle(
      schemaVersion: '1.0.0',
      generatedAt: DateTime.utc(2024, 1, 1),
      accounts: <AccountEntity>[
        AccountEntity(
          id: 'a1',
          name: 'Main',
          balance: 100,
          currency: 'USD',
          type: 'checking',
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 1, 2),
        ),
      ],
      categories: <Category>[
        Category(
          id: 'c1',
          name: 'Food',
          type: 'expense',
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 1, 1),
        ),
      ],
      transactions: <TransactionEntity>[
        TransactionEntity(
          id: 't1',
          accountId: 'a1',
          categoryId: 'c1',
          amount: 12,
          date: DateTime.utc(2024, 1, 3),
          type: 'expense',
          createdAt: DateTime.utc(2024, 1, 3),
          updatedAt: DateTime.utc(2024, 1, 3),
        ),
      ],
    );

    when(() => filePicker.pickJsonFile()).thenAnswer((_) async => pickedFile);
    when(() => decoder.decode(pickedFile.bytes)).thenReturn(bundle);
    when(
      () => repository.upsertAccounts(bundle.accounts),
    ).thenAnswer((_) async {});
    when(
      () => repository.upsertCategories(bundle.categories),
    ).thenAnswer((_) async {});
    when(
      () => repository.upsertTransactions(bundle.transactions),
    ).thenAnswer((_) async {});

    final ImportUserDataResult result = await useCase();

    expect(result, isA<ImportUserDataResultSuccess>());
    result.map(
      success: (ImportUserDataResultSuccess success) {
        expect(success.accounts, 1);
        expect(success.categories, 1);
        expect(success.transactions, 1);
      },
      cancelled: (_) => fail('Should not be cancelled'),
      failure: (_) => fail('Should not fail'),
    );

    verify(() => repository.upsertAccounts(bundle.accounts)).called(1);
    verify(() => repository.upsertCategories(bundle.categories)).called(1);
    verify(() => repository.upsertTransactions(bundle.transactions)).called(1);
  });

  test('returns failure when decoder throws FormatException', () async {
    final PickedImportFile pickedFile = PickedImportFile(
      fileName: 'backup.json',
      bytes: Uint8List(0),
    );

    when(() => filePicker.pickJsonFile()).thenAnswer((_) async => pickedFile);
    when(
      () => decoder.decode(pickedFile.bytes),
    ).thenThrow(const FormatException('Invalid JSON'));

    final ImportUserDataResult result = await useCase();

    expect(result, const ImportUserDataResult.failure('Invalid JSON'));
  });

  test('returns failure when repository throws', () async {
    final PickedImportFile pickedFile = PickedImportFile(
      fileName: 'backup.json',
      bytes: Uint8List(0),
    );
    final ExportBundle bundle = ExportBundle(
      schemaVersion: '1.0.0',
      generatedAt: DateTime.utc(2024, 1, 1),
    );

    when(() => filePicker.pickJsonFile()).thenAnswer((_) async => pickedFile);
    when(() => decoder.decode(pickedFile.bytes)).thenReturn(bundle);
    when(
      () => repository.upsertAccounts(bundle.accounts),
    ).thenThrow(Exception('db error'));

    final ImportUserDataResult result = await useCase();

    expect(result, const ImportUserDataResult.failure('Exception: db error'));
  });
}
