import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/entities/data_transfer_format.dart';
import 'package:kopim/features/settings/domain/entities/picked_import_file.dart';
import 'package:kopim/features/settings/domain/repositories/import_data_repository.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_csv_decoder.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_json_decoder.dart';
import 'package:kopim/features/settings/domain/services/import_file_picker.dart';
import 'package:kopim/features/settings/domain/use_cases/import_user_data_result.dart';
import 'package:kopim/features/settings/domain/use_cases/import_user_data_use_case.dart';
import 'package:kopim/features/settings/domain/use_cases/import_user_data_use_case_impl.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

class _MockImportFilePicker extends Mock implements ImportFilePicker {}

class _MockExportBundleJsonDecoder extends Mock
    implements ExportBundleJsonDecoder {}

class _MockExportBundleCsvDecoder extends Mock
    implements ExportBundleCsvDecoder {}

class _MockImportDataRepository extends Mock implements ImportDataRepository {}

void main() {
  late _MockImportFilePicker filePicker;
  late _MockExportBundleJsonDecoder decoder;
  late _MockExportBundleCsvDecoder csvDecoder;
  late _MockImportDataRepository repository;
  late ImportUserDataUseCaseImpl useCase;

  setUp(() {
    filePicker = _MockImportFilePicker();
    decoder = _MockExportBundleJsonDecoder();
    csvDecoder = _MockExportBundleCsvDecoder();
    repository = _MockImportDataRepository();
    useCase = ImportUserDataUseCaseImpl(
      filePicker: filePicker,
      jsonDecoder: decoder,
      csvDecoder: csvDecoder,
      repository: repository,
    );
  });

  test('returns cancelled when user dismisses picker', () async {
    when(
      () => filePicker.pickFile(DataTransferFormat.csv),
    ).thenAnswer((_) async => null);

    final ImportUserDataResult result = await useCase(
      const ImportUserDataParams(),
    );

    expect(result, const ImportUserDataResult.cancelled());
    verify(() => filePicker.pickFile(DataTransferFormat.csv)).called(1);
    verifyNoMoreInteractions(decoder);
    verifyNoMoreInteractions(csvDecoder);
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
          balanceMinor: BigInt.from(10000),
          currency: 'USD',
          currencyScale: 2,
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
      savingGoals: <SavingGoal>[
        SavingGoal(
          id: 'sg1',
          userId: 'u1',
          name: 'Vacation',
          accountId: 'a1',
          targetAmount: 50000,
          currentAmount: 1200,
          createdAt: DateTime.utc(2024, 1, 2),
          updatedAt: DateTime.utc(2024, 1, 3),
        ),
      ],
      transactions: <TransactionEntity>[
        TransactionEntity(
          id: 't1',
          accountId: 'a1',
          categoryId: 'c1',
          amountMinor: BigInt.from(1200),
          amountScale: 2,
          date: DateTime.utc(2024, 1, 3),
          type: 'expense',
          createdAt: DateTime.utc(2024, 1, 3),
          updatedAt: DateTime.utc(2024, 1, 3),
        ),
      ],
    );

    when(
      () => filePicker.pickFile(DataTransferFormat.json),
    ).thenAnswer((_) async => pickedFile);
    when(() => decoder.decode(pickedFile.bytes)).thenReturn(bundle);
    when(
      () => repository.importData(
        accounts: bundle.accounts,
        categories: bundle.categories,
        savingGoals: bundle.savingGoals,
        transactions: bundle.transactions,
      ),
    ).thenAnswer((_) async {});

    final ImportUserDataResult result = await useCase(
      const ImportUserDataParams(format: DataTransferFormat.json),
    );

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

    verify(
      () => repository.importData(
        accounts: bundle.accounts,
        categories: bundle.categories,
        savingGoals: bundle.savingGoals,
        transactions: bundle.transactions,
      ),
    ).called(1);
  });

  test('uses csv decoder by default', () async {
    final PickedImportFile pickedFile = PickedImportFile(
      fileName: 'backup.csv',
      bytes: Uint8List(0),
    );
    final ExportBundle bundle = ExportBundle(
      schemaVersion: '1.0.0',
      generatedAt: DateTime.utc(2024, 1, 1),
    );

    when(
      () => filePicker.pickFile(DataTransferFormat.csv),
    ).thenAnswer((_) async => pickedFile);
    when(() => csvDecoder.decode(pickedFile.bytes)).thenReturn(bundle);
    when(
      () => repository.importData(
        accounts: bundle.accounts,
        categories: bundle.categories,
        savingGoals: bundle.savingGoals,
        transactions: bundle.transactions,
      ),
    ).thenAnswer((_) async {});

    final ImportUserDataResult result = await useCase(
      const ImportUserDataParams(),
    );

    expect(result, isA<ImportUserDataResultSuccess>());
    verify(() => csvDecoder.decode(pickedFile.bytes)).called(1);
    verifyNever(() => decoder.decode(pickedFile.bytes));
  });

  test('returns failure when decoder throws FormatException', () async {
    final PickedImportFile pickedFile = PickedImportFile(
      fileName: 'backup.json',
      bytes: Uint8List(0),
    );

    when(
      () => filePicker.pickFile(DataTransferFormat.json),
    ).thenAnswer((_) async => pickedFile);
    when(
      () => decoder.decode(pickedFile.bytes),
    ).thenThrow(const FormatException('Invalid JSON'));

    final ImportUserDataResult result = await useCase(
      const ImportUserDataParams(format: DataTransferFormat.json),
    );

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

    when(
      () => filePicker.pickFile(DataTransferFormat.json),
    ).thenAnswer((_) async => pickedFile);
    when(() => decoder.decode(pickedFile.bytes)).thenReturn(bundle);
    when(
      () => repository.importData(
        accounts: bundle.accounts,
        categories: bundle.categories,
        savingGoals: bundle.savingGoals,
        transactions: bundle.transactions,
      ),
    ).thenThrow(Exception('db error'));

    final ImportUserDataResult result = await useCase(
      const ImportUserDataParams(format: DataTransferFormat.json),
    );

    expect(result, const ImportUserDataResult.failure('Exception: db error'));
  });

  test('clears missing saving goal references for legacy backups', () async {
    final PickedImportFile pickedFile = PickedImportFile(
      fileName: 'backup.json',
      bytes: Uint8List(0),
    );
    final TransactionEntity legacyTransaction = TransactionEntity(
      id: 't1',
      accountId: 'a1',
      categoryId: 'c1',
      savingGoalId: 'missing-goal',
      amountMinor: BigInt.from(1200),
      amountScale: 2,
      date: DateTime.utc(2024, 1, 3),
      type: 'expense',
      createdAt: DateTime.utc(2024, 1, 3),
      updatedAt: DateTime.utc(2024, 1, 3),
    );
    final ExportBundle bundle = ExportBundle(
      schemaVersion: '1.1.0',
      generatedAt: DateTime.utc(2024, 1, 1),
      accounts: <AccountEntity>[
        AccountEntity(
          id: 'a1',
          name: 'Main',
          balanceMinor: BigInt.from(10000),
          currency: 'USD',
          currencyScale: 2,
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
      transactions: <TransactionEntity>[legacyTransaction],
    );

    when(
      () => filePicker.pickFile(DataTransferFormat.json),
    ).thenAnswer((_) async => pickedFile);
    when(() => decoder.decode(pickedFile.bytes)).thenReturn(bundle);
    when(
      () => repository.importData(
        accounts: bundle.accounts,
        categories: bundle.categories,
        savingGoals: bundle.savingGoals,
        transactions: <TransactionEntity>[
          legacyTransaction.copyWith(savingGoalId: null),
        ],
      ),
    ).thenAnswer((_) async {});

    final ImportUserDataResult result = await useCase(
      const ImportUserDataParams(format: DataTransferFormat.json),
    );

    expect(result, isA<ImportUserDataResultSuccess>());
    verify(
      () => repository.importData(
        accounts: bundle.accounts,
        categories: bundle.categories,
        savingGoals: bundle.savingGoals,
        transactions: <TransactionEntity>[
          legacyTransaction.copyWith(savingGoalId: null),
        ],
      ),
    ).called(1);
  });

  test(
    'skips transactions with missing source account and clears broken refs',
    () async {
      final PickedImportFile pickedFile = PickedImportFile(
        fileName: 'backup.json',
        bytes: Uint8List(0),
      );
      final TransactionEntity validTransaction = TransactionEntity(
        id: 't-valid',
        accountId: 'a1',
        transferAccountId: 'missing-transfer',
        categoryId: 'missing-category',
        amountMinor: BigInt.from(500),
        amountScale: 2,
        date: DateTime.utc(2024, 1, 3),
        type: 'expense',
        createdAt: DateTime.utc(2024, 1, 3),
        updatedAt: DateTime.utc(2024, 1, 3),
      );
      final TransactionEntity brokenTransaction = TransactionEntity(
        id: 't-broken',
        accountId: 'missing-account',
        amountMinor: BigInt.from(700),
        amountScale: 2,
        date: DateTime.utc(2024, 1, 4),
        type: 'expense',
        createdAt: DateTime.utc(2024, 1, 4),
        updatedAt: DateTime.utc(2024, 1, 4),
      );
      final ExportBundle bundle = ExportBundle(
        schemaVersion: '1.1.0',
        generatedAt: DateTime.utc(2024, 1, 1),
        accounts: <AccountEntity>[
          AccountEntity(
            id: 'a1',
            name: 'Main',
            balanceMinor: BigInt.from(10000),
            currency: 'USD',
            currencyScale: 2,
            type: 'checking',
            createdAt: DateTime.utc(2024, 1, 1),
            updatedAt: DateTime.utc(2024, 1, 2),
          ),
        ],
        categories: <Category>[],
        transactions: <TransactionEntity>[validTransaction, brokenTransaction],
      );

      when(
        () => filePicker.pickFile(DataTransferFormat.json),
      ).thenAnswer((_) async => pickedFile);
      when(() => decoder.decode(pickedFile.bytes)).thenReturn(bundle);
      when(
        () => repository.importData(
          accounts: bundle.accounts,
          categories: bundle.categories,
          savingGoals: bundle.savingGoals,
          transactions: <TransactionEntity>[
            validTransaction.copyWith(
              transferAccountId: null,
              categoryId: null,
            ),
          ],
        ),
      ).thenAnswer((_) async {});

      final ImportUserDataResult result = await useCase(
        const ImportUserDataParams(format: DataTransferFormat.json),
      );

      expect(result, isA<ImportUserDataResultSuccess>());
      verify(
        () => repository.importData(
          accounts: bundle.accounts,
          categories: bundle.categories,
          savingGoals: bundle.savingGoals,
          transactions: <TransactionEntity>[
            validTransaction.copyWith(
              transferAccountId: null,
              categoryId: null,
            ),
          ],
        ),
      ).called(1);
    },
  );
}
