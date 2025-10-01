import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/transactions/domain/entities/add_transaction_request.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/transactions/domain/use_cases/add_transaction_use_case.dart';
import 'package:mocktail/mocktail.dart';

class _MockTransactionRepository extends Mock
    implements TransactionRepository {}

class _MockAccountRepository extends Mock implements AccountRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      TransactionEntity(
        id: 'fallback',
        accountId: 'acc',
        categoryId: null,
        amount: 0,
        date: DateTime.utc(2000),
        note: null,
        type: 'expense',
        createdAt: DateTime.utc(2000),
        updatedAt: DateTime.utc(2000),
      ),
    );
    registerFallbackValue(
      AccountEntity(
        id: 'fallback',
        name: 'Fallback',
        balance: 0,
        currency: 'USD',
        type: 'card',
        createdAt: DateTime.utc(2000),
        updatedAt: DateTime.utc(2000),
      ),
    );
  });

  late _MockTransactionRepository transactionRepository;
  late _MockAccountRepository accountRepository;
  late AddTransactionUseCase useCase;
  final DateTime fixedNow = DateTime.utc(2024, 1, 1, 12);

  setUp(() {
    transactionRepository = _MockTransactionRepository();
    accountRepository = _MockAccountRepository();
    useCase = AddTransactionUseCase(
      transactionRepository: transactionRepository,
      accountRepository: accountRepository,
      idGenerator: () => 'generated-id',
      clock: () => fixedNow,
    );
  });

  AccountEntity account0({double balance = 100}) {
    final DateTime createdAt = DateTime.utc(2023, 1, 1);
    return AccountEntity(
      id: 'acc-1',
      name: 'Main',
      balance: balance,
      currency: 'USD',
      type: 'card',
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  test('saves expense transaction and decreases account balance', () async {
    final AccountEntity account = account0(balance: 200);
    when(
      () => accountRepository.findById(account.id),
    ).thenAnswer((_) async => account);
    when(() => transactionRepository.upsert(any())).thenAnswer((_) async {});
    when(() => accountRepository.upsert(any())).thenAnswer((_) async {});

    final AddTransactionRequest request = AddTransactionRequest(
      accountId: account.id,
      amount: 50,
      date: fixedNow,
      note: 'Lunch',
      type: TransactionType.expense,
    );

    await useCase(request);

    final TransactionEntity transaction =
        verify(() => transactionRepository.upsert(captureAny())).captured.single
            as TransactionEntity;
    expect(transaction.id, 'generated-id');
    expect(transaction.accountId, account.id);
    expect(transaction.amount, 50);
    expect(transaction.type, 'expense');
    expect(transaction.note, 'Lunch');
    expect(transaction.createdAt, fixedNow.toUtc());
    expect(transaction.updatedAt, fixedNow.toUtc());

    final AccountEntity updatedAccount =
        verify(() => accountRepository.upsert(captureAny())).captured.single
            as AccountEntity;
    expect(updatedAccount.balance, closeTo(150, 1e-9));
    expect(updatedAccount.updatedAt, fixedNow.toUtc());
  });

  test('saves income transaction and increases account balance', () async {
    final AccountEntity account = account0(balance: 80);
    when(
      () => accountRepository.findById(account.id),
    ).thenAnswer((_) async => account);
    when(() => transactionRepository.upsert(any())).thenAnswer((_) async {});
    when(() => accountRepository.upsert(any())).thenAnswer((_) async {});

    final AddTransactionRequest request = AddTransactionRequest(
      accountId: account.id,
      amount: 20,
      date: fixedNow,
      note: 'Gift',
      type: TransactionType.income,
    );

    await useCase(request);

    final AccountEntity updatedAccount =
        verify(() => accountRepository.upsert(captureAny())).captured.single
            as AccountEntity;
    expect(updatedAccount.balance, closeTo(100, 1e-9));
  });

  test('throws StateError when account is missing', () async {
    when(
      () => accountRepository.findById('missing'),
    ).thenAnswer((_) async => null);

    final AddTransactionRequest request = AddTransactionRequest(
      accountId: 'missing',
      amount: 10,
      date: fixedNow,
    );

    await expectLater(() => useCase(request), throwsStateError);
    verifyNever(() => transactionRepository.upsert(any()));
    verifyNever(() => accountRepository.upsert(any()));
  });
}
