import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/presentation/controllers/budgets_providers.dart';
import 'package:kopim/features/budgets/presentation/widgets/budget_progress_indicator.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/l10n/app_localizations.dart';

class HomeBudgetProgressCard extends ConsumerWidget {
  const HomeBudgetProgressCard({
    required this.preferences,
    required this.onConfigure,
    super.key,
  });

  final HomeDashboardPreferences preferences;
  final VoidCallback onConfigure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations strings = AppLocalizations.of(context)!;

    final String? budgetId = preferences.budgetId;
    if (budgetId == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                strings.homeBudgetWidgetTitle,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                strings.homeBudgetWidgetEmpty,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: onConfigure,
                icon: const Icon(Icons.settings_outlined),
                label: Text(strings.homeBudgetWidgetConfigureCta),
              ),
            ],
          ),
        ),
      );
    }

    final AsyncValue<BudgetProgress> progressAsync = ref.watch(
      budgetProgressByIdProvider(budgetId),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              strings.homeBudgetWidgetTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            progressAsync.when(
              data: (BudgetProgress progress) {
                final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
                  locale: strings.localeName,
                );
                final double limit = progress.budget.amount;
                final double spent = progress.spent;
                final double remaining = progress.remaining;
                final double ratio = progress.utilization.isFinite
                    ? progress.utilization.clamp(0, 2)
                    : 1.0;
                final bool exceeded = progress.isExceeded;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      progress.budget.title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    BudgetProgressIndicator(value: ratio, exceeded: exceeded),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _BudgetStat(
                          label: strings.budgetsSpentLabel,
                          value: currencyFormat.format(spent),
                        ),
                        _BudgetStat(
                          label: strings.budgetsLimitLabel,
                          value: currencyFormat.format(limit),
                        ),
                        _BudgetStat(
                          label: exceeded
                              ? strings.budgetsExceededLabel
                              : strings.budgetsRemainingLabel,
                          value: currencyFormat.format(
                            exceeded ? (spent - limit) : remaining,
                          ),
                          valueStyle: exceeded
                              ? theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              ),
              error: (Object error, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    strings.homeBudgetWidgetMissing,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: onConfigure,
                    icon: const Icon(Icons.settings_outlined),
                    label: Text(strings.homeBudgetWidgetConfigureCta),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetStat extends StatelessWidget {
  const _BudgetStat({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: valueStyle ?? theme.textTheme.bodyMedium),
      ],
    );
  }
}
