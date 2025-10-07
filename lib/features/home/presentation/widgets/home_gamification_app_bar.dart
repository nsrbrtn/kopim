import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/policies/level_policy.dart';
import 'package:kopim/features/profile/presentation/controllers/user_progress_controller.dart';
import 'package:kopim/features/profile/presentation/screens/profile_management_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';

class HomeGamificationAppBar extends ConsumerWidget {
  const HomeGamificationAppBar({required this.userId, super.key});

  final String userId;

  static const double _expandedHeight = 220;

  static const List<String> _phrases = <String>[
    'Ты экономишь как супергерой!',
    'Каждая транзакция приближает к мечте!',
    'Бюджет под контролем – ты молодец!',
    'Финансы слушаются только тебя!',
    'Продолжай в том же духе, кошелёк улыбается!',
  ];

  String _phraseForDate(DateTime date) {
    final DateTime anchor = DateTime.utc(2024, 1, 1);
    final int dayIndex = date.toUtc().difference(anchor).inDays;
    final int normalized = dayIndex % _phrases.length;
    final int safeIndex = normalized < 0
        ? normalized + _phrases.length
        : normalized;
    return _phrases[safeIndex];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<UserProgress> progressAsync = ref.watch(
      userProgressProvider(userId),
    );
    final double topPadding = MediaQuery.of(context).padding.top;
    final TextTheme textTheme = theme.textTheme;
    final String headline = _phraseForDate(DateTime.now());

    Widget buildProgressSection() {
      return progressAsync.when(
        data: (UserProgress progress) {
          final LevelPolicy policy = ref.read(levelPolicyProvider);
          final int previousThreshold = policy.previousThreshold(
            progress.level,
          );
          final int nextThreshold = progress.nextThreshold;
          final double ratio = nextThreshold == previousThreshold
              ? 1.0
              : ((progress.totalTx - previousThreshold) /
                        (nextThreshold - previousThreshold))
                    .clamp(0.0, 1.0);
          final int xpToNext = math.max(0, nextThreshold - progress.totalTx);
          final bool maxedOut = nextThreshold == progress.totalTx;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                headline,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: LinearProgressIndicator(value: ratio, minHeight: 8),
              ),
              const SizedBox(height: 8),
              Text(
                maxedOut
                    ? strings.profileLevelMaxReached
                    : strings.profileXpToNext(xpToNext),
                style: textTheme.bodyMedium,
              ),
            ],
          );
        },
        loading: () => const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (Object error, _) => Text(
          strings.homeGamificationError(error.toString()),
          style: textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
        ),
      );
    }

    return SliverAppBar(
      automaticallyImplyLeading: false,
      floating: false,
      pinned: true,
      snap: false,
      expandedHeight: _expandedHeight,
      collapsedHeight: kToolbarHeight + topPadding,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      elevation: 4,
      titleSpacing: 20,
      title: Text(
        'Копим',
        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      actions: <Widget>[
        Semantics(
          label: strings.homeProfileTooltip,
          button: true,
          child: IconButton(
            tooltip: strings.homeProfileTooltip,
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamed(ProfileManagementScreen.routeName);
            },
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double maxHeight = constraints.biggest.height;
          final double minHeight = kToolbarHeight + topPadding;
          final double expansionFactor =
              (maxHeight - minHeight) /
              (HomeGamificationAppBar._expandedHeight - minHeight);
          final double clamped = expansionFactor.clamp(0.0, 1.0);
          final double opacity = Curves.easeInOut.transform(clamped);
          final double verticalOffset = (1 - opacity) * 12;

          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  top: topPadding + kToolbarHeight,
                  left: 20,
                  right: 20,
                  bottom: 16,
                ),
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    heightFactor: opacity == 0 ? 0.0 : opacity,
                    child: Opacity(
                      key: const Key('homeGamification.progressOpacity'),
                      opacity: opacity,
                      child: Transform.translate(
                        offset: Offset(0, verticalOffset),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: buildProgressSection(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
