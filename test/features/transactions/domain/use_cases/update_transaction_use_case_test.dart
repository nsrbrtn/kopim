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
    String? categoryId,
    String? note,
    DateTime? date,
  }) {
    final DateTime timestamp = date ?? DateTime.utc(2024, 2, 1);
    return TransactionEntity(
      id: id,
      accountId: accountId,
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

  test('updates transaction in the same account and adjusts balance', () async {
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
    when(() => accountRepository.upsert(any())).thenAnswer((_) async {});

    final UpdateTransactionRequest request = UpdateTransactionRequest(
      transactionId: original.id,
      accountId: accountId,
      amount: 50,
      date: DateTime.utc(2024, 2, 5),
      note: 'Updated lunch',
      type: TransactionType.expense,
    );

    await useCase(request);

    final AccountEntity updatedAccount =
        verify(() => accountRepository.upsert(captureAny())).captured.single
            as AccountEntity;
    expect(updatedAccount.balance, closeTo(950, 1e-9));
    expect(updatedAccount.updatedAt, fixedNow.toUtc());

    final TransactionEntity updatedTransaction =
        verify(() => transactionRepository.upsert(captureAny())).captured.single
            as TransactionEntity;
    expect(updatedTransaction.amount, 50);
    expect(updatedTransaction.note, 'Updated lunch');
    expect(updatedTransaction.updatedAt, fixedNow.toUtc());
    expect(updatedTransaction.date, request.date);
  });

  test(
    'moves transaction to another account and updates both balances',
    () async {
      const String originalAccountId = 'acc-1';
      const String newAccountId = 'acc-2';
      final TransactionEntity original = existingTransaction(
        id: 'tx-2',
        accountId: originalAccountId,
        amount: 80,
        type: TransactionType.expense,
        note: 'Groceries',
      );
      final AccountEntity sourceAccount = account(
        id: originalAccountId,
        balance: 920,
      );
      final AccountEntity targetAccount = account(
        id: newAccountId,
        balance: 500,
      );

      when(
        () => transactionRepository.findById(original.id),
      ).thenAnswer((_) async => original);
      when(
        () => accountRepository.findById(originalAccountId),
      ).thenAnswer((_) async => sourceAccount);
      when(
        () => accountRepository.findById(newAccountId),
      ).thenAnswer((_) async => targetAccount);
      when(() => transactionRepository.upsert(any())).thenAnswer((_) async {});
      when(() => accountRepository.upsert(any())).thenAnswer((_) async {});

      final UpdateTransactionRequest request = UpdateTransactionRequest(
        transactionId: original.id,
        accountId: newAccountId,
        amount: 120,
        date: DateTime.utc(2024, 2, 7),
        note: 'Freelance payment',
        type: TransactionType.income,
      );

      await useCase(request);

      final List<AccountEntity> upsertedAccounts = verify(
        () => accountRepository.upsert(captureAny()),
      ).captured.cast<AccountEntity>();
      expect(upsertedAccounts, hasLength(2));

      final AccountEntity restoredSource = upsertedAccounts.firstWhere(
        (AccountEntity e) => e.id == originalAccountId,
      );
      expect(restoredSource.balance, closeTo(1000, 1e-9));
      expect(restoredSource.updatedAt, fixedNow.toUtc());

      final AccountEntity updatedTarget = upsertedAccounts.firstWhere(
        (AccountEntity e) => e.id == newAccountId,
      );
      expect(updatedTarget.balance, closeTo(620, 1e-9));
      expect(updatedTarget.updatedAt, fixedNow.toUtc());

      final TransactionEntity updatedTransaction =
          verify(
                () => transactionRepository.upsert(captureAny()),
              ).captured.single
              as TransactionEntity;
      expect(updatedTransaction.accountId, newAccountId);
      expect(updatedTransaction.amount, 120);
      expect(updatedTransaction.type, TransactionType.income.storageValue);
      expect(updatedTransaction.note, 'Freelance payment');
    },
  );

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
    verifyNever(() => accountRepository.upsert(any()));
  });

  test('throws StateError when target account is missing', () async {
    const String originalAccountId = 'acc-1';
    const String newAccountId = 'acc-2';
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
    when(
      () => accountRepository.findById(newAccountId),
    ).thenAnswer((_) async => null);

    when(() => accountRepository.upsert(any())).thenAnswer((_) async {});

    final UpdateTransactionRequest request = UpdateTransactionRequest(
      transactionId: original.id,
      accountId: newAccountId,
      amount: 45,
      date: DateTime.utc(2024, 2, 8),
      type: TransactionType.expense,
    );

    await expectLater(() => useCase(request), throwsStateError);
    verify(() => accountRepository.upsert(any())).called(1);
    verifyNever(() => transactionRepository.upsert(any()));
  });
}
