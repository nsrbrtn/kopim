import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/features/accounts/presentation/accounts_add_screen.dart';
import 'package:kopim/features/categories/presentation/screens/manage_categories_screen.dart';
import 'package:kopim/features/getting_started/domain/entities/getting_started_progress.dart';
import 'package:kopim/features/getting_started/domain/entities/getting_started_view_model.dart';
import 'package:kopim/features/getting_started/presentation/controllers/getting_started_controller.dart';
import 'package:kopim/features/profile/presentation/screens/profile_management_screen.dart';
import 'package:kopim/features/savings/presentation/screens/savings_list_screen.dart';
import 'package:kopim/features/transactions/presentation/add_transaction_screen.dart';
import 'package:kopim/features/getting_started/presentation/widgets/getting_started_celebration_dialog.dart';
import 'package:kopim/l10n/app_localizations.dart';

class GettingStartedCardHost extends ConsumerWidget {
  const GettingStartedCardHost({
    required this.onRouteRequested,
    this.forceVisible = false,
    this.allowDismiss = true,
    this.onDismiss,
    super.key,
  });

  final ValueChanged<String> onRouteRequested;
  final bool forceVisible;
  final bool allowDismiss;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<GettingStartedViewModel>>(
      gettingStartedViewModelProvider,
      (
        AsyncValue<GettingStartedViewModel>? previous,
        AsyncValue<GettingStartedViewModel> next,
      ) {
        next.whenData((GettingStartedViewModel model) {
          if (model.shouldAutoActivate) {
            unawaited(
              ref
                  .read(gettingStartedPreferencesControllerProvider.notifier)
                  .activate()
                  .catchError((Object error, StackTrace stackTrace) {
                    debugPrint(
                      'Failed to auto-activate getting started: $error',
                    );
                  }),
            );
          }
          final bool wasCompleted =
              previous?.value?.progress.isCompleted ?? false;
          final bool isCompleted = model.progress.isCompleted;
          if (isCompleted && !wasCompleted) {
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) =>
                  const GettingStartedCelebrationDialog(),
            );
          }
        });
      },
    );

    final AsyncValue<GettingStartedViewModel> viewModelAsync = ref.watch(
      gettingStartedViewModelProvider,
    );
    return viewModelAsync.when(
      data: (GettingStartedViewModel model) {
        if (!forceVisible && !model.shouldDisplayOnHome) {
          return const SizedBox.shrink();
        }
        return GettingStartedCard(
          model: model,
          allowDismiss: allowDismiss,
          onDismiss:
              onDismiss ??
              () => ref
                  .read(gettingStartedPreferencesControllerProvider.notifier)
                  .hide(),
          onStepTap: (GettingStartedStepId stepId) =>
              onRouteRequested(_routeForStep(stepId)),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (Object error, StackTrace stackTrace) => const SizedBox.shrink(),
    );
  }
}

class GettingStartedCard extends StatelessWidget {
  const GettingStartedCard({
    required this.model,
    required this.onStepTap,
    required this.onDismiss,
    this.allowDismiss = true,
    super.key,
  });

  final GettingStartedViewModel model;
  final ValueChanged<GettingStartedStepId> onStepTap;
  final VoidCallback onDismiss;
  final bool allowDismiss;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final GettingStartedStepId? currentStep = model.progress.currentStep;
    final String subtitle = model.progress.isCompleted
        ? strings.gettingStartedCompletedSubtitle
        : strings.gettingStartedSubtitle;

    return Card(
      color: colors.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        strings.gettingStartedTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (allowDismiss && !model.progress.isCompleted)
                  IconButton(
                    tooltip: strings.gettingStartedHideAction,
                    onPressed: onDismiss,
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              strings.gettingStartedProgressLabel(
                model.progress.completedStepsCount,
                model.progress.totalStepsCount,
              ),
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _ProgressBar(
              value: model.progress.totalStepsCount > 0
                  ? model.progress.completedStepsCount /
                        model.progress.totalStepsCount
                  : 0.0,
            ),
            const SizedBox(height: 16),
            for (final GettingStartedStepId stepId
                in GettingStartedProgress.orderedSteps) ...<Widget>[
              _GettingStartedStepTile(
                title: _titleForStep(strings, stepId),
                description: _descriptionForStep(strings, stepId),
                isComplete: model.progress.isStepComplete(stepId),
                isCurrent: currentStep == stepId,
                isLocked: model.progress.isStepLocked(stepId),
                onTap: () => onStepTap(stepId),
              ),
              if (stepId != GettingStartedProgress.orderedSteps.last)
                const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _GettingStartedStepTile extends StatelessWidget {
  const _GettingStartedStepTile({
    required this.title,
    required this.description,
    required this.isComplete,
    required this.isCurrent,
    required this.isLocked,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool isComplete;
  final bool isCurrent;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool isEnabled = !isLocked;
    final Color accent = isComplete
        ? Colors.green
        : isCurrent
        ? colors.primary
        : colors.outline;
    final IconData icon = isComplete
        ? Icons.check_circle
        : isLocked
        ? Icons.lock_outline
        : Icons.radio_button_unchecked;

    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrent
              ? colors.primaryContainer.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrent ? colors.primary : colors.outlineVariant,
            width: isCurrent ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(icon, key: ValueKey<IconData>(icon), color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isEnabled
                          ? colors.onSurface
                          : colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isEnabled)
              Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

String _routeForStep(GettingStartedStepId stepId) {
  return switch (stepId) {
    GettingStartedStepId.account => AddAccountScreen.routeName,
    GettingStartedStepId.category => ManageCategoriesScreen.routeName,
    GettingStartedStepId.transaction => AddTransactionScreen.routeName,
    GettingStartedStepId.profile => ProfileManagementScreen.routeName,
    GettingStartedStepId.goal => SavingsListScreen.routeName,
  };
}

String _titleForStep(AppLocalizations strings, GettingStartedStepId stepId) {
  return switch (stepId) {
    GettingStartedStepId.account => strings.gettingStartedStepAccountTitle,
    GettingStartedStepId.category => strings.gettingStartedStepCategoryTitle,
    GettingStartedStepId.transaction =>
      strings.gettingStartedStepTransactionTitle,
    GettingStartedStepId.profile => strings.gettingStartedStepProfileTitle,
    GettingStartedStepId.goal => strings.gettingStartedStepGoalTitle,
  };
}

String _descriptionForStep(
  AppLocalizations strings,
  GettingStartedStepId stepId,
) {
  return switch (stepId) {
    GettingStartedStepId.account =>
      strings.gettingStartedStepAccountDescription,
    GettingStartedStepId.category =>
      strings.gettingStartedStepCategoryDescription,
    GettingStartedStepId.transaction =>
      strings.gettingStartedStepTransactionDescription,
    GettingStartedStepId.profile =>
      strings.gettingStartedStepProfileDescription,
    GettingStartedStepId.goal => strings.gettingStartedStepGoalDescription,
  };
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      builder: (BuildContext context, double animatedValue, Widget? child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 6,
            width: double.infinity,
            color: colors.primaryContainer.withValues(alpha: 0.3),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: animatedValue,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    colors: <Color>[colors.primary, colors.tertiary],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
