import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/value_objects/goal_progress.dart';
import 'package:kopim/l10n/app_localizations.dart';

class SavingGoalCard extends StatelessWidget {
  const SavingGoalCard({
    super.key,
    required this.goal,
    required this.progress,
    required this.onContribute,
    required this.onEdit,
    required this.onArchive,
    this.onOpen,
  });

  final SavingGoal goal;
  final GoalProgress progress;
  final VoidCallback onContribute;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final KopimLayout layout = context.kopimLayout;
    final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toString(),
    );
    final NumberFormat percentFormat = NumberFormat.percentPattern(
      Localizations.localeOf(context).toString(),
    );
    final double percentValue = progress.percent.clamp(0, 1);
    final String percentLabel = percentFormat.format(percentValue);
    final String currentLabel = currencyFormat.format(
      progress.goal.currentAmount / 100,
    );
    final String targetLabel = currencyFormat.format(
      progress.goal.targetAmount / 100,
    );
    final String remainingLabel = currencyFormat.format(
      progress.remaining.minorUnits / 100,
    );
    final _SavingGoalCardColors cardColors = _resolveCardColors(theme, goal);
    final double radius = layout.radius.card;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: cardColors.background,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(radius),
        child: Padding(
          padding: EdgeInsets.all(layout.spacing.section),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      goal.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: cardColors.onBackground,
                      ),
                    ),
                  ),
                  PopupMenuButton<_GoalAction>(
                    onSelected: (_GoalAction action) {
                      switch (action) {
                        case _GoalAction.edit:
                          onEdit();
                          break;
                        case _GoalAction.archive:
                          onArchive();
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<_GoalAction>>[
                          PopupMenuItem<_GoalAction>(
                            value: _GoalAction.edit,
                            child: Text(strings.savingsEditAction),
                          ),
                          PopupMenuItem<_GoalAction>(
                            value: _GoalAction.archive,
                            enabled: !goal.isArchived,
                            child: Text(strings.savingsArchiveAction),
                          ),
                        ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: percentValue,
                  minHeight: 6,
                  backgroundColor: cardColors.onBackground.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    cardColors.onBackground,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '$currentLabel / $targetLabel',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cardColors.onBackground,
                    ),
                  ),
                  Text(
                    percentLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cardColors.onBackground,
                    ),
                  ),
                ],
              ),
              if (goal.note != null && goal.note!.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  goal.note!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cardColors.muted,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      strings.savingsRemainingLabel(remainingLabel),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cardColors.muted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: onContribute,
                    style: FilledButton.styleFrom(
                      backgroundColor: cardColors.onBackground,
                      foregroundColor: cardColors.background,
                    ),
                    icon: const Icon(Icons.savings_outlined),
                    label: Text(strings.savingsContributeAction),
                  ),
                ],
              ),
              if (goal.isArchived) ...<Widget>[
                const SizedBox(height: 12),
                Chip(
                  label: Text(strings.savingsArchivedBadge),
                  backgroundColor: cardColors.onBackground.withOpacity(0.12),
                  labelStyle: theme.textTheme.labelSmall?.copyWith(
                    color: cardColors.onBackground,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum _GoalAction { edit, archive }

class _SavingGoalCardColors {
  const _SavingGoalCardColors({
    required this.background,
    required this.onBackground,
    required this.muted,
  });

  final Color background;
  final Color onBackground;
  final Color muted;
}

_SavingGoalCardColors _resolveCardColors(ThemeData theme, SavingGoal goal) {
  final ColorScheme colors = theme.colorScheme;
  final List<Color> palette = <Color>[
    colors.primaryContainer,
    colors.secondaryContainer,
    colors.tertiaryContainer,
  ];
  final Color base = palette[goal.id.hashCode.abs() % palette.length];
  final Color background =
      Color.lerp(base, colors.surfaceContainerLow, 0.35) ?? base;
  final Brightness brightness = ThemeData.estimateBrightnessForColor(
    background,
  );
  final Color onBackground = brightness == Brightness.dark
      ? Colors.white
      : colors.onSurface;
  final Color muted =
      brightness == Brightness.dark ? Colors.white70 : colors.onSurfaceVariant;
  return _SavingGoalCardColors(
    background: background,
    onBackground: onBackground,
    muted: muted,
  );
}
