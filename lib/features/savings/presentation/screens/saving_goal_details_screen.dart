import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/presentation/utils/category_gradients.dart';
import 'package:kopim/features/categories/presentation/widgets/category_chip.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/models/saving_goal_analytics.dart';
import 'package:kopim/features/savings/domain/models/saving_goal_category_breakdown.dart';
import 'package:kopim/features/savings/domain/value_objects/goal_progress.dart';
import 'package:kopim/features/savings/presentation/controllers/saving_goal_details_providers.dart';
import 'package:kopim/features/savings/presentation/controllers/saving_goals_controller.dart';
import 'package:kopim/features/savings/presentation/controllers/saving_goals_state.dart';
import 'package:kopim/features/savings/presentation/screens/add_edit_goal_screen.dart';
import 'package:kopim/features/analytics/presentation/widgets/analytics_chart.dart';
import 'package:kopim/l10n/app_localizations.dart';

class SavingGoalDetailsScreen extends ConsumerWidget {
  const SavingGoalDetailsScreen({required this.goalId, super.key});

  final String goalId;

  static Route<void> route(String goalId) {
    return MaterialPageRoute<void>(
      builder: (BuildContext context) =>
          SavingGoalDetailsScreen(goalId: goalId),
      settings: RouteSettings(name: 'saving-goal/$goalId'),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final SavingGoal? goal = ref.watch(savingGoalByIdProvider(goalId));
    final bool isLoading = ref.watch(
      savingGoalsControllerProvider.select(
        (SavingGoalsState state) => state.isLoading,
      ),
    );
    final String? error = ref.watch(
      savingGoalsControllerProvider.select(
        (SavingGoalsState state) => state.error,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(goal?.name ?? strings.savingsGoalDetailsTitle),
        actions: <Widget>[
          if (goal != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: strings.savingsGoalDetailsEditTooltip,
              onPressed: () {
                Navigator.of(context).push(AddEditGoalScreen.route(goal: goal));
              },
            ),
        ],
      ),
      body: Builder(
        builder: (BuildContext context) {
          if (goal == null) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (error != null) {
              return _GoalDetailsError(message: strings.genericErrorMessage);
            }
            return _GoalDetailsError(
              message: strings.savingsGoalDetailsNotFound,
            );
          }
          return _GoalDetailsContent(goal: goal);
        },
      ),
    );
  }
}

class _GoalDetailsContent extends ConsumerWidget {
  const _GoalDetailsContent({required this.goal});

  final SavingGoal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final GoalProgress progress = GoalProgress.fromGoal(goal);
    final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
      locale: strings.localeName,
    );

    final AsyncValue<SavingGoalAnalytics> analyticsAsync = ref.watch(
      savingGoalAnalyticsProvider(goal.id),
    );
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      savingGoalCategoriesProvider,
    );

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(savingGoalsControllerProvider.notifier).refresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            sliver: SliverToBoxAdapter(
              child: _GoalSummaryCard(
                progress: progress,
                currencyFormat: currencyFormat,
                strings: strings,
                analyticsAsync: analyticsAsync,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverToBoxAdapter(
              child: _GoalAnalyticsCard(
                goal: goal,
                analyticsAsync: analyticsAsync,
                categoriesAsync: categoriesAsync,
                currencyFormat: currencyFormat,
                strings: strings,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalSummaryCard extends StatelessWidget {
  const _GoalSummaryCard({
    required this.progress,
    required this.currencyFormat,
    required this.strings,
    required this.analyticsAsync,
  });

  final GoalProgress progress;
  final NumberFormat currencyFormat;
  final AppLocalizations strings;
  final AsyncValue<SavingGoalAnalytics> analyticsAsync;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double percent = progress.percent.clamp(0, 1);
    final String currentLabel = currencyFormat.format(
      progress.goal.currentAmount / 100,
    );
    final String targetLabel = currencyFormat.format(
      progress.goal.targetAmount / 100,
    );
    final String remainingLabel = currencyFormat.format(
      progress.remaining.minorUnits / 100,
    );

    final SavingGoalAnalytics? analytics = analyticsAsync.value;
    final DateTime? lastContribution = analytics?.lastContributionAt;
    final int transactionsCount = analytics?.transactionCount ?? 0;
    final DateFormat? dateFormat = lastContribution == null
        ? null
        : DateFormat.yMMMMd(strings.localeName);
    final String lastContributionLabel = lastContribution == null
        ? strings.savingsGoalDetailsNoContributions
        : strings.savingsGoalDetailsLastContribution(
            dateFormat!.format(lastContribution),
          );
    final String transactionsLabel = strings
        .savingsGoalDetailsTransactionsCount(transactionsCount);

    return Card(
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              strings.savingsGoalDetailsSummaryTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: percent),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: _SummaryValue(
                    label: strings.savingsGoalDetailsCurrentLabel(currentLabel),
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryValue(
                    label: strings.savingsGoalDetailsTargetLabel(targetLabel),
                    theme: theme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              strings.savingsRemainingLabel(remainingLabel),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(lastContributionLabel, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              transactionsLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (progress.goal.note != null && progress.goal.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  progress.goal.note!,
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GoalAnalyticsCard extends StatelessWidget {
  const _GoalAnalyticsCard({
    required this.goal,
    required this.analyticsAsync,
    required this.categoriesAsync,
    required this.currencyFormat,
    required this.strings,
  });

  final SavingGoal goal;
  final AsyncValue<SavingGoalAnalytics> analyticsAsync;
  final AsyncValue<List<Category>> categoriesAsync;
  final NumberFormat currencyFormat;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: analyticsAsync.when(
          data: (SavingGoalAnalytics data) {
            if (data.transactionCount == 0 || data.totalAmount <= 0) {
              return _GoalAnalyticsEmpty(strings: strings);
            }

            final List<Category> categories =
                categoriesAsync.value ?? const <Category>[];
            final Map<String, Category> categoriesById = <String, Category>{
              for (final Category category in categories) category.id: category,
            };

            final List<AnalyticsChartItem> items = data.categoryBreakdown
                .map<AnalyticsChartItem>((
                  SavingGoalCategoryBreakdown savingBreakdown,
                ) {
                  final Category? category = savingBreakdown.categoryId == null
                      ? null
                      : categoriesById[savingBreakdown.categoryId!];
                  final Color resolvedColor =
                      resolveCategoryColorStyle(category?.color).sampleColor ??
                      theme.colorScheme.primary;
                  final IconData? iconData = resolvePhosphorIconData(
                    category?.icon,
                  );
                  final String title =
                      category?.name ?? strings.analyticsCategoryUncategorized;
                  final String key =
                      savingBreakdown.categoryId ?? '_uncategorized';
                  return AnalyticsChartItem(
                    key: '$key-${goal.id}',
                    title: title,
                    amount: savingBreakdown.amount,
                    color: resolvedColor,
                    icon: iconData,
                  );
                })
                .toList(growable: false);

            final String totalLabel = currencyFormat.format(data.totalAmount);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  strings.savingsGoalDetailsAnalyticsTitle,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 240,
                  child: AnalyticsDonutChart(
                    items: items,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    totalAmount: data.totalAmount,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  strings.savingsGoalDetailsAnalyticsTotal(totalLabel),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: items
                      .map((AnalyticsChartItem item) {
                        final double percentage = data.totalAmount <= 0
                            ? 0
                            : item.absoluteAmount / data.totalAmount * 100;
                        final String percentLabel = percentage >= 1
                            ? '${percentage.round()}%'
                            : '${percentage.toStringAsFixed(1)}%';
                        return Tooltip(
                          message: currencyFormat.format(item.absoluteAmount),
                          waitDuration: const Duration(milliseconds: 400),
                          child: CategoryChip(
                            label: item.title,
                            backgroundColor: item.color.withValues(alpha: 0.16),
                            leading: item.icon == null
                                ? null
                                : Icon(item.icon, size: 16),
                            trailing: Text(
                              percentLabel,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      })
                      .toList(growable: false),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) =>
              _GoalDetailsError(message: strings.genericErrorMessage),
        ),
      ),
    );
  }
}

class _GoalDetailsError extends StatelessWidget {
  const _GoalDetailsError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _GoalAnalyticsEmpty extends StatelessWidget {
  const _GoalAnalyticsEmpty({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          strings.savingsGoalDetailsAnalyticsTitle,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Text(
          strings.savingsGoalDetailsAnalyticsEmpty,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.theme});

  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
