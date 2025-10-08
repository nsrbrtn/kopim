import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/domain/use_cases/save_recurring_rule_use_case.dart';
import 'package:kopim/features/recurring_transactions/presentation/controllers/recurring_rule_form_controller.dart';
import 'package:kopim/features/recurring_transactions/presentation/models/recurring_rule_form_result.dart';
import 'package:kopim/features/recurring_transactions/presentation/widgets/recurring_rule_form_view.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:kopim/l10n/app_localizations_en.dart';
import 'package:mocktail/mocktail.dart';

class _MockSaveRecurringRuleUseCase extends Mock
    implements SaveRecurringRuleUseCase {}

RecurringRule _fallbackRule() {
  final DateTime now = DateTime.utc(2024, 1, 1);
  return RecurringRule(
    id: 'fallback',
    title: 'Fallback',
    accountId: 'acc',
    categoryId: 'cat',
    amount: 100,
    currency: 'EUR',
    startAt: now,
    timezone: 'Europe/Helsinki',
    rrule: 'FREQ=MONTHLY',
    notes: null,
    dayOfMonth: 1,
    applyAtLocalHour: 0,
    applyAtLocalMinute: 1,
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

void main() {
  late _MockSaveRecurringRuleUseCase mockUseCase;

  setUp(() {
    mockUseCase = _MockSaveRecurringRuleUseCase();
    when(() => mockUseCase.call(any())).thenAnswer((_) async {});
  });

  setUpAll(() {
    registerFallbackValue(_fallbackRule());
  });

  testWidgets('форма восстанавливает значения и сохраняет autoPost и категорию', (
    WidgetTester tester,
  ) async {
    final DateTime now = DateTime.utc(2024, 1, 1);
    final AccountEntity account = AccountEntity(
      id: 'acc-1',
      name: 'Main',
      balance: 1000,
      currency: 'EUR',
      type: 'cash',
      createdAt: now,
      updatedAt: now,
    );
    final Category category = Category(
      id: 'cat-1',
      name: 'Utilities',
      type: 'expense',
      createdAt: now,
      updatedAt: now,
    );
    final RecurringRule initialRule = RecurringRule(
      id: 'rule-1',
      title: 'Интернет',
      accountId: account.id,
      categoryId: category.id,
      amount: 250,
      currency: account.currency,
      startAt: DateTime(2024, 1, 10, 0, 1),
      timezone: 'Europe/Helsinki',
      rrule: 'FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=10',
      notes: 'Оплатить до 5-го',
      dayOfMonth: 10,
      applyAtLocalHour: 0,
      applyAtLocalMinute: 1,
      lastRunAt: null,
      nextDueLocalDate: DateTime(2024, 1, 10, 0, 1),
      isActive: true,
      autoPost: true,
      reminderMinutesBefore: null,
      shortMonthPolicy: RecurringRuleShortMonthPolicy.clipToLastDay,
      createdAt: now,
      updatedAt: now,
    );
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    RecurringRuleFormResult? result;

    await tester.pumpWidget(
      ProviderScope(
        // ignore: always_specify_types
        overrides: [
          saveRecurringRuleUseCaseProvider.overrideWithValue(mockUseCase),
          recurringRuleAccountsProvider.overrideWith(
            (Ref ref) =>
                Stream<List<AccountEntity>>.value(<AccountEntity>[account]),
          ),
          recurringRuleCategoriesProvider.overrideWith(
            (Ref ref) => Stream<List<Category>>.value(<Category>[category]),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: RecurringRuleFormView(
              formKey: formKey,
              onSuccess: (RecurringRuleFormResult value) => result = value,
              initialRule: initialRule,
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();
    await tester.fling(find.byType(ListView), const Offset(0, -600), 800);
    await tester.pumpAndSettle();

    final Iterable<Text> textWidgets = tester.widgetList<Text>(
      find.byType(Text),
    );
    final Iterable<RichText> richTextWidgets = tester.widgetList<RichText>(
      find.byType(RichText),
    );
    final bool hasAutoPostLabel =
        textWidgets.any(
          (Text text) =>
              text.data == AppLocalizationsEn().addRecurringRuleAutoPostLabel,
        ) ||
        richTextWidgets.any(
          (RichText text) => text.text.toPlainText().contains(
            AppLocalizationsEn().addRecurringRuleAutoPostLabel,
          ),
        );
    expect(
      hasAutoPostLabel,
      isTrue,
      reason:
          'Texts: ${textWidgets.map((Text text) => text.data).toList()} | RichTexts: ${richTextWidgets.map((RichText text) => text.text.toPlainText()).toList()}',
    );
    final String autoPostLabel =
        AppLocalizationsEn().addRecurringRuleAutoPostLabel;
    final Finder autoPostTileFinder = find.byWidgetPredicate((Widget widget) {
      if (widget is SwitchListTile && widget.title is Text) {
        return (widget.title as Text).data == autoPostLabel;
      }
      return false;
    });
    expect(autoPostTileFinder, findsOneWidget);
    final ProviderContainer providerContainer = ProviderScope.containerOf(
      tester.element(find.byType(RecurringRuleFormView)),
    );
    final RecurringRuleFormState initialState = providerContainer.read(
      recurringRuleFormControllerProvider(initialRule: initialRule),
    );
    expect(initialState.autoPost, isTrue);
    expect(initialState.notes, 'Оплатить до 5-го');
    expect(initialState.accountId, account.id);
    expect(initialState.categoryId, category.id);

    await tester.tap(autoPostTileFinder);
    await tester.pump();

    final RecurringRuleFormState toggledState = providerContainer.read(
      recurringRuleFormControllerProvider(initialRule: initialRule),
    );
    expect(toggledState.autoPost, isFalse);

    await tester.tap(find.text(AppLocalizationsEn().editRecurringRuleSubmit));
    await tester.pump();

    final RecurringRule captured =
        verify(() => mockUseCase.call(captureAny())).captured.single
            as RecurringRule;
    expect(captured.autoPost, isFalse);
    expect(captured.categoryId, category.id);
    expect(captured.notes, 'Оплатить до 5-го');
    expect(result, RecurringRuleFormResult.updated);
  });
}
