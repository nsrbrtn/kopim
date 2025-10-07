import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/policies/level_policy.dart';
import 'package:kopim/features/profile/presentation/controllers/user_progress_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

class HomeGamificationCard extends ConsumerWidget {
  const HomeGamificationCard({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<UserProgress> progressAsync = ref.watch(
      userProgressProvider(userId),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              strings.homeGamificationTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              strings.homeGamificationSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            progressAsync.when(
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
                final int xpToNext = math.max(
                  0,
                  nextThreshold - progress.totalTx,
                );
                final bool maxedOut = nextThreshold == progress.totalTx;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Chip(
                      label: Text(
                        strings.profileLevelBadge(
                          progress.level,
                          progress.title,
                        ),
                      ),
                      avatar: const Icon(Icons.emoji_events_outlined),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      child: LinearProgressIndicator(value: ratio),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      maxedOut
                          ? strings.profileLevelMaxReached
                          : strings.profileXpToNext(xpToNext),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                );
              },
              loading: () => const Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (Object error, _) => Text(
                strings.homeGamificationError(error.toString()),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
