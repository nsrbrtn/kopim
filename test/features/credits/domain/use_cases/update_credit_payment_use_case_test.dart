import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_group.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';
import 'package:kopim/features/credits/domain/use_cases/update_credit_payment_case.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class _MockCreditRepository extends Mock implements CreditRepository {}

class _MockTransactionRepository extends Mock
    implements TransactionRepository {}

class _FakeCreditPaymentGroupEntity extends Fake
    implements CreditPaymentGroupEntity {}

class _FakeCreditPaymentScheduleEntity extends Fake
    implements CreditPaymentScheduleEntity {}

class _FakeTransactionEntity extends Fake implements TransactionEntity {}

void main() {
  late _MockCreditRepository creditRepository;
  late _MockTransactionRepository transactionRepository;
  late UpdateCreditPaymentUseCase useCase;

  setUpAll(() {
    registerFallbackValue(_FakeCreditPaymentGroupEntity());
    registerFallbackValue(_FakeCreditPaymentScheduleEntity());
    registerFallbackValue(_FakeTransactionEntity());
  });

  setUp(() {
    creditRepository = _MockCreditRepository();
    transactionRepository = _MockTransactionRepository();
    useCase = UpdateCreditPaymentUseCase(
      creditRepository: creditRepository,
      transactionRepository: transactionRepository,
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
      () => creditRepository.updatePaymentGroup(any()),
    ).thenAnswer((_) async {});
    when(
      () => creditRepository.updateScheduleItem(any()),
    ).thenAnswer((_) async {});
    when(() => transactionRepository.upsert(any())).thenAnswer((_) async {});
    when(
      () => transactionRepository.softDelete(any()),
    ).thenAnswer((_) async {});
  });

  test(
    'атомарно обновляет payment group, schedule item и связанные транзакции',
    () async {
      final CreditPaymentGroupEntity group = _buildGroup(
        principal: 5000,
        interest: 500,
        fees: 100,
        total: 5600,
        note: 'Старый комментарий',
        scheduleItemId: 'schedule-1',
        idempotencyKey: 'credit-payment:key-1',
      );
      final CreditEntity credit = _buildCredit();
      final CreditPaymentScheduleEntity schedule = _buildSchedule(
        principalPaid: 5000,
        interestPaid: 500,
        status: CreditPaymentStatus.partiallyPaid,
        paidAt: nowStatic.subtract(const Duration(days: 1)),
      );
      final List<TransactionEntity> transactions = <TransactionEntity>[
        _buildTransaction(
          id: 'tx-principal',
          groupId: group.id,
          type: 'transfer',
          categoryId: credit.categoryId,
          transferAccountId: credit.accountId,
          amountMinor: 5000,
          idempotencyKey: 'credit-payment:key-1:principal',
        ),
        _buildTransaction(
          id: 'tx-interest',
          groupId: group.id,
          type: 'expense',
          categoryId: credit.interestCategoryId,
          amountMinor: 500,
          idempotencyKey: 'credit-payment:key-1:interest',
        ),
        _buildTransaction(
          id: 'tx-fees',
          groupId: group.id,
          type: 'expense',
          categoryId: credit.feesCategoryId,
          amountMinor: 100,
          idempotencyKey: 'credit-payment:key-1:fees',
        ),
      ];

      when(
        () => creditRepository.findPaymentGroupById(group.id),
      ).thenAnswer((_) async => group);
      when(
        () => creditRepository.getCredits(),
      ).thenAnswer((_) async => <CreditEntity>[credit]);
      when(
        () => transactionRepository.findByGroupId(group.id),
      ).thenAnswer((_) async => transactions);
      when(
        () => creditRepository.getSchedule(group.creditId),
      ).thenAnswer((_) async => <CreditPaymentScheduleEntity>[schedule]);
      when(
        () => creditRepository.getPaymentGroups(group.creditId),
      ).thenAnswer((_) async => <CreditPaymentGroupEntity>[group]);

      await useCase.call(
        groupId: group.id,
        principalPaid: _money(10000),
        interestPaid: _money(1000),
        feesPaid: _money(200),
        totalOutflow: _money(11200),
        note: 'Обновленный платеж',
      );

      final CreditPaymentGroupEntity updatedGroup =
          verify(
                () => creditRepository.updatePaymentGroup(captureAny()),
              ).captured.single
              as CreditPaymentGroupEntity;
      expect(updatedGroup.principalPaid.minor, BigInt.from(10000));
      expect(updatedGroup.interestPaid.minor, BigInt.from(1000));
      expect(updatedGroup.feesPaid.minor, BigInt.from(200));
      expect(updatedGroup.totalOutflow.minor, BigInt.from(11200));
      expect(updatedGroup.note, 'Обновленный платеж');

      final CreditPaymentScheduleEntity updatedSchedule =
          verify(
                () => creditRepository.updateScheduleItem(captureAny()),
              ).captured.single
              as CreditPaymentScheduleEntity;
      expect(updatedSchedule.principalPaid.minor, BigInt.from(10000));
      expect(updatedSchedule.interestPaid.minor, BigInt.from(1000));
      expect(updatedSchedule.status, CreditPaymentStatus.paid);
      expect(updatedSchedule.paidAt, group.paidAt);

      final List<TransactionEntity> updatedTransactions = verify(
        () => transactionRepository.upsert(captureAny()),
      ).captured.cast<TransactionEntity>();
      expect(updatedTransactions, hasLength(3));
      expect(
        updatedTransactions
            .where((TransactionEntity tx) => tx.id == 'tx-principal')
            .single
            .amountMinor,
        BigInt.from(10000),
      );
      expect(
        updatedTransactions
            .where((TransactionEntity tx) => tx.id == 'tx-interest')
            .single
            .amountMinor,
        BigInt.from(1000),
      );
      expect(
        updatedTransactions
            .where((TransactionEntity tx) => tx.id == 'tx-fees')
            .single
            .amountMinor,
        BigInt.from(200),
      );
      expect(
        updatedTransactions.every(
          (TransactionEntity tx) => tx.note == 'Обновленный платеж',
        ),
        isTrue,
      );
    },
  );

  test('удаляет component-транзакцию, если сумма стала нулевой', () async {
    final CreditPaymentGroupEntity group = _buildGroup(
      principal: 7000,
      interest: 700,
      fees: 300,
      total: 8000,
      note: null,
      scheduleItemId: 'schedule-1',
      idempotencyKey: 'credit-payment:key-2',
    );
    final CreditEntity credit = _buildCredit();
    final CreditPaymentScheduleEntity schedule = _buildSchedule(
      principalPaid: 7000,
      interestPaid: 700,
      status: CreditPaymentStatus.partiallyPaid,
      paidAt: nowStatic,
    );
    final TransactionEntity feesTx = _buildTransaction(
      id: 'tx-fees',
      groupId: group.id,
      type: 'expense',
      categoryId: credit.feesCategoryId,
      amountMinor: 300,
      idempotencyKey: 'credit-payment:key-2:fees',
    );

    when(
      () => creditRepository.findPaymentGroupById(group.id),
    ).thenAnswer((_) async => group);
    when(
      () => creditRepository.getCredits(),
    ).thenAnswer((_) async => <CreditEntity>[credit]);
    when(() => transactionRepository.findByGroupId(group.id)).thenAnswer(
      (_) async => <TransactionEntity>[
        _buildTransaction(
          id: 'tx-principal',
          groupId: group.id,
          type: 'transfer',
          categoryId: credit.categoryId,
          transferAccountId: credit.accountId,
          amountMinor: 7000,
          idempotencyKey: 'credit-payment:key-2:principal',
        ),
        _buildTransaction(
          id: 'tx-interest',
          groupId: group.id,
          type: 'expense',
          categoryId: credit.interestCategoryId,
          amountMinor: 700,
          idempotencyKey: 'credit-payment:key-2:interest',
        ),
        feesTx,
      ],
    );
    when(
      () => creditRepository.getSchedule(group.creditId),
    ).thenAnswer((_) async => <CreditPaymentScheduleEntity>[schedule]);
    when(
      () => creditRepository.getPaymentGroups(group.creditId),
    ).thenAnswer((_) async => <CreditPaymentGroupEntity>[group]);

    await useCase.call(
      groupId: group.id,
      principalPaid: _money(7000),
      interestPaid: _money(700),
      feesPaid: _money(0),
      totalOutflow: _money(7700),
      note: null,
    );

    verify(() => transactionRepository.softDelete(feesTx.id)).called(1);
    final List<TransactionEntity> updatedTransactions = verify(
      () => transactionRepository.upsert(captureAny()),
    ).captured.cast<TransactionEntity>();
    expect(updatedTransactions, hasLength(2));
  });

  test('падает, если payment group не найдена', () async {
    when(
      () => creditRepository.findPaymentGroupById('missing'),
    ).thenAnswer((_) async => null);

    await expectLater(
      () => useCase.call(
        groupId: 'missing',
        principalPaid: _money(1000),
        interestPaid: _money(100),
        feesPaid: _money(0),
        totalOutflow: _money(1100),
      ),
      throwsA(isA<StateError>()),
    );

    verifyNever(() => creditRepository.updatePaymentGroup(any()));
    verifyNever(() => transactionRepository.upsert(any()));
  });
}

CreditEntity _buildCredit() {
  return CreditEntity(
    id: 'credit-1',
    accountId: 'credit-account',
    categoryId: 'credit-category',
    interestCategoryId: 'interest-category',
    feesCategoryId: 'fees-category',
    interestRate: 12,
    termMonths: 12,
    startDate: nowStatic,
    paymentDay: 15,
    createdAt: nowStatic,
    updatedAt: nowStatic,
    totalAmountMinor: BigInt.from(11000),
    totalAmountScale: 2,
  );
}

CreditPaymentGroupEntity _buildGroup({
  required int principal,
  required int interest,
  required int fees,
  required int total,
  required String? note,
  required String? scheduleItemId,
  required String? idempotencyKey,
}) {
  return CreditPaymentGroupEntity(
    id: 'group-1',
    creditId: 'credit-1',
    sourceAccountId: 'source-1',
    scheduleItemId: scheduleItemId,
    paidAt: nowStatic,
    totalOutflow: _money(total),
    principalPaid: _money(principal),
    interestPaid: _money(interest),
    feesPaid: _money(fees),
    note: note,
    idempotencyKey: idempotencyKey,
  );
}

CreditPaymentScheduleEntity _buildSchedule({
  required int principalPaid,
  required int interestPaid,
  required CreditPaymentStatus status,
  required DateTime? paidAt,
}) {
  return CreditPaymentScheduleEntity(
    id: 'schedule-1',
    creditId: 'credit-1',
    periodKey: '2026-03',
    dueDate: nowStatic,
    status: status,
    principalAmount: _money(10000),
    interestAmount: _money(1000),
    totalAmount: _money(11000),
    principalPaid: _money(principalPaid),
    interestPaid: _money(interestPaid),
    paidAt: paidAt,
  );
}

TransactionEntity _buildTransaction({
  required String id,
  required String groupId,
  required String type,
  required int amountMinor,
  String? categoryId,
  String? transferAccountId,
  String? idempotencyKey,
}) {
  return TransactionEntity(
    id: id,
    accountId: 'source-1',
    transferAccountId: transferAccountId,
    categoryId: categoryId,
    groupId: groupId,
    idempotencyKey: idempotencyKey,
    amountMinor: BigInt.from(amountMinor),
    amountScale: 2,
    date: nowStatic,
    note: null,
    type: type,
    createdAt: nowStatic,
    updatedAt: nowStatic,
  );
}

Money _money(int minor) {
  return Money.fromMinor(BigInt.from(minor), currency: 'RUB', scale: 2);
}

final DateTime nowStatic = DateTime.utc(2026, 3, 7, 12);
