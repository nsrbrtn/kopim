import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/widgets/kopim_floating_action_button.dart';
import 'package:kopim/features/app_shell/presentation/models/navigation_tab_content.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/value_objects/goal_progress.dart';
import 'package:kopim/features/savings/presentation/controllers/saving_goals_controller.dart';
import 'package:kopim/features/savings/presentation/controllers/saving_goals_providers.dart';
import 'package:kopim/features/savings/presentation/controllers/saving_goals_state.dart';
import 'package:kopim/features/savings/presentation/screens/add_edit_goal_screen.dart';
import 'package:kopim/features/savings/presentation/screens/contribute_screen.dart';
import 'package:kopim/features/savings/presentation/screens/saving_goal_details_screen.dart';
import 'package:kopim/features/savings/presentation/widgets/saving_goal_card.dart';
import 'package:kopim/l10n/app_localizations.dart';

class SavingsListScreen extends ConsumerWidget {
  const SavingsListScreen({super.key});

  static const String routeName = '/savings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NavigationTabContent content = buildSavingsTabContent(context, ref);
    return Scaffold(
      appBar: content.appBarBuilder?.call(context, ref),
      body: content.bodyBuilder(context, ref),
      floatingActionButton: content.floatingActionButtonBuilder?.call(
        context,
        ref,
      ),
    );
  }
}

NavigationTabContent buildSavingsTabContent(
  BuildContext context,
  WidgetRef ref,
) {
  final AppLocalizations strings = AppLocalizations.of(context)!;
  return NavigationTabContent(
    appBarBuilder: (BuildContext context, WidgetRef ref) =>
        AppBar(title: Text(strings.savingsTitle)),
    floatingActionButtonBuilder: (BuildContext context, WidgetRef ref) {
      return KopimFloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(AddEditGoalScreen.route());
        },
        icon: const Icon(Icons.add),
      );
    },
    bodyBuilder: (BuildContext context, WidgetRef ref) => const _SavingsBody(),
  );
}

class _SavingsBody extends ConsumerStatefulWidget {
  const _SavingsBody();

  @override
  ConsumerState<_SavingsBody> createState() => _SavingsBodyState();
}

class _SavingsBodyState extends ConsumerState<_SavingsBody> {
  Future<void> _archiveGoal(SavingGoal goal) async {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(savingGoalsControllerProvider.notifier)
          .archiveGoal(goal.id);
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(content: Text(strings.savingsGoalArchivedMessage(goal.name))),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(content: Text(strings.genericErrorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final SavingGoalsState state = ref.watch(savingGoalsControllerProvider);
    final List<SavingGoal> goals = ref.watch(goalsStreamProvider);
    final bool isLoading = ref.watch(
      savingGoalsControllerProvider.select(
        (SavingGoalsState value) => value.isLoading,
      ),
    );
    final String? error = ref.watch(
      savingGoalsControllerProvider.select(
        (SavingGoalsState value) => value.error,
      ),
    );
    final bool showArchived = state.showArchived;

    if (isLoading && goals.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null && goals.isEmpty) {
      return _SavingsErrorState(
        message: error,
        onRetry: () =>
            ref.read(savingGoalsControllerProvider.notifier).refresh(),
      );
    }
    if (goals.isEmpty) {
      return _SavingsEmptyState(
        onCreate: () {
          Navigator.of(context).push(AddEditGoalScreen.route());
        },
      );
    }
    final List<GoalProgress> progressList = goals
        .map(GoalProgress.fromGoal)
        .toList(growable: false);
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(savingGoalsControllerProvider.notifier).refresh(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: progressList.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _FilterRow(
              showArchived: showArchived,
              onChanged: (bool value) => ref
                  .read(savingGoalsControllerProvider.notifier)
                  .toggleShowArchived(value),
            );
          }
          final GoalProgress progress = progressList[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SavingGoalCard(
              goal: progress.goal,
              progress: progress,
              onContribute: () {
                Navigator.of(
                  context,
                ).push(ContributeScreen.route(progress.goal));
              },
              onEdit: () {
                Navigator.of(
                  context,
                ).push(AddEditGoalScreen.route(goal: progress.goal));
              },
              onArchive: () => unawaited(_archiveGoal(progress.goal)),
              onOpen: () {
                Navigator.of(
                  context,
                ).push(SavingGoalDetailsScreen.route(progress.goal.id));
              },
            ),
          );
        },
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.showArchived, required this.onChanged});

  final bool showArchived;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    return SwitchListTile.adaptive(
      value: showArchived,
      onChanged: onChanged,
      title: Text(strings.savingsShowArchivedToggle),
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _SavingsEmptyState extends StatelessWidget {
  const _SavingsEmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.savings_outlined,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              strings.savingsEmptyTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              strings.savingsEmptyMessage,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onCreate,
              child: Text(strings.savingsAddGoalButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavingsErrorState extends StatelessWidget {
  const _SavingsErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              strings.savingsErrorTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(strings.savingsRetryButton),
            ),
          ],
        ),
      ),
    );
  }
}
