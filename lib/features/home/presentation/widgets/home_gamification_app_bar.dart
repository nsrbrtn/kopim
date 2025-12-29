import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/policies/level_policy.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/user_progress_controller.dart';
import 'package:kopim/features/profile/presentation/screens/profile_management_screen.dart';
import 'package:kopim/features/home/presentation/widgets/top_bar_avatar_icon.dart';
import 'package:kopim/features/home/presentation/widgets/sync_status_indicator.dart';
import 'package:kopim/l10n/app_localizations.dart';

class HomeGamificationAppBar extends ConsumerWidget {
  const HomeGamificationAppBar({required this.userId, super.key});

  final String userId;

  static const double appBarHeight = 40;
  static const double minGamificationHeight = 80;

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
    final AsyncValue<Profile?> profileAsync = ref.watch(
      profileControllerProvider(userId),
    );
    final LevelPolicy policy = ref.read(levelPolicyProvider);
    final double topPadding = MediaQuery.of(context).padding.top;
    final TextTheme textTheme = theme.textTheme;
    final String headline = _phraseForDate(DateTime.now());

    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverAppBar(
          automaticallyImplyLeading: false,
          floating: false,
          pinned: false,
          snap: false,
          expandedHeight: topPadding + appBarHeight,
          collapsedHeight: topPadding + appBarHeight,
          toolbarHeight: appBarHeight,
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: theme.colorScheme.surfaceTint,
          elevation: 4,
          titleSpacing: 20,
          title: Text(
            'Копим',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          actions: <Widget>[
            const Center(child: SyncStatusIndicator()),
            const SizedBox(width: 12),
            Semantics(
              label: strings.homeProfileTooltip,
              button: true,
              child: profileAsync.when(
                data: (Profile? profile) => IconButton(
                  tooltip: strings.homeProfileTooltip,
                  padding: EdgeInsets.zero,
                  iconSize: 48,
                  icon: SizedBox(
                    width: 48,
                    height: 48,
                    child: TopBarAvatarIcon(photoUrl: profile?.photoUrl),
                  ),
                  onPressed: () {
                    context.push(ProfileManagementScreen.routeName);
                  },
                ),
                loading: () => IconButton(
                  tooltip: strings.homeProfileTooltip,
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    context.push(ProfileManagementScreen.routeName);
                  },
                  icon: const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (Object error, StackTrace? stackTrace) => IconButton(
                  tooltip: strings.homeProfileTooltip,
                  padding: EdgeInsets.zero,
                  iconSize: 48,
                  icon: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(Icons.account_circle_outlined),
                  ),
                  onPressed: () {
                    context.push(ProfileManagementScreen.routeName);
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverToBoxAdapter(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: minGamificationHeight,
              ),
              child: _HomeGamificationCard(
                progressAsync: progressAsync,
                policy: policy,
                headline: headline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeGamificationCard extends StatelessWidget {
  const _HomeGamificationCard({
    required this.progressAsync,
    required this.policy,
    required this.headline,
  });

  final AsyncValue<UserProgress> progressAsync;
  final LevelPolicy policy;
  final String headline;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final TextTheme textTheme = theme.textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Align(
          alignment: Alignment.center,
          child: progressAsync.when(
            data: (UserProgress progress) {
              final int previousThreshold = policy.previousThreshold(
                progress.level,
              );
              final int nextThreshold = progress.nextThreshold;
              final double ratio = nextThreshold == previousThreshold
                  ? 1.0
                  : ((progress.totalTx - previousThreshold) /
                            (nextThreshold - previousThreshold))
                        .clamp(0.0, 1.0);
              final int xpToNext = math.max(
                0,
                nextThreshold - progress.totalTx,
              );
              final bool maxedOut = nextThreshold == progress.totalTx;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    headline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: LinearProgressIndicator(value: ratio, minHeight: 8),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    maxedOut
                        ? strings.profileLevelMaxReached
                        : strings.profileXpToNext(xpToNext),
                    style: textTheme.bodyMedium,
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (Object error, _) => Align(
              alignment: Alignment.centerLeft,
              child: Text(
                strings.homeGamificationError(error.toString()),
                style: textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
