import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/app_shell/presentation/models/navigation_tab_content.dart';
import 'package:kopim/features/profile/presentation/screens/general_settings_screen.dart';
import 'package:kopim/features/profile/presentation/screens/profile_screen.dart'
    show buildProfileTabContent;
import 'package:kopim/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _MockNavigatorObserver extends Mock implements NavigatorObserver {}

class _ProfileAppBarHarness extends ConsumerWidget {
  const _ProfileAppBarHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NavigationTabContent content = buildProfileTabContent(context, ref);
    final PreferredSizeWidget? appBar = content.appBarBuilder?.call(
      context,
      ref,
    );

    return Scaffold(appBar: appBar, body: const SizedBox.shrink());
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  testWidgets('иконка настроек открывает экран общих настроек', (
    WidgetTester tester,
  ) async {
    final _MockNavigatorObserver observer = _MockNavigatorObserver();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorObservers: <NavigatorObserver>[observer],
          routes: <String, WidgetBuilder>{
            GeneralSettingsScreen.routeName: (_) => const Scaffold(),
          },
          home: const _ProfileAppBarHarness(),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    verify(
      () => observer.didPush(
        any(
          that: isA<Route<dynamic>>().having(
            (Route<dynamic> route) => route.settings.name,
            'name',
            GeneralSettingsScreen.routeName,
          ),
        ),
        any(),
      ),
    ).called(1);
  });
}

class FakeRoute extends Fake implements Route<dynamic> {}
