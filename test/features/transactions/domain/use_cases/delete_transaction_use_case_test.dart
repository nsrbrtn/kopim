import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/credits/domain/use_cases/sync_credit_payment_schedule_use_case.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/models/profile_command_result.dart';
import 'package:kopim/features/profile/domain/usecases/on_transaction_deleted_use_case.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/transactions/domain/models/transaction_command_result.dart';
import 'package:kopim/features/transactions/domain/use_cases/delete_transaction_use_case.dart';
import 'package:mocktail/mocktail.dart';

class _MockTransactionRepository extends Mock
    implements TransactionRepository {}

class _MockOnTransactionDeletedUseCase extends Mock
    implements OnTransactionDeletedUseCase {}

class _MockSyncCreditPaymentScheduleUseCase extends Mock
    implements SyncCreditPaymentScheduleUseCase {}

void main() {
  late _MockTransactionRepository transactionRepository;
  late _MockOnTransactionDeletedUseCase onTransactionDeletedUseCase;
  late _MockSyncCreditPaymentScheduleUseCase syncCreditPaymentScheduleUseCase;
  late DeleteTransactionUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      TransactionEntity(
        id: 'fallback',
        accountId: 'acc',
        transferAccountId: null,
        categoryId: null,
        amountMinor: BigInt.zero,
        amountScale: 2,
        date: DateTime.utc(2024, 1, 1),
        note: null,
        type: 'expense',
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 1),
      ),
    );
  });

  setUp(() {
    transactionRepository = _MockTransactionRepository();
    onTransactionDeletedUseCase = _MockOnTransactionDeletedUseCase();
    syncCreditPaymentScheduleUseCase =
        _MockSyncCreditPaymentScheduleUseCase();
    useCase = DeleteTransactionUseCase(
      transactionRepository: transactionRepository,
      onTransactionDeletedUseCase: onTransactionDeletedUseCase,
      syncCreditPaymentScheduleUseCase: syncCreditPaymentScheduleUseCase,
    );
  });

  test('deletes transaction when it exists', () async {
    final TransactionEntity transaction = TransactionEntity(
      id: 'tx-1',
      accountId: 'acc-1',
      transferAccountId: null,
      categoryId: null,
      amountMinor: BigInt.from(4000),
      amountScale: 2,
      date: DateTime.utc(2024, 2, 20),
      note: 'Taxi',
      type: 'expense',
      createdAt: DateTime.utc(2024, 2, 20),
      updatedAt: DateTime.utc(2024, 2, 20),
    );

    when(
      () => transactionRepository.findById(transaction.id),
    ).thenAnswer((_) async => transaction);
    when(
      () => transactionRepository.softDelete(transaction.id),
    ).thenAnswer((_) async {});
    when(
      () => syncCreditPaymentScheduleUseCase.call(previous: transaction),
    ).thenAnswer((_) async {});
    when(
      () => onTransactionDeletedUseCase.call(),
    ).thenAnswer(
      (_) async => ProfileCommandResult<UserProgress>(
        value: UserProgress(
          title: 'Level 1',
          nextThreshold: 10,
          updatedAt: DateTime.utc(2024, 2, 20),
        ),
      ),
    );

    final TransactionCommandResult<void> result = await useCase(transaction.id);

    verify(() => transactionRepository.softDelete(transaction.id)).called(1);
    expect(result.profileEvents, isEmpty);
  });

  test('does nothing when transaction is not found', () async {
    when(
      () => transactionRepository.findById('missing'),
    ).thenAnswer((_) async => null);

    final TransactionCommandResult<void> result = await useCase('missing');

    verifyNever(() => transactionRepository.softDelete(any()));
    expect(result.profileEvents, isEmpty);
  });

  test('still succeeds when side effects fail after soft delete', () async {
    final TransactionEntity transaction = TransactionEntity(
      id: 'tx-2',
      accountId: 'acc-1',
      amountMinor: BigInt.from(1000),
      amountScale: 2,
      date: DateTime.utc(2024, 2, 20),
      type: 'expense',
      createdAt: DateTime.utc(2024, 2, 20),
      updatedAt: DateTime.utc(2024, 2, 20),
    );

    when(
      () => transactionRepository.findById(transaction.id),
    ).thenAnswer((_) async => transaction);
    when(
      () => transactionRepository.softDelete(transaction.id),
    ).thenAnswer((_) async {});
    when(
      () => syncCreditPaymentScheduleUseCase.call(previous: transaction),
    ).thenThrow(StateError('sync failed'));
    when(
      () => onTransactionDeletedUseCase.call(),
    ).thenThrow(StateError('progress failed'));

    final TransactionCommandResult<void> result = await useCase(transaction.id);

    verify(() => transactionRepository.softDelete(transaction.id)).called(1);
    expect(result.profileEvents, isEmpty);
  });
}
