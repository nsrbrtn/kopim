import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/accounts/domain/use_cases/delete_account_use_case.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';
import 'package:kopim/features/categories/domain/use_cases/delete_category_use_case.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_group.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';
import 'package:kopim/features/credits/domain/use_cases/delete_credit_use_case.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/upcoming_payments_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockCreditRepository extends Mock implements CreditRepository {}

class _MockTransactionRepository extends Mock
    implements TransactionRepository {}

class _MockAccountRepository extends Mock implements AccountRepository {}

class _MockCategoryRepository extends Mock implements CategoryRepository {}

class _MockUpcomingPaymentsRepository extends Mock
    implements UpcomingPaymentsRepository {}

void main() {
  late _MockCreditRepository creditRepository;
  late _MockTransactionRepository transactionRepository;
  late _MockAccountRepository accountRepository;
  late _MockCategoryRepository categoryRepository;
  late _MockUpcomingPaymentsRepository upcomingPaymentsRepository;
  late DeleteCreditUseCase useCase;

  setUp(() {
    creditRepository = _MockCreditRepository();
    transactionRepository = _MockTransactionRepository();
    accountRepository = _MockAccountRepository();
    categoryRepository = _MockCategoryRepository();
    upcomingPaymentsRepository = _MockUpcomingPaymentsRepository();
    useCase = DeleteCreditUseCase(
      creditRepository,
      transactionRepository,
      DeleteAccountUseCase(accountRepository),
      DeleteCategoryUseCase(categoryRepository),
      upcomingPaymentsRepository,
    );

    when(() => creditRepository.deleteCredit(any())).thenAnswer((_) async {});
    when(
      () => transactionRepository.softDelete(any()),
    ).thenAnswer((_) async {});
    when(() => accountRepository.softDelete(any())).thenAnswer((_) async {});
    when(() => categoryRepository.softDelete(any())).thenAnswer((_) async {});
    when(
      () => upcomingPaymentsRepository.getByCategoryId(any()),
    ).thenAnswer((_) async => null);
    when(
      () => upcomingPaymentsRepository.delete(any()),
    ).thenAnswer((_) async {});
  });

  test(
    'перед удалением кредита soft-delete связанные payment transactions и не трогает уже deleted записи',
    () async {
      final CreditEntity credit = _buildCredit();
      final List<CreditPaymentGroupEntity> groups = <CreditPaymentGroupEntity>[
        _buildGroup(id: 'group-1', creditId: credit.id),
        _buildGroup(id: 'group-2', creditId: credit.id),
      ];
      when(
        () => creditRepository.getPaymentGroups(credit.id),
      ).thenAnswer((_) async => groups);
      when(() => transactionRepository.findByGroupId('group-1')).thenAnswer(
        (_) async => <TransactionEntity>[
          _buildTransaction(id: 'tx-1', groupId: 'group-1'),
          _buildTransaction(id: 'tx-2', groupId: 'group-1', isDeleted: true),
        ],
      );
      when(() => transactionRepository.findByGroupId('group-2')).thenAnswer(
        (_) async => <TransactionEntity>[
          _buildTransaction(id: 'tx-3', groupId: 'group-2'),
        ],
      );
      when(
        () => upcomingPaymentsRepository.getByCategoryId('category-main'),
      ).thenAnswer((_) async => null);
      when(
        () => upcomingPaymentsRepository.getByCategoryId('category-interest'),
      ).thenAnswer((_) async => _buildUpcomingPayment(id: 'upcoming-1'));
      when(
        () => upcomingPaymentsRepository.getByCategoryId('category-fees'),
      ).thenAnswer((_) async => null);

      await useCase.call(credit);

      verifyInOrder(<dynamic Function()>[
        () => creditRepository.getPaymentGroups(credit.id),
        () => transactionRepository.findByGroupId('group-1'),
        () => transactionRepository.softDelete('tx-1'),
        () => transactionRepository.findByGroupId('group-2'),
        () => transactionRepository.softDelete('tx-3'),
        () => creditRepository.deleteCredit(credit.id),
        () => accountRepository.softDelete(credit.accountId),
      ]);
      verifyNever(() => transactionRepository.softDelete('tx-2'));
      verify(() => upcomingPaymentsRepository.delete('upcoming-1')).called(1);
      verify(() => categoryRepository.softDelete('category-main')).called(1);
      verify(
        () => categoryRepository.softDelete('category-interest'),
      ).called(1);
      verify(() => categoryRepository.softDelete('category-fees')).called(1);
    },
  );

  test(
    'если у кредита нет payment groups, удаление продолжает обычный flow',
    () async {
      final CreditEntity credit = _buildCredit(
        categoryId: null,
        interestCategoryId: null,
        feesCategoryId: null,
      );
      when(
        () => creditRepository.getPaymentGroups(credit.id),
      ).thenAnswer((_) async => const <CreditPaymentGroupEntity>[]);

      await useCase.call(credit);

      verify(() => creditRepository.getPaymentGroups(credit.id)).called(1);
      verifyNever(() => transactionRepository.findByGroupId(any()));
      verifyNever(() => transactionRepository.softDelete(any()));
      verify(() => creditRepository.deleteCredit(credit.id)).called(1);
      verify(() => accountRepository.softDelete(credit.accountId)).called(1);
      verifyNever(() => categoryRepository.softDelete(any()));
    },
  );
}

CreditEntity _buildCredit({
  String? categoryId = 'category-main',
  String? interestCategoryId = 'category-interest',
  String? feesCategoryId = 'category-fees',
}) {
  final DateTime now = DateTime.utc(2026, 6, 13);
  return CreditEntity(
    id: 'credit-1',
    accountId: 'credit-account-1',
    categoryId: categoryId,
    interestCategoryId: interestCategoryId,
    feesCategoryId: feesCategoryId,
    totalAmountMinor: BigInt.from(100000),
    totalAmountScale: 2,
    interestRate: 12.5,
    termMonths: 12,
    startDate: now,
    firstPaymentDate: now,
    paymentDay: 10,
    createdAt: now,
    updatedAt: now,
  );
}

CreditPaymentGroupEntity _buildGroup({
  required String id,
  required String creditId,
}) {
  final DateTime now = DateTime.utc(2026, 6, 13);
  return CreditPaymentGroupEntity(
    id: id,
    creditId: creditId,
    sourceAccountId: 'cash-1',
    paidAt: now,
    totalOutflow: _money(1200),
    principalPaid: _money(1000),
    interestPaid: _money(200),
    feesPaid: _money(0),
    createdAt: now,
    updatedAt: now,
  );
}

TransactionEntity _buildTransaction({
  required String id,
  required String groupId,
  bool isDeleted = false,
}) {
  final DateTime now = DateTime.utc(2026, 6, 13);
  return TransactionEntity(
    id: id,
    accountId: 'cash-1',
    groupId: groupId,
    amountMinor: BigInt.from(1000),
    amountScale: 2,
    date: now,
    type: 'expense',
    createdAt: now,
    updatedAt: now,
    isDeleted: isDeleted,
  );
}

UpcomingPayment _buildUpcomingPayment({required String id}) {
  return UpcomingPayment(
    id: id,
    title: 'Interest reminder',
    accountId: 'cash-1',
    categoryId: 'category-interest',
    amountMinor: BigInt.from(500),
    amountScale: 2,
    dayOfMonth: 10,
    notifyDaysBefore: 1,
    notifyTimeHhmm: '09:00',
    autoPost: false,
    isActive: true,
    createdAtMs: 1,
    updatedAtMs: 1,
  );
}

Money _money(int minor) =>
    Money.fromMinor(BigInt.from(minor), currency: 'RUB', scale: 2);
