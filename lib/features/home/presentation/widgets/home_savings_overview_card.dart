import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:kopim/features/home/presentation/controllers/home_providers.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/value_objects/goal_progress.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:kopim/core/config/theme_extensions.dart';

class HomeSavingsOverviewCard extends ConsumerWidget {
  const HomeSavingsOverviewCard({this.onOpenGoal, super.key});

  final void Function(SavingGoal goal)? onOpenGoal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<List<GoalProgress>> goalsAsync = ref.watch(
      homeSavingGoalProgressProvider,
    );

    return goalsAsync.when(
      data: (List<GoalProgress> goals) {
        final List<GoalProgress> activeGoals = goals
            .where((GoalProgress progress) => !progress.goal.isArchived)
            .toList(growable: false);
        if (activeGoals.isEmpty) {
          return _HomeSavingsCardContainer(
            child: _HomeSavingsEmptyState(strings: strings, theme: theme),
          );
        }

        final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
          locale: strings.localeName,
        );
        final List<GoalProgress> visibleGoals = activeGoals
            .take(3)
            .toList(growable: false);

        return _HomeSavingsCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                strings.homeSavingsWidgetTitle,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (int i = 0; i < visibleGoals.length; i++) ...<Widget>[
                if (i != 0) const SizedBox(height: 12),
                _HomeSavingGoalTile(
                  progress: visibleGoals[i],
                  currencyFormat: currencyFormat,
                  strings: strings,
                  onTap: onOpenGoal == null
                      ? null
                      : () => onOpenGoal!(visibleGoals[i].goal),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const _HomeSavingsCardContainer(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, _) => _HomeSavingsCardContainer(
        child: Text(
          strings.genericErrorMessage,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ),
    );
  }
}

class _HomeSavingsEmptyState extends StatelessWidget {
  const _HomeSavingsEmptyState({required this.strings, required this.theme});

  final AppLocalizations strings;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          strings.homeSavingsWidgetTitle,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          strings.homeSavingsWidgetEmpty,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }
}

class _HomeSavingGoalTile extends StatelessWidget {
  const _HomeSavingGoalTile({
    required this.progress,
    required this.currencyFormat,
    required this.strings,
    this.onTap,
  });

  final GoalProgress progress;
  final NumberFormat currencyFormat;
  final AppLocalizations strings;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double percent = progress.percent.clamp(0, 1);
    final String percentLabel = NumberFormat.percentPattern(
      strings.localeName,
    ).format(percent);
    final String balanceLabel =
        '${currencyFormat.format(progress.goal.currentAmount / 100)} · ${currencyFormat.format(progress.goal.targetAmount / 100)}';

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    progress.goal.name,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  percentLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: LinearProgressIndicator(value: percent),
            ),
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    balanceLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.72,
                      ),
                    ),
                  ),
                ),
                Text(
                  strings.savingsRemainingLabel(
                    currencyFormat.format(progress.remaining.minorUnits / 100),
                  ),
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSavingsCardContainer extends StatelessWidget {
  const _HomeSavingsCardContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double cardRadius = context.kopimLayout.radius.xxl;
    final BorderRadius borderRadius = BorderRadius.circular(cardRadius);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: child,
          ),
        ),
      ),
    );
  }
}
