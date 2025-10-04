import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_occurrence.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/presentation/controllers/recurring_rule_form_controller.dart';
import 'package:kopim/features/recurring_transactions/presentation/controllers/recurring_transactions_providers.dart';
import 'package:kopim/features/recurring_transactions/presentation/screens/add_recurring_rule_screen.dart';
import 'package:kopim/features/recurring_transactions/presentation/screens/recurring_transactions_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';
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
    final StreamController<List<RecurringOccurrence>> occurrencesController =
        StreamController<List<RecurringOccurrence>>();
    addTearDown(() async {
      await rulesController.close();
      await occurrencesController.close();
    });
    rulesController.add(const <RecurringRule>[]);
    occurrencesController.add(const <RecurringOccurrence>[]);

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
          upcomingRecurringOccurrencesProvider().overrideWith(
            (Ref ref) => occurrencesController.stream,
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
}
