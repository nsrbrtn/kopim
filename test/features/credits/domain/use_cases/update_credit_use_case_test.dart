import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';
import 'package:kopim/features/categories/domain/use_cases/save_category_use_case.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';
import 'package:kopim/features/credits/domain/use_cases/update_credit_use_case.dart';
import 'package:mocktail/mocktail.dart';

class _MockCreditRepository extends Mock implements CreditRepository {}

class _MockAccountRepository extends Mock implements AccountRepository {}

class _MockCategoryRepository extends Mock implements CategoryRepository {}

class _MockSaveCategoryUseCase extends Mock implements SaveCategoryUseCase {}

class _FakeCreditPaymentScheduleEntity extends Fake
    implements CreditPaymentScheduleEntity {}

class _FakeCreditEntity extends Fake implements CreditEntity {}

class _FakeAccountEntity extends Fake implements AccountEntity {}

void main() {
  late _MockCreditRepository creditRepository;
  late _MockAccountRepository accountRepository;
  late _MockCategoryRepository categoryRepository;
  late _MockSaveCategoryUseCase saveCategoryUseCase;
  late UpdateCreditUseCase useCase;

  setUpAll(() {
    registerFallbackValue(_FakeCreditPaymentScheduleEntity());
    registerFallbackValue(_FakeCreditEntity());
    registerFallbackValue(_FakeAccountEntity());
  });

  setUp(() {
    creditRepository = _MockCreditRepository();
    accountRepository = _MockAccountRepository();
    categoryRepository = _MockCategoryRepository();
    saveCategoryUseCase = _MockSaveCategoryUseCase();
    useCase = UpdateCreditUseCase(
      creditRepository: creditRepository,
      accountRepository: accountRepository,
      categoryRepository: categoryRepository,
      saveCategoryUseCase: saveCategoryUseCase,
      clock: () => DateTime.utc(2026, 3, 1, 10),
      idGenerator: () => 'new-id',
    );

    when(() => creditRepository.updateCredit(any())).thenAnswer((_) async {});
    when(
      () => creditRepository.updateScheduleItem(any()),
    ).thenAnswer((_) async {});
    when(() => creditRepository.addSchedule(any())).thenAnswer((_) async {});
    when(() => accountRepository.upsert(any())).thenAnswer((_) async {});
  });

  test(
    'пересчитывает schedule и помечает лишние planned периоды как skipped',
    () async {
      final DateTime now = DateTime.utc(2026, 1, 1);
      final CreditEntity credit = CreditEntity(
        id: 'credit-1',
        accountId: 'account-1',
        totalAmountMinor: BigInt.from(120000),
        totalAmountScale: 2,
        interestRate: 12,
        termMonths: 3,
        startDate: now,
        firstPaymentDate: DateTime.utc(2026, 1, 15),
        paymentDay: 15,
        createdAt: now,
        updatedAt: now,
      );

      final AccountEntity account = AccountEntity(
        id: 'account-1',
        name: 'Credit account',
        balanceMinor: BigInt.zero,
        openingBalanceMinor: BigInt.zero,
        currency: 'RUB',
        currencyScale: 2,
        type: 'credit',
        createdAt: now,
        updatedAt: now,
      );

      final List<CreditPaymentScheduleEntity> existing =
          <CreditPaymentScheduleEntity>[
            _schedule(
              id: 's1',
              periodKey: '2026-01',
              dueDate: DateTime.utc(2026, 1, 15),
              principalMinor: 39000,
              interestMinor: 1000,
              status: CreditPaymentStatus.paid,
              principalPaidMinor: 39000,
              interestPaidMinor: 1000,
            ),
            _schedule(
              id: 's2',
              periodKey: '2026-02',
              dueDate: DateTime.utc(2026, 2, 15),
              principalMinor: 39500,
              interestMinor: 500,
            ),
            _schedule(
              id: 's3',
              periodKey: '2026-03',
              dueDate: DateTime.utc(2026, 3, 15),
              principalMinor: 40000,
              interestMinor: 0,
            ),
          ];

      when(
        () => accountRepository.findById('account-1'),
      ).thenAnswer((_) async => account);
      when(
        () => creditRepository.getSchedule('credit-1'),
      ).thenAnswer((_) async => existing);

      await useCase.call(
        credit: credit,
        name: 'Updated credit',
        totalAmount: _moneyAmount(100000),
        interestRate: 0,
        termMonths: 2,
        paymentDay: 15,
      );

      verify(() => creditRepository.updateCredit(any())).called(1);

      final List<CreditPaymentScheduleEntity> updatedItems = verify(
        () => creditRepository.updateScheduleItem(captureAny()),
      ).captured.cast<CreditPaymentScheduleEntity>();

      expect(updatedItems, hasLength(3));
      final CreditPaymentScheduleEntity january = updatedItems.firstWhere(
        (CreditPaymentScheduleEntity item) => item.periodKey == '2026-01',
      );
      final CreditPaymentScheduleEntity february = updatedItems.firstWhere(
        (CreditPaymentScheduleEntity item) => item.periodKey == '2026-02',
      );
      final CreditPaymentScheduleEntity march = updatedItems.firstWhere(
        (CreditPaymentScheduleEntity item) => item.periodKey == '2026-03',
      );

      expect(january.status, CreditPaymentStatus.partiallyPaid);
      expect(january.principalPaid.minor, BigInt.from(39000));
      expect(january.interestPaid.minor, BigInt.zero);

      expect(february.status, CreditPaymentStatus.planned);
      expect(february.totalAmount.minor, greaterThan(BigInt.zero));

      expect(march.status, CreditPaymentStatus.skipped);
      expect(march.paidAt, isNull);

      verifyNever(() => creditRepository.addSchedule(any()));
    },
  );

  test(
    'ставит paidAt при status=paid, если в старом period paidAt отсутствует',
    () async {
      final DateTime now = DateTime.utc(2026, 1, 1);
      final CreditEntity credit = CreditEntity(
        id: 'credit-1',
        accountId: 'account-1',
        totalAmountMinor: BigInt.from(120000),
        totalAmountScale: 2,
        interestRate: 12,
        termMonths: 1,
        startDate: now,
        firstPaymentDate: DateTime.utc(2026, 1, 15),
        paymentDay: 15,
        createdAt: now,
        updatedAt: now,
      );

      final AccountEntity account = AccountEntity(
        id: 'account-1',
        name: 'Credit account',
        balanceMinor: BigInt.zero,
        openingBalanceMinor: BigInt.zero,
        currency: 'RUB',
        currencyScale: 2,
        type: 'credit',
        createdAt: now,
        updatedAt: now,
      );

      final CreditPaymentScheduleEntity inconsistentPaid =
          CreditPaymentScheduleEntity(
            id: 's-paid',
            creditId: 'credit-1',
            periodKey: '2026-01',
            dueDate: DateTime.utc(2026, 1, 15),
            status: CreditPaymentStatus.paid,
            principalAmount: _money(120000),
            interestAmount: _money(0),
            totalAmount: _money(120000),
            principalPaid: _money(120000),
            interestPaid: _money(0),
            paidAt: null,
          );

      when(
        () => accountRepository.findById('account-1'),
      ).thenAnswer((_) async => account);
      when(() => creditRepository.getSchedule('credit-1')).thenAnswer(
        (_) async => <CreditPaymentScheduleEntity>[inconsistentPaid],
      );

      await useCase.call(
        credit: credit,
        name: 'Updated credit',
        totalAmount: _moneyAmount(120000),
        interestRate: 0,
        termMonths: 1,
        paymentDay: 15,
      );

      final List<CreditPaymentScheduleEntity> updatedItems = verify(
        () => creditRepository.updateScheduleItem(captureAny()),
      ).captured.cast<CreditPaymentScheduleEntity>();

      expect(updatedItems, hasLength(1));
      expect(updatedItems.single.status, CreditPaymentStatus.paid);
      expect(updatedItems.single.paidAt, DateTime.utc(2026, 3, 1, 10));
    },
  );
}

CreditPaymentScheduleEntity _schedule({
  required String id,
  required String periodKey,
  required DateTime dueDate,
  required int principalMinor,
  required int interestMinor,
  CreditPaymentStatus status = CreditPaymentStatus.planned,
  int principalPaidMinor = 0,
  int interestPaidMinor = 0,
}) {
  return CreditPaymentScheduleEntity(
    id: id,
    creditId: 'credit-1',
    periodKey: periodKey,
    dueDate: dueDate,
    status: status,
    principalAmount: _money(principalMinor),
    interestAmount: _money(interestMinor),
    totalAmount: _money(principalMinor + interestMinor),
    principalPaid: _money(principalPaidMinor),
    interestPaid: _money(interestPaidMinor),
    paidAt: status == CreditPaymentStatus.paid ? dueDate : null,
  );
}

Money _money(int minor) {
  return Money.fromMinor(BigInt.from(minor), currency: 'RUB', scale: 2);
}

MoneyAmount _moneyAmount(int minor) {
  return MoneyAmount(minor: BigInt.from(minor), scale: 2);
}
