import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/home/presentation/widgets/home_gamification_app_bar.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/presentation/controllers/user_progress_controller.dart';
import 'package:kopim/features/profile/presentation/screens/profile_management_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:riverpod/src/framework.dart' show Override;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeGamificationAppBar', () {
    const String userId = 'user-123';

    Future<void> pumpGamificationAppBar(
      WidgetTester tester, {
      List<Override> overrides = const <Override>[],
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: CustomScrollView(
                slivers: <Widget>[
                  HomeGamificationAppBar(userId: userId),
                  SliverToBoxAdapter(child: SizedBox(height: 800)),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
    }

    testWidgets('renders progress state when data is available', (
      WidgetTester tester,
    ) async {
      final UserProgress progress = UserProgress(
        totalTx: 150,
        level: 2,
        title: 'Apprentice',
        nextThreshold: 500,
        updatedAt: DateTime(2024, 1, 1),
      );

      await pumpGamificationAppBar(
        tester,
        overrides: <Override>[
          userProgressProvider(
            userId,
          ).overrideWithValue(AsyncValue<UserProgress>.data(progress)),
        ],
      );

      expect(find.textContaining('XP to the next level'), findsOneWidget);

      final LinearProgressIndicator indicator = tester.widget(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, closeTo(0.125, 0.001));
    });

    testWidgets('uses fixed heights for app bar and gamification card', (
      WidgetTester tester,
    ) async {
      final UserProgress progress = UserProgress(
        totalTx: 150,
        level: 2,
        title: 'Apprentice',
        nextThreshold: 500,
        updatedAt: DateTime(2024, 1, 1),
      );

      await pumpGamificationAppBar(
        tester,
        overrides: <Override>[
          userProgressProvider(
            userId,
          ).overrideWithValue(AsyncValue<UserProgress>.data(progress)),
        ],
      );

      final SliverAppBar appBar = tester.widget(
        find.byType(SliverAppBar).first,
      );
      expect(appBar.toolbarHeight, HomeGamificationAppBar.appBarHeight);

      final Finder cardHeightFinder = find.byWidgetPredicate(
        (Widget widget) =>
            widget is SizedBox &&
            widget.height == HomeGamificationAppBar.gamificationHeight,
      );

      expect(cardHeightFinder, findsOneWidget);
    });

    testWidgets('shows loading indicator while data loads', (
      WidgetTester tester,
    ) async {
      await pumpGamificationAppBar(
        tester,
        overrides: <Override>[
          userProgressProvider(
            userId,
          ).overrideWithValue(const AsyncValue<UserProgress>.loading()),
        ],
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state message', (WidgetTester tester) async {
      await pumpGamificationAppBar(
        tester,
        overrides: <Override>[
          userProgressProvider(userId).overrideWithValue(
            const AsyncValue<UserProgress>.error('boom', StackTrace.empty),
          ),
        ],
      );

      expect(find.text("Can't load progress: boom"), findsOneWidget);
    });

    testWidgets('profile action navigates to profile management', (
      WidgetTester tester,
    ) async {
      final UserProgress progress = UserProgress(
        totalTx: 200,
        level: 3,
        title: 'Expert',
        nextThreshold: 800,
        updatedAt: DateTime(2024, 2, 1),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            userProgressProvider(
              userId,
            ).overrideWithValue(AsyncValue<UserProgress>.data(progress)),
          ],
          child: MaterialApp(
            routes: <String, WidgetBuilder>{
              ProfileManagementScreen.routeName: (_) =>
                  const Scaffold(body: Text('Profile Management')),
            },
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const CustomScrollView(
              slivers: <Widget>[
                HomeGamificationAppBar(userId: userId),
                SliverToBoxAdapter(child: SizedBox(height: 400)),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.account_circle_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Profile Management'), findsOneWidget);
    });
  });
}
