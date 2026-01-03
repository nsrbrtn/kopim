import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/home/presentation/widgets/home_gamification_widget.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/presentation/controllers/user_progress_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:riverpod/src/framework.dart' show Override;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeGamificationWidget', () {
    const String userId = 'user-123';

    Future<void> pumpGamificationWidget(
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
              body: HomeGamificationWidget(userId: userId),
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

      await pumpGamificationWidget(
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

    testWidgets('uses fixed minimum height for the card', (
      WidgetTester tester,
    ) async {
      final UserProgress progress = UserProgress(
        totalTx: 150,
        level: 2,
        title: 'Apprentice',
        nextThreshold: 500,
        updatedAt: DateTime(2024, 1, 1),
      );

      await pumpGamificationWidget(
        tester,
        overrides: <Override>[
          userProgressProvider(
            userId,
          ).overrideWithValue(AsyncValue<UserProgress>.data(progress)),
        ],
      );

      final Finder cardHeightFinder = find.byWidgetPredicate(
        (Widget widget) =>
            widget is ConstrainedBox &&
            widget.constraints.minHeight ==
                HomeGamificationWidget.minGamificationHeight,
      );

      expect(cardHeightFinder, findsOneWidget);
    });

    testWidgets('shows loading indicator while data loads', (
      WidgetTester tester,
    ) async {
      await pumpGamificationWidget(
        tester,
        overrides: <Override>[
          userProgressProvider(
            userId,
          ).overrideWithValue(const AsyncValue<UserProgress>.loading()),
        ],
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state message', (WidgetTester tester) async {
      await pumpGamificationWidget(
        tester,
        overrides: <Override>[
          userProgressProvider(userId).overrideWithValue(
            const AsyncValue<UserProgress>.error('boom', StackTrace.empty),
          ),
        ],
      );

      expect(find.text("Can't load progress: boom"), findsOneWidget);
    });
  });
}
