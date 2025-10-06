import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/presentation/widgets/profile_overview_card.dart';
import 'package:kopim/l10n/app_localizations.dart';

void main() {
  testWidgets('renders avatar preview and level badge', (
    WidgetTester tester,
  ) async {
    final Profile profile = Profile(
      uid: 'test-user',
      name: 'Totoro Fan',
      currency: ProfileCurrency.rub,
      locale: 'ru',
      photoUrl: 'https://example.com/avatar.jpg',
      updatedAt: DateTime.now(),
    );

    final UserProgress progress = UserProgress(
      totalTx: 150,
      level: 2,
      title: 'Ученик Кодамы',
      nextThreshold: 500,
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ProfileOverviewCard(
              profile: profile,
              progressAsync: AsyncValue<UserProgress>.data(progress),
              uid: profile.uid,
              avatarState: const AsyncData<void>(null),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.textContaining('Level'), findsOneWidget);
  });
}
