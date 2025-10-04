import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
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
    categoryId: 'category',
    amount: 10,
    currency: 'USD',
    startAt: now,
    timezone: 'Europe/Helsinki',
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

Category _buildCategory({String type = 'expense'}) {
  final DateTime now = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  return Category(
    id: 'category-1-$type',
    name: 'Category',
    type: type,
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

    final RecurringRuleFormControllerProvider provider =
        recurringRuleFormControllerProvider(initialRule: null);
    final RecurringRuleFormController controller = container.read(
      provider.notifier,
    );
    final AccountEntity account = _buildAccount();
    final Category category = _buildCategory(type: 'income');
    controller.updateAccount(account);
    controller.updateTitle('  Зарплата ');
    controller.updateAmount('150');
    controller.updateType(TransactionType.income);
    controller.updateCategory(category);
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
    expect(captured.categoryId, category.id);
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

    final RecurringRuleFormState state = container.read(provider);
    expect(state.submissionSuccess, isTrue);
    expect(state.isSubmitting, isFalse);
    expect(state.generalErrorMessage, isNull);
    expect(state.isEditing, isFalse);
  });

  test('submit validates fields before calling use case', () async {
    final RecurringRuleFormControllerProvider provider =
        recurringRuleFormControllerProvider(initialRule: null);
    final RecurringRuleFormController controller = container.read(
      provider.notifier,
    );
    controller.updateTitle('  ');
    controller.updateAmount('abc');
    controller.updateAccount(null);

    await controller.submit();

    final RecurringRuleFormState state = container.read(provider);
    expect(state.titleError, RecurringRuleTitleError.empty);
    expect(state.amountError, RecurringRuleAmountError.invalid);
    expect(state.accountError, RecurringRuleAccountError.missing);
    expect(state.categoryError, RecurringRuleCategoryError.missing);
    verifyNever(() => mockUseCase.call(any()));
  });

  test('submit surfaces error when use case throws', () async {
    when(() => mockUseCase.call(any())).thenAnswer((_) async {
      throw Exception('failed');
    });

    final RecurringRuleFormControllerProvider provider =
        recurringRuleFormControllerProvider(initialRule: null);
    final RecurringRuleFormController controller = container.read(
      provider.notifier,
    );
    controller.updateAccount(_buildAccount());
    controller.updateCategory(_buildCategory());
    controller.updateTitle('Аренда');
    controller.updateAmount('500');

    await controller.submit();

    final RecurringRuleFormState state = container.read(provider);
    expect(state.submissionSuccess, isFalse);
    expect(state.isSubmitting, isFalse);
    expect(state.generalErrorMessage, contains('failed'));
    verify(() => mockUseCase.call(any())).called(1);
  });

  test('submit updates existing rule when editing', () async {
    when(() => mockUseCase.call(any())).thenAnswer((_) async {});

    final RecurringRule existingRule = _fallbackRule();
    final RecurringRuleFormControllerProvider provider =
        recurringRuleFormControllerProvider(initialRule: existingRule);
    final RecurringRuleFormController controller = container.read(
      provider.notifier,
    );
    final AccountEntity account = _buildAccount().copyWith(id: 'account-2');
    final Category category = _buildCategory();
    controller.updateAccount(account);
    controller.updateTitle('Аренда жилья');
    controller.updateAmount('750.5');
    controller.updateType(TransactionType.expense);
    controller.updateCategory(category);
    controller.updateStartDate(DateTime(2024, 2, 5));
    controller.updateTime(hour: 8, minute: 45);
    controller.updateAutoPost(true);

    await controller.submit();

    final RecurringRule captured =
        verify(() => mockUseCase.call(captureAny())).captured.single
            as RecurringRule;
    expect(captured.id, existingRule.id);
    expect(captured.title, 'Аренда жилья');
    expect(captured.accountId, account.id);
    expect(captured.categoryId, category.id);
    expect(captured.currency, account.currency);
    expect(captured.amount, 750.5);
    expect(captured.dayOfMonth, 5);
    expect(captured.applyAtLocalHour, 8);
    expect(captured.applyAtLocalMinute, 45);
    expect(captured.autoPost, isTrue);
    expect(captured.createdAt, existingRule.createdAt);
    expect(captured.updatedAt.isAfter(existingRule.updatedAt), isTrue);

    final RecurringRuleFormState state = container.read(provider);
    expect(state.submissionSuccess, isTrue);
    expect(state.isSubmitting, isFalse);
    expect(state.isEditing, isTrue);
    expect(state.initialRule?.id, existingRule.id);
  });
}
