import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/presentation/controllers/recurring_rule_form_controller.dart';
import 'package:kopim/features/recurring_transactions/presentation/controllers/recurring_transactions_providers.dart';
import 'package:kopim/features/recurring_transactions/presentation/screens/add_recurring_rule_screen.dart';
import 'package:kopim/features/recurring_transactions/presentation/screens/recurring_transactions_screen.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:kopim/l10n/app_localizations_en.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _RecordingNavigatorObserver extends NavigatorObserver {
  _RecordingNavigatorObserver(this.pushedRoutes);

  final List<Route<dynamic>> pushedRoutes;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    pushedRoutes.add(route);
  }
}

void main() {
  testWidgets('нажатие на кнопку добавления открывает экран создания правила', (
    WidgetTester tester,
  ) async {
    final List<Route<dynamic>> pushedRoutes = <Route<dynamic>>[];
    final NavigatorObserver observer = _RecordingNavigatorObserver(
      pushedRoutes,
    );

    final StreamController<List<RecurringRule>> rulesController =
        StreamController<List<RecurringRule>>();
    addTearDown(() async {
      await rulesController.close();
    });
    rulesController.add(const <RecurringRule>[]);

    await tester.pumpWidget(
      ProviderScope(
        // ignore: always_specify_types
        overrides: [
          recurringRulesProvider.overrideWith(
            (Ref ref) => rulesController.stream,
          ),
          recurringRuleAccountsProvider.overrideWith(
            (Ref ref) => Stream<List<AccountEntity>>.value(<AccountEntity>[
              AccountEntity(
                id: 'acc-1',
                name: 'Main',
                balance: 0,
                currency: 'USD',
                type: 'cash',
                createdAt: DateTime(2024, 1, 1),
                updatedAt: DateTime(2024, 1, 1),
              ),
            ]),
          ),
          recurringRuleCategoriesProvider.overrideWith(
            (Ref ref) => Stream<List<Category>>.value(<Category>[
              Category(
                id: 'cat-expense',
                name: 'Utilities',
                type: 'expense',
                createdAt: DateTime(2024, 1, 1),
                updatedAt: DateTime(2024, 1, 1),
              ),
              Category(
                id: 'cat-income',
                name: 'Salary',
                type: 'income',
                createdAt: DateTime(2024, 1, 1),
                updatedAt: DateTime(2024, 1, 1),
              ),
            ]),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RecurringTransactionsScreen(),
          routes: <String, WidgetBuilder>{
            AddRecurringRuleScreen.routeName: (_) =>
                const AddRecurringRuleScreen(),
          },
          navigatorObservers: <NavigatorObserver>[observer],
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      pushedRoutes.map((Route<dynamic> route) => route.settings.name),
      contains(AddRecurringRuleScreen.routeName),
    );
    expect(find.byType(AddRecurringRuleScreen), findsOneWidget);
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets(
    'отображается ближайшая дата, если операция должна произойти сегодня',
    (WidgetTester tester) async {
      final StreamController<List<RecurringRule>> rulesController =
          StreamController<List<RecurringRule>>();
      addTearDown(() async {
        await rulesController.close();
      });
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day, 0, 1);
      final RecurringRule rule = RecurringRule(
        id: 'rule-today',
        title: 'Аренда',
        accountId: 'acc-1',
        categoryId: 'cat-expense',
        amount: 500,
        currency: 'USD',
        startAt: today.subtract(const Duration(days: 30)),
        timezone: 'Europe/Helsinki',
        rrule: 'FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=${today.day}',
        notes: null,
        dayOfMonth: today.day,
        applyAtLocalHour: 0,
        applyAtLocalMinute: 1,
        lastRunAt: today.subtract(const Duration(days: 30)),
        nextDueLocalDate: today,
        isActive: true,
        autoPost: false,
        reminderMinutesBefore: null,
        shortMonthPolicy: RecurringRuleShortMonthPolicy.clipToLastDay,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );
      rulesController.add(<RecurringRule>[rule]);

      await tester.pumpWidget(
        ProviderScope(
          // ignore: always_specify_types
          overrides: [
            recurringRulesProvider.overrideWith(
              (Ref ref) => rulesController.stream,
            ),
            recurringRuleAccountsProvider.overrideWith(
              (Ref ref) => Stream<List<AccountEntity>>.value(<AccountEntity>[
                AccountEntity(
                  id: 'acc-1',
                  name: 'Main',
                  balance: 0,
                  currency: 'USD',
                  type: 'cash',
                  createdAt: DateTime(2024, 1, 1),
                  updatedAt: DateTime(2024, 1, 1),
                ),
              ]),
            ),
            recurringRuleCategoriesProvider.overrideWith(
              (Ref ref) => Stream<List<Category>>.value(<Category>[
                Category(
                  id: 'cat-expense',
                  name: 'Utilities',
                  type: 'expense',
                  createdAt: DateTime(2024, 1, 1),
                  updatedAt: DateTime(2024, 1, 1),
                ),
              ]),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: RecurringTransactionsScreen(),
          ),
        ),
      );

      await tester.pump();

      final DateFormat formatter = DateFormat.yMMMMd();
      final String expectedDate = formatter.format(today.toLocal());

      expect(find.textContaining('Next due'), findsOneWidget);
      expect(find.textContaining(expectedDate), findsOneWidget);
      expect(
        find.text(AppLocalizationsEn().recurringTransactionsNoUpcoming),
        findsNothing,
      );
    },
  );
}
