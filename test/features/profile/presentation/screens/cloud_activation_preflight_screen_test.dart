import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_decision_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_preflight_controller.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_activation_choice_screen.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_activation_preflight_screen.dart';
import 'package:kopim/features/profile/presentation/screens/sign_in_screen.dart';

Widget _buildTestApp({required CloudActivationPreflightState state}) {
  return ProviderScope(
    overrides: <Override>[
      cloudActivationPreflightProvider.overrideWithValue(state),
      cloudActivationDecisionProvider.overrideWithValue(
        const CloudActivationDecisionState(
          status: CloudActivationDecisionStatus.blocked,
          title: 'Как включить облачные функции',
          subtitle: 'subtitle',
          body: 'body',
          followupNote: 'note',
          localSnapshotState: CloudActivationSnapshotState.hasData,
          remoteSnapshotState: CloudActivationSnapshotState.unknown,
          options: <CloudActivationDecisionOption>[],
        ),
      ),
    ],
    child: MaterialApp(
      routes: <String, WidgetBuilder>{
        SignInScreen.routeName: (_) =>
            const Scaffold(body: Text('sign-in-screen')),
        CloudActivationChoiceScreen.routeName: (_) =>
            const Scaffold(body: Text('choice-screen')),
      },
      home: const CloudActivationPreflightScreen(),
    ),
  );
}

void main() {
  testWidgets('signedOut state opens sign-in route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(
        state: const CloudActivationPreflightState(
          CloudActivationPreflightStatus.signedOut,
        ),
      ),
    );

    expect(find.text('Нужен вход в аккаунт'), findsOneWidget);

    await tester.tap(find.text('Войти в аккаунт'));
    await tester.pumpAndSettle();

    expect(find.text('sign-in-screen'), findsOneWidget);
  });

  testWidgets('alreadyCloudEnabled state explains that preflight is not needed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(
        state: const CloudActivationPreflightState(
          CloudActivationPreflightStatus.alreadyCloudEnabled,
        ),
      ),
    );

    expect(find.text('Синхронизация уже включена'), findsOneWidget);
    expect(
      find.text(
        'Облачные функции уже активны. Дополнительный preflight для этого аккаунта сейчас не требуется.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('blocked state opens choice screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        state: const CloudActivationPreflightState(
          CloudActivationPreflightStatus.blockedByLocalOnlyData,
        ),
      ),
    );

    expect(find.text('Нужно действие перед синхронизацией'), findsOneWidget);
    expect(find.text('Выбрать сценарий'), findsOneWidget);

    await tester.tap(find.text('Выбрать сценарий'));
    await tester.pumpAndSettle();

    expect(find.text('choice-screen'), findsOneWidget);
  });

  testWidgets('ready state also opens choice screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(
        state: const CloudActivationPreflightState(
          CloudActivationPreflightStatus.readyForNextStep,
        ),
      ),
    );

    await tester.tap(find.text('Выбрать сценарий'));
    await tester.pumpAndSettle();

    expect(find.text('choice-screen'), findsOneWidget);
  });
}
