import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:kopim/core/formatting/currency_symbols.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/models/saving_goal_analytics.dart';
import 'package:kopim/features/savings/domain/value_objects/goal_progress.dart';
import 'package:kopim/features/savings/presentation/controllers/saving_goal_details_providers.dart';
import 'package:kopim/features/savings/presentation/controllers/saving_goals_controller.dart';
import 'package:kopim/features/savings/presentation/controllers/saving_goals_state.dart';
import 'package:kopim/features/savings/presentation/screens/add_edit_goal_screen.dart';
import 'package:kopim/features/savings/presentation/screens/contribute_screen.dart';
import 'package:kopim/features/profile/presentation/controllers/active_currency_code_provider.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_editor.dart';
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
        centerTitle: false,
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
          return SafeArea(child: _GoalDetailsContent(goal: goal));
        },
      ),
      floatingActionButton: goal != null
          ? _GoalPrimaryAction(
              label: strings.savingsContributeAction,
              onPressed: () {
                Navigator.of(context).push(ContributeScreen.route(goal));
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
    final String currencyCode = ref.watch(activeCurrencyCodeProvider);
    final NumberFormat currencyFormat = resolveCurrencyFormat(
      locale: strings.localeName,
      currencyCode: currencyCode,
    );

    final AsyncValue<SavingGoalAnalytics> analyticsAsync = ref.watch(
      savingGoalAnalyticsProvider(goal.id),
    );
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(savingGoalsControllerProvider.notifier).refresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            sliver: SliverToBoxAdapter(
              child: _GoalForecastCard(
                goalId: goal.id,
                currencyFormat: currencyFormat,
                strings: strings,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            sliver: SliverToBoxAdapter(
              child: _GoalAccountsCard(goalId: goal.id),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            sliver: SliverToBoxAdapter(
              child: _GoalAnalyticsCard(
                goal: goal,
                currencyFormat: currencyFormat,
                strings: strings,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 132),
            sliver: SliverToBoxAdapter(
              child: _GoalTransactionsCard(goalId: goal.id),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalSummaryCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
    final DateFormat? dateFormat = lastContribution == null
        ? null
        : DateFormat.yMMMMd(strings.localeName);
    final String lastContributionLabel = lastContribution == null
        ? strings.savingsGoalDetailsNoContributions
        : strings.savingsGoalDetailsLastContribution(
            dateFormat!.format(lastContribution),
          );

    return _GoalSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            strings.savingsGoalDetailsSummaryTitle,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 12,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool useColumn = constraints.maxWidth < 520;
              final Widget currentTile = _SummaryMetricTile(
                icon: Icons.account_balance_wallet_outlined,
                title: strings.savingsGoalDetailsCurrentLabel(''),
                value: currentLabel,
              );
              final Widget targetTile = _SummaryMetricTile(
                icon: Icons.track_changes_outlined,
                title: strings.savingsGoalDetailsTargetLabel(''),
                value: targetLabel,
              );

              if (useColumn) {
                return Column(
                  children: <Widget>[
                    currentTile,
                    const SizedBox(height: 12),
                    targetTile,
                  ],
                );
              }

              return Row(
                children: <Widget>[
                  Expanded(child: currentTile),
                  const SizedBox(width: 12),
                  Expanded(child: targetTile),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          _SummaryFactLine(
            icon: Icons.timelapse_outlined,
            text: strings.savingsRemainingLabel(remainingLabel),
            textStyle: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          _SummaryFactLine(
            icon: Icons.calendar_today_outlined,
            text: lastContributionLabel,
            textStyle: theme.textTheme.bodyMedium,
          ),
          if (progress.goal.note != null &&
              progress.goal.note!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            Text(
              progress.goal.note!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GoalForecastCard extends ConsumerWidget {
  const _GoalForecastCard({
    required this.goalId,
    required this.currencyFormat,
    required this.strings,
  });

  final String goalId;
  final NumberFormat currencyFormat;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SavingGoalForecast? forecast = ref.watch(
      savingGoalForecastProvider(goalId),
    );
    if (forecast == null) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final String avgLabel = currencyFormat.format(
      forecast.averageMonthlyContribution,
    );

    String dateLabel;
    if (forecast.estimatedCompletionDate != null) {
      final DateFormat dateFormat = DateFormat.yMMMM(strings.localeName);
      dateLabel = strings.savingsGoalDetailsEstimatedDate(
        dateFormat.format(forecast.estimatedCompletionDate!),
      );
    } else {
      dateLabel = strings.savingsGoalDetailsEstimatedNever;
    }

    String recLabel;
    if (forecast.recommendedMonthlyContribution > 0) {
      recLabel = strings.savingsGoalDetailsRecommendedContribution(
        currencyFormat.format(forecast.recommendedMonthlyContribution),
      );
    } else {
      recLabel = strings.savingsGoalDetailsRecommendedNoTarget;
    }

    final Color accentColor = forecast.estimatedCompletionDate == null
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    return _GoalSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            strings.savingsGoalDetailsForecastTitle,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 18),
          _ForecastLine(
            icon: Icons.flag_outlined,
            text: dateLabel,
            color: accentColor,
            textStyle: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          _ForecastLine(
            icon: Icons.show_chart_outlined,
            text: strings.savingsGoalDetailsAverageContribution(avgLabel),
            textStyle: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          _ForecastLine(
            icon: Icons.trending_up_outlined,
            text: recLabel,
            textStyle: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _GoalAnalyticsCard extends StatelessWidget {
  const _GoalAnalyticsCard({
    required this.goal,
    required this.currencyFormat,
    required this.strings,
  });

  final SavingGoal goal;
  final NumberFormat currencyFormat;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final ThemeData theme = Theme.of(context);
        final AsyncValue<List<TransactionEntity>> transactionsAsync = ref.watch(
          savingGoalTransactionsProvider(goal.id),
        );

        return _GoalSectionCard(
          child: transactionsAsync.when(
            data: (List<TransactionEntity> transactions) {
              final List<_SavingsTrendPoint> points = _buildSavingsTrendPoints(
                transactions,
              );
              final double totalContributed = transactions.fold<double>(
                0,
                (double sum, TransactionEntity tx) =>
                    sum + tx.amountValue.abs().toDouble(),
              );
              final double maxValue = points.fold<double>(
                0,
                (double prev, _SavingsTrendPoint point) =>
                    point.amount > prev ? point.amount : prev,
              );
              final double yMax = maxValue <= 0 ? 1 : maxValue * 1.12;
              final NumberFormat compactFormat = NumberFormat.compact(
                locale: strings.localeName,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    strings.assistantQuickActionSavingsLabel,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.savingsGoalDetailsAnalyticsTotal(
                      currencyFormat.format(totalContributed),
                    ),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  if (points.every(
                    (_SavingsTrendPoint point) => point.amount == 0,
                  ))
                    Text(
                      strings.savingsGoalDetailsAnalyticsEmpty,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    SizedBox(
                      height: 260,
                      child: SfCartesianChart(
                        plotAreaBorderWidth: 0,
                        margin: EdgeInsets.zero,
                        primaryXAxis: CategoryAxis(
                          majorGridLines: const MajorGridLines(width: 0),
                          axisLine: AxisLine(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.25,
                            ),
                            width: 1,
                          ),
                          labelStyle: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        primaryYAxis: NumericAxis(
                          minimum: 0,
                          maximum: yMax,
                          majorGridLines: MajorGridLines(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.2,
                            ),
                            width: 1,
                          ),
                          axisLine: const AxisLine(width: 0),
                          majorTickLines: const MajorTickLines(size: 0),
                          numberFormat: compactFormat,
                          labelStyle: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        series: <CartesianSeries<_SavingsTrendPoint, String>>[
                          AreaSeries<_SavingsTrendPoint, String>(
                            dataSource: points,
                            xValueMapper: (_SavingsTrendPoint point, _) =>
                                point.label,
                            yValueMapper: (_SavingsTrendPoint point, _) =>
                                point.amount,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                theme.colorScheme.primary.withValues(
                                  alpha: 0.32,
                                ),
                                theme.colorScheme.primary.withValues(
                                  alpha: 0.02,
                                ),
                              ],
                            ),
                            borderWidth: 0,
                            animationDuration: 0,
                          ),
                          SplineSeries<_SavingsTrendPoint, String>(
                            dataSource: points,
                            xValueMapper: (_SavingsTrendPoint point, _) =>
                                point.label,
                            yValueMapper: (_SavingsTrendPoint point, _) =>
                                point.amount,
                            color: theme.colorScheme.primary,
                            width: 3,
                            markerSettings: MarkerSettings(
                              isVisible: true,
                              width: 6,
                              height: 6,
                              color: theme.colorScheme.primary,
                            ),
                            animationDuration: 0,
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace stackTrace) =>
                _GoalDetailsError(message: strings.genericErrorMessage),
          ),
        );
      },
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

class _GoalAccountsCard extends ConsumerWidget {
  const _GoalAccountsCard({required this.goalId});

  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<List<AccountEntity>> accountsAsync = ref.watch(
      savingGoalAccountsProvider(goalId),
    );
    final String currencyCode = ref.watch(activeCurrencyCodeProvider);

    return accountsAsync.when(
      data: (List<AccountEntity> accounts) {
        if (accounts.isEmpty) {
          return const SizedBox.shrink();
        }

        final NumberFormat currencyFormat = resolveCurrencyFormat(
          locale: strings.localeName,
          currencyCode: currencyCode,
        );

        return _GoalSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                strings.savingsGoalDetailsStorageAccounts,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Column(
                children: accounts.map((AccountEntity account) {
                  final String balanceLabel = currencyFormat.format(
                    account.balanceAmount.toDouble(),
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Icon(
                          _resolveAccountIcon(account.type),
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(account.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              balanceLabel,
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) => const SizedBox.shrink(),
    );
  }

  IconData _resolveAccountIcon(String type) {
    switch (type) {
      case 'bank':
        return Icons.account_balance_outlined;
      case 'credit_card':
        return Icons.credit_card_outlined;
      case 'investment':
        return Icons.trending_up_outlined;
      default:
        return Icons.payments_outlined;
    }
  }
}

class _GoalTransactionsCard extends ConsumerWidget {
  const _GoalTransactionsCard({required this.goalId});

  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<List<TransactionEntity>> transactionsAsync = ref.watch(
      savingGoalTransactionsProvider(goalId),
    );
    final String currencyCode = ref.watch(activeCurrencyCodeProvider);

    return transactionsAsync.when(
      data: (List<TransactionEntity> transactions) {
        if (transactions.isEmpty) {
          return _GoalSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  strings.savingsGoalDetailsHistoryTitle,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  strings.savingsGoalDetailsHistoryEmpty,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        final NumberFormat currencyFormat = resolveCurrencyFormat(
          locale: strings.localeName,
          currencyCode: currencyCode,
        );
        final DateFormat dateFormat = DateFormat.yMMMMd(strings.localeName);

        final List<TransactionEntity> sortedTransactions =
            List<TransactionEntity>.from(transactions)..sort(
              (TransactionEntity a, TransactionEntity b) =>
                  b.date.compareTo(a.date),
            );

        return _GoalSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                strings.savingsGoalDetailsHistoryTitle,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedTransactions.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 10),
                itemBuilder: (BuildContext context, int index) {
                  final TransactionEntity tx = sortedTransactions[index];
                  final String amountLabel = currencyFormat.format(
                    tx.amountValue.abs().toDouble(),
                  );
                  final String dateLabel = dateFormat.format(tx.date);

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.surfaceContainer,
                          ),
                          child: Icon(
                            Icons.arrow_downward_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                tx.note != null && tx.note!.isNotEmpty
                                    ? tx.note!
                                    : strings.transactionDefaultTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dateLabel,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          amountLabel,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: theme.colorScheme.error,
                          ),
                          onPressed: () {
                            deleteTransactionWithFeedback(
                              context: context,
                              ref: ref,
                              transactionId: tx.id,
                              strings: strings,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) => const SizedBox.shrink(),
    );
  }
}

class _GoalPrimaryAction extends StatelessWidget {
  const _GoalPrimaryAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.savings_outlined),
          label: Text(label),
        ),
      ),
    );
  }
}

class _GoalSectionCard extends StatelessWidget {
  const _GoalSectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: theme.colorScheme.surfaceContainer,
      ),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }
}

class _SummaryMetricTile extends StatelessWidget {
  const _SummaryMetricTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String normalizedTitle = title
        .replaceAll(': ', '')
        .replaceAll(':', '');
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    normalizedTitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(value, style: theme.textTheme.headlineSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryFactLine extends StatelessWidget {
  const _SummaryFactLine({
    required this.icon,
    required this.text,
    this.textStyle,
  });

  final IconData icon;
  final String text;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: textStyle ?? theme.textTheme.bodyLarge),
        ),
      ],
    );
  }
}

class _ForecastLine extends StatelessWidget {
  const _ForecastLine({
    required this.icon,
    required this.text,
    this.color,
    this.textStyle,
  });

  final IconData icon;
  final String text;
  final Color? color;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color resolvedColor = color ?? theme.colorScheme.onSurface;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 22, color: resolvedColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: (textStyle ?? theme.textTheme.bodyLarge)?.copyWith(
              color: resolvedColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _SavingsTrendPoint {
  const _SavingsTrendPoint({required this.label, required this.amount});

  final String label;
  final double amount;
}

List<_SavingsTrendPoint> _buildSavingsTrendPoints(
  List<TransactionEntity> transactions,
) {
  final DateTime now = DateTime.now();
  final List<DateTime> months = List<DateTime>.generate(
    6,
    (int index) => DateTime(now.year, now.month - (5 - index)),
    growable: false,
  );
  final Map<int, double> totalsByMonth = <int, double>{
    for (final DateTime month in months) _monthKey(month): 0,
  };

  for (final TransactionEntity transaction in transactions) {
    if (transaction.savingGoalId == null || transaction.savingGoalId!.isEmpty) {
      continue;
    }
    if (parseTransactionType(transaction.type) != TransactionType.transfer) {
      continue;
    }
    final DateTime monthStart = DateTime(
      transaction.date.year,
      transaction.date.month,
    );
    final int key = _monthKey(monthStart);
    if (!totalsByMonth.containsKey(key)) {
      continue;
    }
    totalsByMonth[key] =
        totalsByMonth[key]! + transaction.amountValue.abs().toDouble();
  }

  return months
      .map(
        (DateTime month) => _SavingsTrendPoint(
          label: DateFormat.MMM().format(month),
          amount: totalsByMonth[_monthKey(month)] ?? 0,
        ),
      )
      .toList(growable: false);
}

int _monthKey(DateTime month) => month.year * 100 + month.month;
