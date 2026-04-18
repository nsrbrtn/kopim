import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/getting_started/domain/entities/getting_started_progress.dart';
import 'package:kopim/features/getting_started/domain/entities/getting_started_preferences.dart';
import 'package:kopim/features/getting_started/domain/entities/getting_started_view_model.dart';
import 'package:kopim/features/getting_started/presentation/widgets/getting_started_card.dart';
import 'package:kopim/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'отображает шаги и вызывает callback только для доступного шага',
    (WidgetTester tester) async {
      final List<GettingStartedStepId> tappedSteps = <GettingStartedStepId>[];

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ru'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ListView(
              children: <Widget>[
                GettingStartedCard(
                  model: const GettingStartedViewModel(
                    preferences: GettingStartedPreferences(
                      hasActivated: true,
                      isHidden: false,
                    ),
                    progress: GettingStartedProgress(
                      hasAccounts: true,
                      hasUserCategories: false,
                      hasTransactions: false,
                      hasProfileName: false,
                      hasSavingGoal: false,
                      hasBudget: false,
                    ),
                    shouldAutoActivate: false,
                    shouldDisplayOnHome: true,
                  ),
                  onDismiss: () {},
                  onStepTap: tappedSteps.add,
                ),
              ],
            ),
          ),
        ),
      );

      final AppLocalizations strings = AppLocalizations.of(
        tester.element(find.byType(GettingStartedCard)),
      )!;

      expect(find.text(strings.gettingStartedTitle), findsOneWidget);
      expect(
        find.text(strings.gettingStartedProgressLabel(1, 5)),
        findsOneWidget,
      );

      await tester.tap(find.text(strings.gettingStartedStepCategoryTitle));
      await tester.pump();

      expect(tappedSteps, <GettingStartedStepId>[
        GettingStartedStepId.category,
      ]);

      await tester.tap(find.text(strings.gettingStartedStepTransactionTitle));
      await tester.pump();

      expect(tappedSteps, <GettingStartedStepId>[
        GettingStartedStepId.category,
      ]);
    },
  );
}
