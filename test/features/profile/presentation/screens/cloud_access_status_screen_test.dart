import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_access_status_screen.dart';

import '../router_test_helper.dart';

class _FakeDataModeController extends DataModeController {
  _FakeDataModeController(this._state);

  final DataModeState _state;

  @override
  Future<DataModeState> build() async => _state;
}

void main() {
  Widget buildApp(DataModeState state) {
    return ProviderScope(
      overrides: <Override>[
        dataModeControllerProvider.overrideWith(
          () => _FakeDataModeController(state),
        ),
      ],
      child: buildTestAppWithRouter(
        child: const Scaffold(body: Text('home-screen')),
        additionalRoutes: <RouteBase>[
          GoRoute(
            path: CloudAccessStatusScreen.routeName,
            builder: (BuildContext context, GoRouterState state) =>
                const CloudAccessStatusScreen(),
          ),
        ],
      ),
    );
  }

  testWidgets('continue local closes access status screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        const DataModeState(
          dataMode: DataMode.localOnly,
          entitlementState: CloudEntitlementState.notActivated,
          migrationDecision: MigrationDecision.none,
        ),
      ),
    );

    final BuildContext context = tester.element(find.text('home-screen'));
    GoRouter.of(context).push(CloudAccessStatusScreen.routeName);
    await tester.pumpAndSettle();

    expect(find.text('Доступ не активен'), findsOneWidget);

    await tester.tap(find.text('Продолжить локально'));
    await tester.pumpAndSettle();

    expect(find.text('home-screen'), findsOneWidget);
  });

  testWidgets('expired entitlement shows paused local copy', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        const DataModeState(
          dataMode: DataMode.localOnly,
          entitlementState: CloudEntitlementState.expired,
          migrationDecision: MigrationDecision.none,
        ),
      ),
    );

    final BuildContext context = tester.element(find.text('home-screen'));
    GoRouter.of(context).push(CloudAccessStatusScreen.routeName);
    await tester.pumpAndSettle();

    expect(find.text('Срок доступа истек'), findsOneWidget);
    expect(
      find.text(
        'Для текущего аккаунта срок облачного доступа истек. Синхронизация остается на паузе, но локальные данные на этом устройстве доступны. Проверьте статус снова, если доступ уже обновлен.',
      ),
      findsOneWidget,
    );
  });
}
