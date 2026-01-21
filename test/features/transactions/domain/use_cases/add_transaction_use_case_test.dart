import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/transactions/domain/entities/add_transaction_request.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/transactions/domain/models/transaction_command_result.dart';
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
        transferAccountId: null,
        categoryId: null,
        amountMinor: BigInt.zero,
        amountScale: 2,
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
        balanceMinor: BigInt.zero,
        currency: 'USD',
        currencyScale: 2,
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

  AccountEntity account0({int balance = 100}) {
    final DateTime createdAt = DateTime.utc(2023, 1, 1);
    return AccountEntity(
      id: 'acc-1',
      name: 'Main',
      balanceMinor: BigInt.from(balance * 100),
      currency: 'USD',
      currencyScale: 2,
      type: 'card',
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  test('saves expense transaction', () async {
    final AccountEntity account = account0(balance: 200);
    when(
      () => accountRepository.findById(account.id),
    ).thenAnswer((_) async => account);
    when(() => transactionRepository.upsert(any())).thenAnswer((_) async {});

    final AddTransactionRequest request = AddTransactionRequest(
      accountId: account.id,
      amount: _amount(50),
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
    expect(transaction.amountValue, _amount(50));
    expect(transaction.type, 'expense');
    expect(transaction.note, 'Lunch');
    expect(transaction.createdAt, fixedNow.toUtc());
    expect(transaction.updatedAt, fixedNow.toUtc());
    expect(createdResult.value.id, 'generated-id');
    expect(createdResult.value.amountValue, _amount(50));
    expect(createdResult.profileEvents, isEmpty);
  });

  test('saves income transaction', () async {
    final AccountEntity account = account0(balance: 80);
    when(
      () => accountRepository.findById(account.id),
    ).thenAnswer((_) async => account);
    when(() => transactionRepository.upsert(any())).thenAnswer((_) async {});

    final AddTransactionRequest request = AddTransactionRequest(
      accountId: account.id,
      amount: _amount(20),
      date: fixedNow,
      note: 'Gift',
      type: TransactionType.income,
    );

    final TransactionCommandResult<TransactionEntity> createdResult =
        await useCase(request);

    expect(createdResult.value.amountValue, _amount(20));
    expect(createdResult.profileEvents, isEmpty);
  });

  test('throws StateError when account is missing', () async {
    when(
      () => accountRepository.findById('missing'),
    ).thenAnswer((_) async => null);

    final AddTransactionRequest request = AddTransactionRequest(
      accountId: 'missing',
      amount: _amount(10),
      date: fixedNow,
    );

    await expectLater(() => useCase(request), throwsStateError);
    verifyNever(() => transactionRepository.upsert(any()));
  });

  test('saves transfer transaction after validating accounts', () async {
    final AccountEntity source = account0(balance: 200);
    final AccountEntity target = account0(balance: 40).copyWith(id: 'acc-2');
    when(
      () => accountRepository.findById(source.id),
    ).thenAnswer((_) async => source);
    when(
      () => accountRepository.findById(target.id),
    ).thenAnswer((_) async => target);
    when(() => transactionRepository.upsert(any())).thenAnswer((_) async {});

    final AddTransactionRequest request = AddTransactionRequest(
      accountId: source.id,
      transferAccountId: target.id,
      amount: _amount(50),
      date: fixedNow,
      note: 'Transfer',
      type: TransactionType.transfer,
    );

    final TransactionCommandResult<TransactionEntity> createdResult =
        await useCase(request);

    final TransactionEntity transaction =
        verify(() => transactionRepository.upsert(captureAny())).captured.single
            as TransactionEntity;
    expect(transaction.transferAccountId, target.id);
    expect(transaction.categoryId, isNull);
    expect(transaction.type, TransactionType.transfer.storageValue);
    expect(createdResult.value.type, TransactionType.transfer.storageValue);
  });
}

MoneyAmount _amount(int value, {int scale = 2}) {
  return MoneyAmount(minor: BigInt.from(value * 100), scale: scale);
}
