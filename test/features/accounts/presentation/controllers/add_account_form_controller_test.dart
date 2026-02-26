import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/use_cases/add_account_use_case.dart';
import 'package:kopim/features/accounts/presentation/controllers/add_account_form_controller.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/use_cases/add_credit_card_use_case.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/src/framework.dart';
import 'package:uuid/uuid.dart';

class _MockAddAccountUseCase extends Mock implements AddAccountUseCase {}

class _MockAddCreditCardUseCase extends Mock implements AddCreditCardUseCase {}

class _MockUuid extends Mock implements Uuid {}

AccountEntity _fallbackAccount() {
  final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
    0,
    isUtc: true,
  );
  return AccountEntity(
    id: 'id',
    name: 'name',
    balanceMinor: BigInt.zero,
    currency: 'USD',
    currencyScale: 2,
    type: 'cash',
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

CreditCardEntity _fallbackCreditCard() {
  final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
    0,
    isUtc: true,
  );
  return CreditCardEntity(
    id: 'card',
    accountId: 'account',
    creditLimitMinor: BigInt.from(10000),
    creditLimitScale: 2,
    statementDay: 5,
    paymentDueDays: 10,
    interestRateAnnual: 20,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_fallbackAccount());
    registerFallbackValue(_fallbackCreditCard());
  });

  late _MockAddAccountUseCase mockUseCase;
  late _MockAddCreditCardUseCase mockAddCreditCardUseCase;
  late _MockUuid mockUuid;
  late ProviderContainer container;

  setUp(() {
    mockUseCase = _MockAddAccountUseCase();
    mockAddCreditCardUseCase = _MockAddCreditCardUseCase();
    mockUuid = _MockUuid();
    when(() => mockUuid.v4()).thenReturn('uuid-123');
    when(() => mockAddCreditCardUseCase.call(any())).thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: <Override>[
        addAccountUseCaseProvider.overrideWithValue(mockUseCase),
        addCreditCardUseCaseProvider.overrideWithValue(
          mockAddCreditCardUseCase,
        ),
        uuidGeneratorProvider.overrideWithValue(mockUuid),
      ],
    );
    addTearDown(container.dispose);
  });

  test('submit sends account data and resets form on success', () async {
    when(() => mockUseCase.call(any())).thenAnswer((_) async {});

    final AddAccountFormController controller = container.read(
      addAccountFormControllerProvider.notifier,
    );
    controller.updateName(' Savings ');
    controller.updateBalance('150.5');
    controller.updateCurrency('EUR');
    controller.updateType('bank');
    controller.updateIsPrimary(true);

    await controller.submit();

    final AccountEntity captured =
        verify(() => mockUseCase.call(captureAny())).captured.single
            as AccountEntity;

    expect(captured.id, 'uuid-123');
    expect(captured.name, 'Savings');
    expect(captured.balanceAmount.toDouble(), 150.5);
    expect(captured.currency, 'EUR');
    expect(captured.type, 'bank');
    expect(captured.createdAt, captured.updatedAt);
    expect(captured.createdAt.isUtc, isTrue);
    expect(captured.isPrimary, isTrue);

    final AddAccountFormState state = container.read(
      addAccountFormControllerProvider,
    );
    expect(state.submissionSuccess, isTrue);
    expect(state.isSaving, isFalse);
    expect(state.name, isEmpty);
    expect(state.balanceInput, isEmpty);
    expect(state.errorMessage, isNull);
    expect(state.isPrimary, isTrue);
  });

  test('submit surfaces error message when use case throws', () async {
    when(() => mockUseCase.call(any())).thenAnswer((_) async {
      throw Exception('failed');
    });

    final AddAccountFormController controller = container.read(
      addAccountFormControllerProvider.notifier,
    );
    controller.updateName('Wallet');
    controller.updateBalance('10');
    controller.updateType('cash');

    await controller.submit();

    final AddAccountFormState state = container.read(
      addAccountFormControllerProvider,
    );
    expect(state.submissionSuccess, isFalse);
    expect(state.isSaving, isFalse);
    expect(state.errorMessage, isNotNull);
    expect(state.errorMessage, contains('Exception'));
    verify(() => mockUseCase.call(any())).called(1);
  });

  test('submit validates input before calling use case', () async {
    final AddAccountFormController controller = container.read(
      addAccountFormControllerProvider.notifier,
    );
    controller.updateName('   ');
    controller.updateBalance('abc');

    await controller.submit();

    final AddAccountFormState state = container.read(
      addAccountFormControllerProvider,
    );
    expect(state.nameError, AddAccountFieldError.emptyName);
    expect(state.balanceError, AddAccountFieldError.invalidBalance);
    verifyNever(() => mockUseCase.call(any()));
  });

  test('submit сохраняет введенный начальный баланс для credit_card', () async {
    when(() => mockUseCase.call(any())).thenAnswer((_) async {});

    final AddAccountFormController controller = container.read(
      addAccountFormControllerProvider.notifier,
    );
    controller.updateName('Credit Card');
    controller.updateType('credit_card');
    controller.updateCurrency('RUB');
    controller.updateBalance('1234.56');
    controller.updateCreditLimit('50000');
    controller.updateStatementDay('5');
    controller.updatePaymentDueDays('10');
    controller.updateInterestRate('25');

    await controller.submit();

    final AccountEntity captured =
        verify(() => mockUseCase.call(captureAny())).captured.single
            as AccountEntity;

    expect(captured.type, 'credit_card');
    expect(captured.balanceAmount.toDouble(), 1234.56);
    expect(captured.openingBalanceAmount.toDouble(), 1234.56);
    verify(() => mockAddCreditCardUseCase.call(any())).called(1);
  });
}
