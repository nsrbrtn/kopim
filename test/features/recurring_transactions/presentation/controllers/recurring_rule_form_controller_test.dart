import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/domain/use_cases/save_recurring_rule_use_case.dart';
import 'package:kopim/features/recurring_transactions/presentation/controllers/recurring_rule_form_controller.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/src/framework.dart';
import 'package:uuid/uuid.dart';

class _MockSaveRecurringRuleUseCase extends Mock
    implements SaveRecurringRuleUseCase {}

class _MockUuid extends Mock implements Uuid {}

RecurringRule _fallbackRule() {
  final DateTime now = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  return RecurringRule(
    id: 'id',
    title: 'title',
    accountId: 'account',
    amount: 10,
    currency: 'USD',
    startAt: now,
    timezone: 'UTC',
    rrule: 'FREQ=MONTHLY;BYMONTHDAY=1',
    notes: null,
    dayOfMonth: 1,
    applyAtLocalHour: 10,
    applyAtLocalMinute: 0,
    lastRunAt: null,
    nextDueLocalDate: now,
    isActive: true,
    autoPost: false,
    reminderMinutesBefore: null,
    shortMonthPolicy: RecurringRuleShortMonthPolicy.clipToLastDay,
    createdAt: now,
    updatedAt: now,
  );
}

AccountEntity _buildAccount() {
  final DateTime now = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  return AccountEntity(
    id: 'account-1',
    name: 'Main',
    balance: 1000,
    currency: 'EUR',
    type: 'bank',
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_fallbackRule());
  });

  late _MockSaveRecurringRuleUseCase mockUseCase;
  late _MockUuid mockUuid;
  late ProviderContainer container;

  setUp(() {
    mockUseCase = _MockSaveRecurringRuleUseCase();
    mockUuid = _MockUuid();
    when(() => mockUuid.v4()).thenReturn('uuid-1');
    container = ProviderContainer(
      overrides: <Override>[
        saveRecurringRuleUseCaseProvider.overrideWithValue(mockUseCase),
        uuidGeneratorProvider.overrideWithValue(mockUuid),
      ],
    );
    addTearDown(container.dispose);
  });

  test('submit sends recurring rule to use case and marks success', () async {
    when(() => mockUseCase.call(any())).thenAnswer((_) async {});

    final RecurringRuleFormController controller = container.read(
      recurringRuleFormControllerProvider.notifier,
    );
    final AccountEntity account = _buildAccount();
    controller.updateAccount(account);
    controller.updateTitle('  Зарплата ');
    controller.updateAmount('150');
    controller.updateType(TransactionType.income);
    controller.updateStartDate(DateTime(2024, 1, 15));
    controller.updateTime(hour: 10, minute: 30);
    controller.updateAutoPost(true);

    await controller.submit();

    final RecurringRule captured =
        verify(() => mockUseCase.call(captureAny())).captured.single
            as RecurringRule;

    expect(captured.id, 'uuid-1');
    expect(captured.title, 'Зарплата');
    expect(captured.accountId, account.id);
    expect(captured.currency, account.currency);
    expect(captured.amount, -150);
    expect(captured.autoPost, isTrue);
    expect(captured.dayOfMonth, 15);
    expect(captured.applyAtLocalHour, 10);
    expect(captured.applyAtLocalMinute, 30);
    expect(captured.rrule, 'FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=15');
    expect(captured.startAt, DateTime.utc(2024, 1, 15, 10, 30));
    expect(captured.nextDueLocalDate, DateTime(2024, 1, 15, 10, 30));
    expect(captured.createdAt.isUtc, isTrue);
    expect(captured.updatedAt.isUtc, isTrue);

    final RecurringRuleFormState state = container.read(
      recurringRuleFormControllerProvider,
    );
    expect(state.submissionSuccess, isTrue);
    expect(state.isSubmitting, isFalse);
    expect(state.generalErrorMessage, isNull);
  });

  test('submit validates fields before calling use case', () async {
    final RecurringRuleFormController controller = container.read(
      recurringRuleFormControllerProvider.notifier,
    );
    controller.updateTitle('  ');
    controller.updateAmount('abc');
    controller.updateAccount(null);

    await controller.submit();

    final RecurringRuleFormState state = container.read(
      recurringRuleFormControllerProvider,
    );
    expect(state.titleError, RecurringRuleTitleError.empty);
    expect(state.amountError, RecurringRuleAmountError.invalid);
    expect(state.accountError, RecurringRuleAccountError.missing);
    verifyNever(() => mockUseCase.call(any()));
  });

  test('submit surfaces error when use case throws', () async {
    when(() => mockUseCase.call(any())).thenAnswer((_) async {
      throw Exception('failed');
    });

    final RecurringRuleFormController controller = container.read(
      recurringRuleFormControllerProvider.notifier,
    );
    controller.updateAccount(_buildAccount());
    controller.updateTitle('Аренда');
    controller.updateAmount('500');

    await controller.submit();

    final RecurringRuleFormState state = container.read(
      recurringRuleFormControllerProvider,
    );
    expect(state.submissionSuccess, isFalse);
    expect(state.isSubmitting, isFalse);
    expect(state.generalErrorMessage, contains('failed'));
    verify(() => mockUseCase.call(any())).called(1);
  });
}
