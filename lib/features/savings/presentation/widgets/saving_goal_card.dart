import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  });

  final SavingGoal goal;
  final GoalProgress progress;
  final VoidCallback onContribute;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations strings = AppLocalizations.of(context)!;
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

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(goal.name, style: theme.textTheme.titleMedium),
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
            LinearProgressIndicator(value: percentValue),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '$currentLabel / $targetLabel',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(percentLabel, style: theme.textTheme.bodyMedium),
              ],
            ),
            if (goal.note != null && goal.note!.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(goal.note!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    strings.savingsRemainingLabel(remainingLabel),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: onContribute,
                  icon: const Icon(Icons.savings_outlined),
                  label: Text(strings.savingsContributeAction),
                ),
              ],
            ),
            if (goal.isArchived) ...<Widget>[
              const SizedBox(height: 12),
              Chip(label: Text(strings.savingsArchivedBadge)),
            ],
          ],
        ),
      ),
    );
  }
}

enum _GoalAction { edit, archive }
