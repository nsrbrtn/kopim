import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_activation_preflight_screen.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_sync_intro_screen.dart';
import 'package:kopim/features/profile/presentation/screens/sign_in_screen.dart';
import 'package:go_router/go_router.dart';

import '../router_test_helper.dart';

void main() {
  testWidgets('intro screen opens sign-in with resume flag', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestAppWithRouter(
        child: const CloudSyncIntroScreen(),
        initialLocation: CloudSyncIntroScreen.routeName,
        additionalRoutes: <RouteBase>[
          GoRoute(
            path: SignInScreen.routeName,
            builder: (BuildContext context, GoRouterState state) => Scaffold(
              body: Text(
                'resume=${state.uri.queryParameters['resumeCloudActivation']}',
              ),
            ),
          ),
        ],
      ),
    );

    expect(find.text('Включить синхронизацию'), findsOneWidget);

    await tester.tap(find.text('Войти в аккаунт'));
    await tester.pumpAndSettle();

    expect(find.text('resume=true'), findsOneWidget);
  });

  testWidgets('continue local closes intro screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestAppWithRouter(
        child: const Scaffold(body: Text('home-screen')),
        additionalRoutes: <RouteBase>[
          GoRoute(
            path: CloudSyncIntroScreen.routeName,
            builder: (BuildContext context, GoRouterState state) =>
                const CloudSyncIntroScreen(),
          ),
          mockRoute(
            CloudActivationPreflightScreen.routeName,
            text: 'preflight',
          ),
        ],
      ),
    );

    final BuildContext context = tester.element(find.text('home-screen'));
    GoRouter.of(context).push(CloudSyncIntroScreen.routeName);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Продолжить локально'));
    await tester.pumpAndSettle();

    expect(find.text('home-screen'), findsOneWidget);
  });
}
