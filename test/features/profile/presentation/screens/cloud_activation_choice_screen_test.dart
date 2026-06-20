import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_decision_controller.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_activation_choice_screen.dart';

Widget _buildTestApp({required CloudActivationDecisionState state}) {
  return ProviderScope(
    overrides: <Override>[
      cloudActivationDecisionProvider.overrideWithValue(state),
    ],
    child: const MaterialApp(home: CloudActivationChoiceScreen()),
  );
}

void _useLargeSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2000);
  tester.view.devicePixelRatio = 1.0;
}

void main() {
  const CloudActivationDecisionState
  blockedState = CloudActivationDecisionState(
    status: CloudActivationDecisionStatus.blocked,
    scenario: CloudActivationScenario.localHasDataRemoteUnknown,
    title: 'Как включить облачные функции',
    subtitle:
        'Сначала выберите, как Kopim должен работать с вашими данными дальше.',
    body:
        'На этом устройстве уже есть локальные данные. Пока приложение не выполняет перенос автоматически.',
    followupNote:
        'Это подготовительный шаг: локальные данные пока никуда не отправлены.',
    localSnapshotState: CloudActivationSnapshotState.hasData,
    remoteSnapshotState: CloudActivationSnapshotState.unknown,
    options: <CloudActivationDecisionOption>[
      CloudActivationDecisionOption(
        choice: CloudActivationChoice.stayLocalOnly,
        title: 'Остаться локально',
        body: 'Закрыть flow без изменения данных.',
        availability: CloudActivationChoiceAvailability.available,
      ),
      CloudActivationDecisionOption(
        choice: CloudActivationChoice.startWithEmptyCloud,
        title: 'Начать с пустого облака',
        body: 'Подготовить пустой облачный старт.',
        availability: CloudActivationChoiceAvailability.requiresConfirmation,
        followupNote:
            'На этом шаге это только подтверждение выбора без изменения данных.',
      ),
      CloudActivationDecisionOption(
        choice: CloudActivationChoice.mergeLocalAndCloud,
        title: 'Объединить локальные и облачные данные',
        body: 'Сценарий появится позже.',
        availability:
            CloudActivationChoiceAvailability.unavailableUntilExecutionFlow,
        followupNote: 'Для merge пока нет execution flow.',
      ),
    ],
  );

  testWidgets('renders choice options and badges', (WidgetTester tester) async {
    _useLargeSurface(tester);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_buildTestApp(state: blockedState));

    expect(find.text('Как включить облачные функции'), findsOneWidget);
    expect(find.text('Остаться локально'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Начать с пустого облака'),
      200,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Нужно подтверждение'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Объединить локальные и облачные данные'),
      200,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Следующий этап'), findsOneWidget);
  });

  testWidgets('requires confirmation before placeholder choice', (
    WidgetTester tester,
  ) async {
    _useLargeSurface(tester);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_buildTestApp(state: blockedState));

    await tester.scrollUntilVisible(
      find.text('Начать с пустого облака'),
      200,
      scrollable: find.byType(Scrollable),
    );
    final Finder optionCard = find.ancestor(
      of: find.text('Начать с пустого облака'),
      matching: find.byType(Card),
    );
    await tester.tap(
      find.descendant(
        of: optionCard,
        matching: find.widgetWithText(OutlinedButton, 'Выбрать'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Начать с пустого облака'), findsWidgets);

    await tester.tap(find.text('Понятно'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'На этом шаге это только подтверждение выбора без изменения данных.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('unavailable option shows placeholder snackbar', (
    WidgetTester tester,
  ) async {
    _useLargeSurface(tester);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_buildTestApp(state: blockedState));

    await tester.scrollUntilVisible(
      find.text('Объединить локальные и облачные данные'),
      200,
      scrollable: find.byType(Scrollable),
    );
    final Finder optionCard = find.ancestor(
      of: find.text('Объединить локальные и облачные данные'),
      matching: find.byType(Card),
    );
    final Finder chooseButton = find.descendant(
      of: optionCard,
      matching: find.widgetWithText(OutlinedButton, 'Выбрать'),
    );
    await tester.scrollUntilVisible(
      chooseButton,
      120,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(chooseButton);
    await tester.pumpAndSettle();

    expect(find.text('Для merge пока нет execution flow.'), findsOneWidget);
  });
}
