import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/features/getting_started/domain/entities/getting_started_preferences.dart';
import 'package:kopim/features/getting_started/domain/entities/getting_started_progress.dart';
import 'package:kopim/features/getting_started/domain/entities/getting_started_view_model.dart';
import 'package:kopim/features/getting_started/presentation/controllers/getting_started_controller.dart';
import 'package:kopim/features/getting_started/presentation/widgets/getting_started_card.dart';
import 'package:kopim/features/getting_started/presentation/widgets/getting_started_celebration_dialog.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:riverpod/src/framework.dart' show Override;

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
        GettingStartedStepId.transaction,
      ]);
    },
  );

  testWidgets(
    'показывает GettingStartedCelebrationDialog при завершении чеклиста',
    (WidgetTester tester) async {
      GettingStartedViewModel currentModel = const GettingStartedViewModel(
        preferences: GettingStartedPreferences(
          hasActivated: true,
          isHidden: false,
        ),
        progress: GettingStartedProgress(
          hasAccounts: false,
          hasUserCategories: false,
          hasTransactions: false,
          hasProfileName: false,
          hasSavingGoal: false,
          hasBudget: false,
        ),
        shouldAutoActivate: false,
        shouldDisplayOnHome: true,
      );

      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          gettingStartedViewModelProvider.overrideWith((Ref ref) {
            return AsyncValue<GettingStartedViewModel>.data(currentModel);
          }),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('ru'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: GettingStartedCardHost(onRouteRequested: (_) {}),
            ),
          ),
        ),
      );

      await tester.pump();

      // Изначально диалог не должен быть виден
      expect(find.byType(GettingStartedCelebrationDialog), findsNothing);

      // Изменяем модель на полностью завершенную
      currentModel = const GettingStartedViewModel(
        preferences: GettingStartedPreferences(
          hasActivated: true,
          isHidden: false,
        ),
        progress: GettingStartedProgress(
          hasAccounts: true,
          hasUserCategories: true,
          hasTransactions: true,
          hasProfileName: true,
          hasSavingGoal: true,
          hasBudget: true,
        ),
        shouldAutoActivate: false,
        shouldDisplayOnHome: false,
      );

      // Перезапускаем расчет состояния
      container.refresh(gettingStartedViewModelProvider);
      await tester.pump();
      // Завершаем анимацию появления диалога
      await tester.pump(const Duration(milliseconds: 500));

      // Проверяем наличие диалога
      expect(find.byType(GettingStartedCelebrationDialog), findsOneWidget);

      final AppLocalizations strings = AppLocalizations.of(
        tester.element(find.byType(GettingStartedCelebrationDialog)),
      )!;

      expect(find.text(strings.gettingStartedCelebrationTitle), findsOneWidget);
      expect(
        find.text(strings.gettingStartedCelebrationSubtitle),
        findsOneWidget,
      );

      // Нажимаем кнопку закрытия диалога
      await tester.tap(find.text(strings.gettingStartedCelebrationButton));
      await tester.pumpAndSettle();

      // Диалог должен закрыться
      expect(find.byType(GettingStartedCelebrationDialog), findsNothing);
    },
  );
}
