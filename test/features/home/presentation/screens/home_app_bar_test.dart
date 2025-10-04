import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kopim/features/app_shell/presentation/models/navigation_tab_content.dart';
import 'package:kopim/features/home/presentation/screens/home_screen.dart';
import 'package:kopim/features/profile/presentation/screens/profile_management_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';

class _MockNavigatorObserver extends Mock implements NavigatorObserver {}

class _FakeRoute<T> extends Fake implements Route<T> {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeRoute<dynamic>());
  });

  testWidgets('tapping profile action opens profile management screen', (
    WidgetTester tester,
  ) async {
    final _MockNavigatorObserver observer = _MockNavigatorObserver();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          navigatorObservers: <NavigatorObserver>[observer],
          routes: <String, WidgetBuilder>{
            ProfileManagementScreen.routeName: (_) =>
                const Scaffold(body: Text('Profile Management')),
          },
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Consumer(
            builder: (BuildContext context, WidgetRef ref, _) {
              final NavigationTabContent content = buildHomeTabContent(
                context,
                ref,
              );
              return Scaffold(
                appBar: content.appBarBuilder?.call(context, ref),
              );
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.account_circle_outlined));
    await tester.pumpAndSettle();

    verify(
      () => observer.didPush(
        any(
          that: isA<Route<dynamic>>().having(
            (Route<dynamic> route) => route.settings.name,
            'routeName',
            ProfileManagementScreen.routeName,
          ),
        ),
        any(),
      ),
    ).called(1);
    expect(find.text('Profile Management'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
