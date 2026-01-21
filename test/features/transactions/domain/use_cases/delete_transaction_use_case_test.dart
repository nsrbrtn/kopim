import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/transactions/domain/models/transaction_command_result.dart';
import 'package:kopim/features/transactions/domain/use_cases/delete_transaction_use_case.dart';
import 'package:mocktail/mocktail.dart';

class _MockTransactionRepository extends Mock
    implements TransactionRepository {}

void main() {
  late _MockTransactionRepository transactionRepository;
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
    useCase = DeleteTransactionUseCase(
      transactionRepository: transactionRepository,
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
}
