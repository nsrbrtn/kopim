import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/entities/update_transaction_request.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/transactions/domain/use_cases/update_transaction_use_case.dart';
import 'package:mocktail/mocktail.dart';

class _MockTransactionRepository extends Mock
    implements TransactionRepository {}

class _MockAccountRepository extends Mock implements AccountRepository {}

void main() {
  late _MockTransactionRepository transactionRepository;
  late _MockAccountRepository accountRepository;
  late UpdateTransactionUseCase useCase;
  final DateTime fixedNow = DateTime.utc(2024, 2, 10, 12, 30);

  TransactionEntity existingTransaction({
    required String id,
    required String accountId,
    required double amount,
    required TransactionType type,
    String? transferAccountId,
    String? categoryId,
    String? note,
    DateTime? date,
  }) {
    final DateTime timestamp = date ?? DateTime.utc(2024, 2, 1);
    return TransactionEntity(
      id: id,
      accountId: accountId,
      transferAccountId: transferAccountId,
      categoryId: categoryId,
      amount: amount,
      date: timestamp,
      note: note,
      type: type.storageValue,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  AccountEntity account({required String id, required double balance}) {
    final DateTime timestamp = DateTime.utc(2024, 1, 1);
    return AccountEntity(
      id: id,
      name: 'Account $id',
      balance: balance,
      currency: 'USD',
      type: 'card',
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  setUpAll(() {
    registerFallbackValue(
      TransactionEntity(
        id: 'fallback',
        accountId: 'fallback',
        transferAccountId: null,
        categoryId: null,
        amount: 0,
        date: DateTime.utc(2024, 1, 1),
        note: null,
        type: TransactionType.expense.storageValue,
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 1),
      ),
    );
    registerFallbackValue(
      AccountEntity(
        id: 'fallback',
        name: 'Fallback',
        balance: 0,
        currency: 'USD',
        type: 'card',
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 1),
      ),
    );
    registerFallbackValue(
      UpdateTransactionRequest(
        transactionId: 'fallback',
        accountId: 'fallback',
        amount: 1,
        date: DateTime.utc(2024, 1, 1),
        type: TransactionType.expense,
      ),
    );
  });

  setUp(() {
    transactionRepository = _MockTransactionRepository();
    accountRepository = _MockAccountRepository();
    useCase = UpdateTransactionUseCase(
      transactionRepository: transactionRepository,
      accountRepository: accountRepository,
      clock: () => fixedNow,
    );
  });

  test('updates transaction in the same account', () async {
    const String accountId = 'acc-1';
    final TransactionEntity original = existingTransaction(
      id: 'tx-1',
      accountId: accountId,
      amount: 100,
      type: TransactionType.expense,
    );
    final AccountEntity sourceAccount = account(id: accountId, balance: 900);

    when(
      () => transactionRepository.findById(original.id),
    ).thenAnswer((_) async => original);
    when(
      () => accountRepository.findById(accountId),
    ).thenAnswer((_) async => sourceAccount);
    when(() => transactionRepository.upsert(any())).thenAnswer((_) async {});

    final UpdateTransactionRequest request = UpdateTransactionRequest(
      transactionId: original.id,
      accountId: accountId,
      amount: 50,
      date: DateTime.utc(2024, 2, 5),
      note: 'Updated lunch',
      type: TransactionType.expense,
    );

    await useCase(request);

    final TransactionEntity updatedTransaction =
        verify(() => transactionRepository.upsert(captureAny())).captured.single
            as TransactionEntity;
    expect(updatedTransaction.amount, 50);
    expect(updatedTransaction.note, 'Updated lunch');
    expect(updatedTransaction.updatedAt, fixedNow.toUtc());
    expect(updatedTransaction.date, request.date);
  });

  test('throws StateError when transaction does not exist', () async {
    when(
      () => transactionRepository.findById('missing'),
    ).thenAnswer((_) async => null);

    final UpdateTransactionRequest request = UpdateTransactionRequest(
      transactionId: 'missing',
      accountId: 'acc',
      amount: 10,
      date: DateTime.utc(2024, 2, 1),
      type: TransactionType.expense,
    );

    await expectLater(() => useCase(request), throwsStateError);
    verifyNever(() => transactionRepository.upsert(any()));
  });

  test('throws StateError when account is missing', () async {
    const String originalAccountId = 'acc-1';
    final TransactionEntity original = existingTransaction(
      id: 'tx-3',
      accountId: originalAccountId,
      amount: 30,
      type: TransactionType.income,
    );
    final AccountEntity sourceAccount = account(
      id: originalAccountId,
      balance: 1030,
    );

    when(
      () => transactionRepository.findById(original.id),
    ).thenAnswer((_) async => original);
    when(
      () => accountRepository.findById(originalAccountId),
    ).thenAnswer((_) async => sourceAccount);
    when(() => accountRepository.findById('missing')).thenAnswer((_) async => null);

    final UpdateTransactionRequest request = UpdateTransactionRequest(
      transactionId: original.id,
      accountId: 'missing',
      amount: 45,
      date: DateTime.utc(2024, 2, 8),
      type: TransactionType.expense,
    );

    await expectLater(() => useCase(request), throwsStateError);
    verifyNever(() => transactionRepository.upsert(any()));
  });

  test(
    'validates target account for transfer updates',
    () async {
      const String sourceId = 'acc-1';
      const String newTargetId = 'acc-3';
      final TransactionEntity original = existingTransaction(
        id: 'tx-4',
        accountId: sourceId,
        transferAccountId: 'acc-2',
        amount: 40,
        type: TransactionType.transfer,
      );
      final AccountEntity sourceAccount = account(id: sourceId, balance: 200);
      final AccountEntity newTargetAccount = account(
        id: newTargetId,
        balance: 30,
      );

      when(
        () => transactionRepository.findById(original.id),
      ).thenAnswer((_) async => original);
      when(
        () => accountRepository.findById(sourceId),
      ).thenAnswer((_) async => sourceAccount);
      when(
        () => accountRepository.findById(newTargetId),
      ).thenAnswer((_) async => newTargetAccount);
      when(() => transactionRepository.upsert(any())).thenAnswer((_) async {});

      final UpdateTransactionRequest request = UpdateTransactionRequest(
        transactionId: original.id,
        accountId: sourceId,
        transferAccountId: newTargetId,
        amount: 60,
        date: DateTime.utc(2024, 2, 8),
        type: TransactionType.transfer,
      );

      await useCase(request);

      verify(() => transactionRepository.upsert(any())).called(1);
    },
  );
}
