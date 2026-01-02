import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/transactions/domain/entities/add_transaction_request.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/transactions/domain/models/transaction_command_result.dart';
import 'package:kopim/features/transactions/domain/use_cases/add_transaction_use_case.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockTransactionRepository extends Mock
    implements TransactionRepository {}

class _MockAccountRepository extends Mock implements AccountRepository {}

class _MockCreditRepository extends Mock implements CreditRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      TransactionEntity(
        id: 'fallback',
        accountId: 'acc',
        transferAccountId: null,
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
  late _MockCreditRepository creditRepository;
  late AddTransactionUseCase useCase;
  final DateTime fixedNow = DateTime.utc(2024, 1, 1, 12);

  setUp(() {
    transactionRepository = _MockTransactionRepository();
    accountRepository = _MockAccountRepository();
    creditRepository = _MockCreditRepository();
    useCase = AddTransactionUseCase(
      transactionRepository: transactionRepository,
      accountRepository: accountRepository,
      creditRepository: creditRepository,
      idGenerator: () => 'generated-id',
      clock: () => fixedNow,
    );
    // По умолчанию категория не связана с кредитом
    when(
      () => creditRepository.getCreditByCategoryId(any()),
    ).thenAnswer((_) async => null);
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

    final TransactionCommandResult<TransactionEntity> createdResult =
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
    expect(createdResult.value.id, 'generated-id');
    expect(createdResult.value.amount, 50);
    expect(createdResult.profileEvents, isEmpty);

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

    final TransactionCommandResult<TransactionEntity> createdResult =
        await useCase(request);

    final AccountEntity updatedAccount =
        verify(() => accountRepository.upsert(captureAny())).captured.single
            as AccountEntity;
    expect(updatedAccount.balance, closeTo(100, 1e-9));
    expect(createdResult.value.amount, 20);
    expect(createdResult.profileEvents, isEmpty);
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

  test(
    'saves transfer transaction and moves balance between accounts',
    () async {
      final AccountEntity source = account0(balance: 200);
      final AccountEntity target = account0(balance: 40).copyWith(id: 'acc-2');
      when(
        () => accountRepository.findById(source.id),
      ).thenAnswer((_) async => source);
      when(
        () => accountRepository.findById(target.id),
      ).thenAnswer((_) async => target);
      when(() => transactionRepository.upsert(any())).thenAnswer((_) async {});
      when(() => accountRepository.upsert(any())).thenAnswer((_) async {});

      final AddTransactionRequest request = AddTransactionRequest(
        accountId: source.id,
        transferAccountId: target.id,
        amount: 50,
        date: fixedNow,
        note: 'Transfer',
        type: TransactionType.transfer,
      );

      final TransactionCommandResult<TransactionEntity> createdResult =
          await useCase(request);

      final TransactionEntity transaction =
          verify(
                () => transactionRepository.upsert(captureAny()),
              ).captured.single
              as TransactionEntity;
      expect(transaction.transferAccountId, target.id);
      expect(transaction.categoryId, isNull);
      expect(transaction.type, TransactionType.transfer.storageValue);
      expect(createdResult.value.type, TransactionType.transfer.storageValue);

      final List<AccountEntity> updatedAccounts = verify(
        () => accountRepository.upsert(captureAny()),
      ).captured.cast<AccountEntity>();
      expect(updatedAccounts.length, 2);
      final AccountEntity updatedSource = updatedAccounts.firstWhere(
        (AccountEntity account) => account.id == source.id,
      );
      final AccountEntity updatedTarget = updatedAccounts.firstWhere(
        (AccountEntity account) => account.id == target.id,
      );
      expect(updatedSource.balance, closeTo(150, 1e-9));
      expect(updatedTarget.balance, closeTo(90, 1e-9));
    },
  );
}
