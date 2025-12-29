import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/transactions/domain/models/transaction_command_result.dart';
import 'package:kopim/features/transactions/domain/use_cases/delete_transaction_use_case.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockTransactionRepository extends Mock
    implements TransactionRepository {}

class _MockAccountRepository extends Mock implements AccountRepository {}

class _MockCreditRepository extends Mock implements CreditRepository {}

void main() {
  late _MockTransactionRepository transactionRepository;
  late _MockAccountRepository accountRepository;
  late _MockCreditRepository creditRepository;
  late DeleteTransactionUseCase useCase;
  final DateTime fixedNow = DateTime.utc(2024, 3, 1, 9, 0);

  setUpAll(() {
    registerFallbackValue(
      TransactionEntity(
        id: 'fallback',
        accountId: 'acc',
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
        id: 'acc',
        name: 'Account',
        balance: 0,
        currency: 'USD',
        type: 'cash',
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 1),
      ),
    );
  });

  setUp(() {
    transactionRepository = _MockTransactionRepository();
    accountRepository = _MockAccountRepository();
    creditRepository = _MockCreditRepository();
    useCase = DeleteTransactionUseCase(
      transactionRepository: transactionRepository,
      accountRepository: accountRepository,
      creditRepository: creditRepository,
      clock: () => fixedNow,
    );
    // По умолчанию категория не связана с кредитом
    when(
      () => creditRepository.getCreditByCategoryId(any()),
    ).thenAnswer((_) async => null);
  });

  AccountEntity account({required double balance}) {
    final DateTime timestamp = DateTime.utc(2024, 1, 1);
    return AccountEntity(
      id: 'acc-1',
      name: 'Main',
      balance: balance,
      currency: 'USD',
      type: 'card',
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  test('restores balance when deleting an expense transaction', () async {
    final TransactionEntity transaction = TransactionEntity(
      id: 'tx-1',
      accountId: 'acc-1',
      categoryId: null,
      amount: 40,
      date: DateTime.utc(2024, 2, 20),
      note: 'Taxi',
      type: TransactionType.expense.storageValue,
      createdAt: DateTime.utc(2024, 2, 20),
      updatedAt: DateTime.utc(2024, 2, 20),
    );
    final AccountEntity existingAccount = account(balance: 860);

    when(
      () => transactionRepository.findById(transaction.id),
    ).thenAnswer((_) async => transaction);
    when(
      () => accountRepository.findById(transaction.accountId),
    ).thenAnswer((_) async => existingAccount);
    when(() => accountRepository.upsert(any())).thenAnswer((_) async {});
    when(
      () => transactionRepository.softDelete(transaction.id),
    ).thenAnswer((_) async {});

    final TransactionCommandResult<void> result = await useCase(transaction.id);

    final AccountEntity updatedAccount =
        verify(() => accountRepository.upsert(captureAny())).captured.single
            as AccountEntity;
    expect(updatedAccount.balance, closeTo(900, 1e-9));
    expect(updatedAccount.updatedAt, fixedNow.toUtc());
    verify(() => transactionRepository.softDelete(transaction.id)).called(1);
    expect(result.profileEvents, isEmpty);
  });

  test('reduces balance when deleting an income transaction', () async {
    final TransactionEntity transaction = TransactionEntity(
      id: 'tx-2',
      accountId: 'acc-1',
      categoryId: null,
      amount: 125,
      date: DateTime.utc(2024, 2, 10),
      note: 'Salary bonus',
      type: TransactionType.income.storageValue,
      createdAt: DateTime.utc(2024, 2, 10),
      updatedAt: DateTime.utc(2024, 2, 10),
    );
    final AccountEntity existingAccount = account(balance: 1125);

    when(
      () => transactionRepository.findById(transaction.id),
    ).thenAnswer((_) async => transaction);
    when(
      () => accountRepository.findById(transaction.accountId),
    ).thenAnswer((_) async => existingAccount);
    when(() => accountRepository.upsert(any())).thenAnswer((_) async {});
    when(
      () => transactionRepository.softDelete(transaction.id),
    ).thenAnswer((_) async {});

    final TransactionCommandResult<void> result = await useCase(transaction.id);

    final AccountEntity updatedAccount =
        verify(() => accountRepository.upsert(captureAny())).captured.single
            as AccountEntity;
    expect(updatedAccount.balance, closeTo(1000, 1e-9));
    expect(updatedAccount.updatedAt, fixedNow.toUtc());
    verify(() => transactionRepository.softDelete(transaction.id)).called(1);
    expect(result.profileEvents, isEmpty);
  });

  test('does nothing when transaction is not found', () async {
    when(
      () => transactionRepository.findById('missing'),
    ).thenAnswer((_) async => null);

    final TransactionCommandResult<void> result = await useCase('missing');

    verifyNever(() => accountRepository.upsert(any()));
    verifyNever(() => transactionRepository.softDelete(any()));
    expect(result.profileEvents, isEmpty);
  });
}
