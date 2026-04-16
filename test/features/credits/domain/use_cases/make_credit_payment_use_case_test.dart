import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_group.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';
import 'package:kopim/features/credits/domain/use_cases/make_credit_payment_use_case.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class _MockCreditRepository extends Mock implements CreditRepository {}

class _MockTransactionRepository extends Mock
    implements TransactionRepository {}

class _MockAccountRepository extends Mock implements AccountRepository {}

class _MockCategoryRepository extends Mock implements CategoryRepository {}

class _FakeCreditPaymentGroupEntity extends Fake
    implements CreditPaymentGroupEntity {}

class _FakeTransactionEntity extends Fake implements TransactionEntity {}

void main() {
  late _MockCreditRepository creditRepository;
  late _MockTransactionRepository transactionRepository;
  late _MockAccountRepository accountRepository;
  late _MockCategoryRepository categoryRepository;
  late MakeCreditPaymentUseCase useCase;

  setUpAll(() {
    registerFallbackValue(_FakeCreditPaymentGroupEntity());
    registerFallbackValue(_FakeTransactionEntity());
  });

  setUp(() {
    creditRepository = _MockCreditRepository();
    transactionRepository = _MockTransactionRepository();
    accountRepository = _MockAccountRepository();
    categoryRepository = _MockCategoryRepository();
    useCase = MakeCreditPaymentUseCase(
      creditRepository: creditRepository,
      transactionRepository: transactionRepository,
      accountRepository: accountRepository,
      categoryRepository: categoryRepository,
      uuid: const Uuid(),
    );

    when(() => transactionRepository.runInTransaction<void>(any())).thenAnswer((
      Invocation invocation,
    ) {
      final Future<void> Function() action =
          invocation.positionalArguments.first as Future<void> Function();
      return action();
    });
    when(
      () => categoryRepository.findById(any()),
    ).thenAnswer((_) async => null);
    when(
      () => creditRepository.addPaymentGroup(any()),
    ).thenAnswer((_) async {});
    when(
      () => creditRepository.addPaymentGroupIfAbsent(any()),
    ).thenAnswer((_) async => true);
  });

  Future<void> arrangeValidPaymentContext({
    required DateTime now,
    String creditId = 'credit-1',
    String sourceAccountId = 'source-1',
    String creditAccountId = 'credit-account',
  }) async {
    final CreditEntity credit = CreditEntity(
      id: creditId,
      accountId: creditAccountId,
      categoryId: 'category-1',
      interestRate: 10,
      termMonths: 12,
      startDate: now,
      paymentDay: 15,
      createdAt: now,
      updatedAt: now,
      totalAmountMinor: BigInt.from(200000),
      totalAmountScale: 2,
    );

    when(
      () => creditRepository.getCredits(),
    ).thenAnswer((_) async => <CreditEntity>[credit]);
    when(
      () => accountRepository.findById(sourceAccountId),
    ).thenAnswer((_) async => _buildAccount(id: sourceAccountId));
    when(
      () => accountRepository.findById(creditAccountId),
    ).thenAnswer((_) async => _buildAccount(id: creditAccountId));
    when(
      () => creditRepository.findPaymentGroupByIdempotencyKey(
        creditId: creditId,
        idempotencyKey: any(named: 'idempotencyKey'),
      ),
    ).thenAnswer((_) async => null);
    when(() => transactionRepository.upsert(any())).thenAnswer((_) async {});
  }

  test('падает, если totalOutflow не равен сумме компонентов', () async {
    await expectLater(
      () => useCase.call(
        creditId: 'credit-1',
        sourceAccountId: 'source-1',
        paidAt: DateTime(2026, 3, 1),
        principalPaid: Money.fromMinor(
          BigInt.from(10000),
          currency: 'RUB',
          scale: 2,
        ),
        interestPaid: Money.fromMinor(
          BigInt.from(1000),
          currency: 'RUB',
          scale: 2,
        ),
        feesPaid: Money.fromMinor(BigInt.from(500), currency: 'RUB', scale: 2),
        totalOutflow: Money.fromMinor(
          BigInt.from(12000),
          currency: 'RUB',
          scale: 2,
        ),
      ),
      throwsA(isA<ArgumentError>()),
    );

    verifyNever(() => transactionRepository.runInTransaction<void>(any()));
  });

  test('падает, если totalOutflow <= 0', () async {
    await expectLater(
      () => useCase.call(
        creditId: 'credit-1',
        sourceAccountId: 'source-1',
        paidAt: DateTime(2026, 3, 1),
        principalPaid: Money.fromMinor(BigInt.zero, currency: 'RUB', scale: 2),
        interestPaid: Money.fromMinor(BigInt.zero, currency: 'RUB', scale: 2),
        feesPaid: Money.fromMinor(BigInt.zero, currency: 'RUB', scale: 2),
        totalOutflow: Money.fromMinor(BigInt.zero, currency: 'RUB', scale: 2),
      ),
      throwsA(isA<ArgumentError>()),
    );

    verifyNever(() => transactionRepository.runInTransaction<void>(any()));
  });

  test('падает, если валюта компонента не совпадает с totalOutflow', () async {
    await expectLater(
      () => useCase.call(
        creditId: 'credit-1',
        sourceAccountId: 'source-1',
        paidAt: DateTime(2026, 3, 1),
        principalPaid: Money.fromMinor(
          BigInt.from(10000),
          currency: 'USD',
          scale: 2,
        ),
        interestPaid: Money.fromMinor(
          BigInt.from(1000),
          currency: 'RUB',
          scale: 2,
        ),
        feesPaid: Money.fromMinor(BigInt.from(500), currency: 'RUB', scale: 2),
        totalOutflow: Money.fromMinor(
          BigInt.from(11500),
          currency: 'RUB',
          scale: 2,
        ),
      ),
      throwsA(isA<ArgumentError>()),
    );

    verifyNever(() => transactionRepository.runInTransaction<void>(any()));
  });

  test('падает, если для principal transfer не найден счет кредита', () async {
    final DateTime now = DateTime(2026, 3, 1);
    final CreditEntity credit = CreditEntity(
      id: 'credit-1',
      accountId: 'credit-account',
      categoryId: 'category-1',
      interestRate: 10,
      termMonths: 12,
      startDate: now,
      paymentDay: 15,
      createdAt: now,
      updatedAt: now,
      totalAmountMinor: BigInt.from(200000),
      totalAmountScale: 2,
    );

    when(
      () => creditRepository.getCredits(),
    ).thenAnswer((_) async => <CreditEntity>[credit]);
    when(
      () => accountRepository.findById('source-1'),
    ).thenAnswer((_) async => _buildAccount(id: 'source-1'));
    when(
      () => accountRepository.findById('credit-account'),
    ).thenAnswer((_) async => null);

    await expectLater(
      () => useCase.call(
        creditId: 'credit-1',
        sourceAccountId: 'source-1',
        paidAt: now,
        principalPaid: Money.fromMinor(
          BigInt.from(10000),
          currency: 'RUB',
          scale: 2,
        ),
        interestPaid: Money.fromMinor(BigInt.zero, currency: 'RUB', scale: 2),
        feesPaid: Money.fromMinor(BigInt.zero, currency: 'RUB', scale: 2),
        totalOutflow: Money.fromMinor(
          BigInt.from(10000),
          currency: 'RUB',
          scale: 2,
        ),
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('повторный вызов с тем же idempotencyKey не создает дублей', () async {
    final DateTime now = DateTime(2026, 3, 1);
    final CreditEntity credit = CreditEntity(
      id: 'credit-1',
      accountId: 'credit-account',
      categoryId: 'category-1',
      interestRate: 10,
      termMonths: 12,
      startDate: now,
      paymentDay: 15,
      createdAt: now,
      updatedAt: now,
      totalAmountMinor: BigInt.from(200000),
      totalAmountScale: 2,
    );
    final Map<String, CreditPaymentGroupEntity> paymentGroupsByKey =
        <String, CreditPaymentGroupEntity>{};

    when(
      () => creditRepository.getCredits(),
    ).thenAnswer((_) async => <CreditEntity>[credit]);
    when(
      () => accountRepository.findById('source-1'),
    ).thenAnswer((_) async => _buildAccount(id: 'source-1'));
    when(
      () => accountRepository.findById('credit-account'),
    ).thenAnswer((_) async => _buildAccount(id: 'credit-account'));
    when(
      () => creditRepository.findPaymentGroupByIdempotencyKey(
        creditId: 'credit-1',
        idempotencyKey: any(named: 'idempotencyKey'),
      ),
    ).thenAnswer((Invocation invocation) async {
      final String key = invocation.namedArguments[#idempotencyKey]! as String;
      return paymentGroupsByKey[key];
    });
    when(() => transactionRepository.upsert(any())).thenAnswer((_) async {});
    when(() => creditRepository.addPaymentGroupIfAbsent(any())).thenAnswer((
      Invocation invocation,
    ) async {
      final CreditPaymentGroupEntity group =
          invocation.positionalArguments.first as CreditPaymentGroupEntity;
      if (group.idempotencyKey != null) {
        paymentGroupsByKey[group.idempotencyKey!] = group;
      }
      return true;
    });

    Future<void> pay() {
      return useCase.call(
        creditId: 'credit-1',
        sourceAccountId: 'source-1',
        paidAt: now,
        principalPaid: Money.fromMinor(
          BigInt.from(10000),
          currency: 'RUB',
          scale: 2,
        ),
        interestPaid: Money.fromMinor(
          BigInt.from(1000),
          currency: 'RUB',
          scale: 2,
        ),
        feesPaid: Money.fromMinor(BigInt.from(500), currency: 'RUB', scale: 2),
        totalOutflow: Money.fromMinor(
          BigInt.from(11500),
          currency: 'RUB',
          scale: 2,
        ),
        idempotencyKey: 'manual:credit-1:2026-03-01',
      );
    }

    await pay();
    await pay();

    final List<CreditPaymentGroupEntity> createdGroups = verify(
      () => creditRepository.addPaymentGroupIfAbsent(captureAny()),
    ).captured.cast<CreditPaymentGroupEntity>();
    expect(createdGroups, hasLength(1));
    expect(createdGroups.single.idempotencyKey, 'manual:credit-1:2026-03-01');

    final List<TransactionEntity> createdTransactions = verify(
      () => transactionRepository.upsert(captureAny()),
    ).captured.cast<TransactionEntity>();
    expect(createdTransactions, hasLength(3));
    expect(
      createdTransactions.map((TransactionEntity tx) => tx.idempotencyKey),
      containsAll(<String>[
        'manual:credit-1:2026-03-01:principal',
        'manual:credit-1:2026-03-01:interest',
        'manual:credit-1:2026-03-01:fees',
      ]),
    );
  });

  test(
    'при гонке insertOrIgnore=false завершает как идемпотентный успех',
    () async {
      final DateTime now = DateTime(2026, 3, 1);
      final CreditEntity credit = CreditEntity(
        id: 'credit-1',
        accountId: 'credit-account',
        categoryId: 'category-1',
        interestRate: 10,
        termMonths: 12,
        startDate: now,
        paymentDay: 15,
        createdAt: now,
        updatedAt: now,
        totalAmountMinor: BigInt.from(200000),
        totalAmountScale: 2,
      );

      when(
        () => creditRepository.getCredits(),
      ).thenAnswer((_) async => <CreditEntity>[credit]);
      when(
        () => accountRepository.findById('source-1'),
      ).thenAnswer((_) async => _buildAccount(id: 'source-1'));
      when(
        () => accountRepository.findById('credit-account'),
      ).thenAnswer((_) async => _buildAccount(id: 'credit-account'));
      when(
        () => creditRepository.findPaymentGroupByIdempotencyKey(
          creditId: 'credit-1',
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenAnswer((_) async => null);
      when(
        () => creditRepository.addPaymentGroupIfAbsent(any()),
      ).thenAnswer((_) async => false);

      await useCase.call(
        creditId: 'credit-1',
        sourceAccountId: 'source-1',
        paidAt: now,
        principalPaid: Money.fromMinor(
          BigInt.from(10000),
          currency: 'RUB',
          scale: 2,
        ),
        interestPaid: Money.fromMinor(
          BigInt.from(1000),
          currency: 'RUB',
          scale: 2,
        ),
        feesPaid: Money.fromMinor(BigInt.from(500), currency: 'RUB', scale: 2),
        totalOutflow: Money.fromMinor(
          BigInt.from(11500),
          currency: 'RUB',
          scale: 2,
        ),
        idempotencyKey: 'manual:credit-1:race',
      );

      verifyNever(() => transactionRepository.upsert(any()));
    },
  );

  test(
    'создает транзакции только для ненулевых компонент и сохраняет scale',
    () async {
      final DateTime now = DateTime(2026, 3, 1);
      await arrangeValidPaymentContext(now: now);

      await useCase.call(
        creditId: 'credit-1',
        sourceAccountId: 'source-1',
        paidAt: now,
        principalPaid: Money.fromMinor(
          BigInt.from(12345),
          currency: 'RUB',
          scale: 3,
        ),
        interestPaid: Money.fromMinor(BigInt.zero, currency: 'RUB', scale: 3),
        feesPaid: Money.fromMinor(BigInt.from(55), currency: 'RUB', scale: 3),
        totalOutflow: Money.fromMinor(
          BigInt.from(12400),
          currency: 'RUB',
          scale: 3,
        ),
        idempotencyKey: 'manual:credit-1:scale3',
      );

      final List<TransactionEntity> createdTransactions = verify(
        () => transactionRepository.upsert(captureAny()),
      ).captured.cast<TransactionEntity>();
      expect(createdTransactions, hasLength(2));
      expect(
        createdTransactions.map((TransactionEntity tx) => tx.idempotencyKey),
        containsAll(<String>[
          'manual:credit-1:scale3:principal',
          'manual:credit-1:scale3:fees',
        ]),
      );
      expect(
        createdTransactions.every(
          (TransactionEntity tx) => tx.amountScale == 3,
        ),
        isTrue,
      );
      expect(
        createdTransactions
            .where(
              (TransactionEntity tx) =>
                  tx.idempotencyKey == 'manual:credit-1:scale3:principal',
            )
            .single
            .amountMinor,
        BigInt.from(12345),
      );
      expect(
        createdTransactions
            .where(
              (TransactionEntity tx) =>
                  tx.idempotencyKey == 'manual:credit-1:scale3:fees',
            )
            .single
            .amountMinor,
        BigInt.from(55),
      );
    },
  );
}

AccountEntity _buildAccount({required String id}) {
  final DateTime now = DateTime(2026, 3, 1);
  return AccountEntity(
    id: id,
    name: 'Test',
    balanceMinor: BigInt.zero,
    openingBalanceMinor: BigInt.zero,
    currency: 'RUB',
    currencyScale: 2,
    type: 'cash',
    createdAt: now,
    updatedAt: now,
  );
}
