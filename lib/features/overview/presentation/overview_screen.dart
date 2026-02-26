import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/overview/domain/entities/overview_preferences.dart';
import 'package:kopim/features/overview/domain/models/financial_index_models.dart';
import 'package:kopim/features/overview/domain/models/overview_daily_allowance.dart';
import 'package:kopim/features/overview/presentation/controllers/overview_financial_index_providers.dart';
import 'package:kopim/features/overview/presentation/controllers/overview_preferences_controller.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/providers/upcoming_payments_providers.dart';
import 'package:kopim/features/upcoming_payments/domain/services/schedule_policy.dart';
import 'package:kopim/l10n/app_localizations.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  static const String routeName = '/overview';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _FinancialIndexCard(colors: colors, theme: theme),
                    const SizedBox(height: 8),
                    _BalanceCard(colors: colors, theme: theme),
                    const SizedBox(height: 16),
                    _SafetyPillowCard(colors: colors, theme: theme),
                    const SizedBox(height: 16),
                    _BehaviorProgressCard(colors: colors, theme: theme),
                    const SizedBox(height: 16),
                    _GoalCard(colors: colors, theme: theme),
                    const SizedBox(height: 16),
                    _InsightCard(colors: colors, theme: theme),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}

class _FinancialIndexCard extends ConsumerWidget {
  const _FinancialIndexCard({required this.colors, required this.theme});

  final ColorScheme colors;
  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<FinancialIndexSeries> seriesAsync = ref.watch(
      overviewFinancialIndexSeriesProvider,
    );
    final FinancialIndexSnapshot snapshot =
        seriesAsync.value?.current ??
        const FinancialIndexSnapshot(
          totalScore: 74,
          status: FinancialIndexStatus.stable,
          factors: FinancialIndexFactors(
            budgetScore: 74,
            safetyScore: 74,
            dynamicsScore: 74,
            disciplineScore: 74,
          ),
        );
    final List<FinancialIndexMonthlyPoint> resolvedMonthlyPoints =
        seriesAsync.value?.monthly ?? const <FinancialIndexMonthlyPoint>[];
    final List<FinancialIndexMonthlyPoint> monthlyPoints =
        resolvedMonthlyPoints.isEmpty
        ? _fallbackMonthlyPoints()
        : resolvedMonthlyPoints;
    final List<int> monthlyScores = monthlyPoints
        .map((FinancialIndexMonthlyPoint point) => point.score)
        .toList(growable: false);
    final int maxScore = monthlyScores.fold<int>(
      1,
      (int previous, int next) => next > previous ? next : previous,
    );
    final int currentScore = snapshot.totalScore;
    final Color zoneColor = _zoneColorForScore(currentScore, colors);
    final Color chartColor = colors.primary;
    final String statusText = _statusText(snapshot.status, strings);
    final int? previousScore = monthlyScores.length > 1
        ? monthlyScores[monthlyScores.length - 2]
        : null;
    final int monthDelta = previousScore == null
        ? 0
        : currentScore - previousScore;
    final bool isGrowth = monthDelta >= 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  strings.overviewFinancialIndexTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _showFinancialIndexInfo(context, strings),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.help_outline_outlined,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: '$currentScore',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    TextSpan(
                      text: '/100',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colors.surfaceContainerHighest,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                statusText,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 58,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List<Widget>.generate(monthlyScores.length, (
                int index,
              ) {
                final int score = monthlyScores[index];
                final bool isCurrent = index == monthlyScores.length - 1;
                final double normalized = score / 100;
                final double relative = maxScore <= 0 ? 0 : score / maxScore;
                final double heightFactor = (0.18 + normalized * 0.82).clamp(
                  0.18,
                  1.0,
                );
                final Color barColor = isCurrent
                    ? chartColor
                    : chartColor.withValues(alpha: 0.32 + relative * 0.28);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.bottomCenter,
                        children: <Widget>[
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest.withValues(
                                alpha: 0.18,
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(3),
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: heightFactor,
                                widthFactor: 1,
                                alignment: Alignment.bottomCenter,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: barColor,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(3),
                                    ),
                                  ),
                                  child: const SizedBox.expand(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: zoneColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  isGrowth ? Icons.trending_up : Icons.trending_down,
                  size: 12,
                  color: zoneColor,
                ),
                const SizedBox(width: 8),
                Text(
                  strings.overviewFinancialIndexMonthScoreChip(currentScore),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: zoneColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<FinancialIndexMonthlyPoint> _fallbackMonthlyPoints() {
  final DateTime now = DateTime.now();
  const List<int> scores = <int>[49, 57, 56, 66, 74, 68, 74];
  return List<FinancialIndexMonthlyPoint>.generate(scores.length, (int index) {
    final int monthOffset = scores.length - 1 - index;
    return FinancialIndexMonthlyPoint(
      month: DateTime(now.year, now.month - monthOffset),
      score: scores[index],
    );
  }, growable: false);
}

Color _zoneColorForScore(int score, ColorScheme colors) {
  if (score < 40) {
    return colors.error;
  }
  if (score < 70) {
    return colors.tertiary;
  }
  return colors.primary;
}

String _statusText(FinancialIndexStatus status, AppLocalizations strings) {
  switch (status) {
    case FinancialIndexStatus.financialRisk:
      return strings.overviewFinancialIndexStatusRisk;
    case FinancialIndexStatus.unstable:
      return strings.overviewFinancialIndexStatusUnstable;
    case FinancialIndexStatus.stable:
      return strings.overviewFinancialIndexStatusStable;
    case FinancialIndexStatus.confidentGrowth:
      return strings.overviewFinancialIndexStatusGrowth;
  }
}

void _showFinancialIndexInfo(BuildContext context, AppLocalizations strings) {
  final ThemeData theme = Theme.of(context);
  final ColorScheme colors = theme.colorScheme;
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: colors.surface,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              strings.overviewFinancialIndexInfoTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              strings.overviewFinancialIndexInfoBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(strings.analyticsDialogClose),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _BalanceCard extends ConsumerWidget {
  const _BalanceCard({required this.colors, required this.theme});

  final ColorScheme colors;
  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<OverviewDailyAllowance> allowanceAsync = ref.watch(
      overviewDailyAllowanceProvider,
    );
    final OverviewDailyAllowance? allowance = allowanceAsync.maybeWhen(
      data: (OverviewDailyAllowance value) => value,
      orElse: () => null,
    );
    final bool hasAllowance = allowance != null;
    final Money dailyMoney = Money(
      minor: allowance?.dailyAllowance.minor.abs() ?? BigInt.zero,
      currency: 'XXX',
      scale: allowance?.dailyAllowance.scale ?? 2,
    );
    final String dailyAmount = dailyMoney.toDecimalString();
    final String dailyPrefix =
        hasAllowance && allowance.dailyAllowance.minor < BigInt.zero ? '-' : '';
    final String horizonLabel = hasAllowance
        ? (allowance.hasIncomeAnchor
              ? strings.overviewBalanceIncomeInDaysValue(allowance.daysLeft)
              : strings.overviewBalanceHorizonInDaysValue(allowance.daysLeft))
        : '';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                strings.overviewBalanceTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colors.onSurface,
                ),
              ),
              const Spacer(),
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showBalanceAnchorPicker(context, ref, strings),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.settings,
                      color: colors.surfaceContainerHighest,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: hasAllowance ? '$dailyPrefix$dailyAmount' : '--',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                TextSpan(
                  text: strings.overviewBalanceDailySuffix,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 13,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9999),
              gradient: LinearGradient(
                colors: <Color>[
                  colors.primary,
                  colors.surfaceContainerHigh,
                  colors.surfaceContainerHighest,
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (horizonLabel.isNotEmpty)
            Text(
              horizonLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> _showBalanceAnchorPicker(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations strings,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) {
      return _BalanceAnchorPickerSheet(strings: strings);
    },
  );
}

class _BalanceAnchorPickerSheet extends ConsumerWidget {
  const _BalanceAnchorPickerSheet({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<UpcomingPayment>> paymentsAsync = ref.watch(
      watchUpcomingPaymentsProvider,
    );
    final String? selectedPaymentId = ref
        .watch(overviewPreferencesControllerProvider)
        .maybeWhen(
          data: (OverviewPreferences value) =>
              value.balanceAnchorUpcomingPaymentId,
          orElse: () => null,
        );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              strings.overviewBalanceAnchorSettingsTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: () async {
                await ref
                    .read(overviewPreferencesControllerProvider.notifier)
                    .setBalanceAnchorUpcomingPaymentId(null);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              title: Text(strings.overviewBalanceAnchorAutoOption),
              trailing: selectedPaymentId == null
                  ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
                  : null,
            ),
            paymentsAsync.when(
              data: (List<UpcomingPayment> payments) {
                final DateTime now = DateTime.now();
                final DateFormat dateFormat = DateFormat.MMMd(
                  strings.localeName,
                );
                final List<UpcomingPayment> incomes = payments
                    .where(
                      (UpcomingPayment payment) =>
                          payment.isActive &&
                          payment.flowType == UpcomingPaymentFlowType.income,
                    )
                    .toList(growable: false);
                if (incomes.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      strings.overviewBalanceAnchorEmptyIncomes,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return Column(
                  children: incomes
                      .map((UpcomingPayment payment) {
                        final DateTime nextRun = const SchedulePolicy()
                            .computeNextRunLocal(
                              fromLocal: now,
                              dayOfMonth: payment.dayOfMonth,
                            );
                        final String subtitle = dateFormat.format(nextRun);
                        final bool isSelected = selectedPaymentId == payment.id;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          onTap: () async {
                            await ref
                                .read(
                                  overviewPreferencesControllerProvider
                                      .notifier,
                                )
                                .setBalanceAnchorUpcomingPaymentId(payment.id);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          title: Text(payment.title),
                          subtitle: Text(subtitle),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_rounded,
                                  color: theme.colorScheme.primary,
                                )
                              : null,
                        );
                      })
                      .toList(growable: false),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (Object error, StackTrace stackTrace) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  strings.upcomingPaymentsListError(error.toString()),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetyPillowCard extends StatelessWidget {
  const _SafetyPillowCard({required this.colors, required this.theme});

  final ColorScheme colors;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    return _MetricCard(
      colors: colors,
      theme: theme,
      icon: Icons.shield_outlined,
      iconColor: colors.inversePrimary,
      iconBackground: colors.inversePrimary.withValues(alpha: 0.10),
      title: strings.overviewSafetyPillowTitle,
      subtitle: strings.overviewSafetyPillowSubtitle,
      value: null,
      progress: 0.74,
      progressColor: colors.inversePrimary,
      progressTrackColor: colors.surfaceContainerHighest.withValues(
        alpha: 0.25,
      ),
    );
  }
}

class _BehaviorProgressCard extends StatelessWidget {
  const _BehaviorProgressCard({required this.colors, required this.theme});

  final ColorScheme colors;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    return _MetricCard(
      colors: colors,
      theme: theme,
      icon: Icons.local_fire_department_outlined,
      iconColor: colors.error,
      iconBackground: colors.error.withValues(alpha: 0.12),
      title: strings.overviewBehaviorProgressTitle,
      subtitle: strings.overviewBehaviorProgressSubtitle,
      value: strings.overviewBehaviorProgressValue,
      valueColor: colors.error,
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.colors,
    required this.theme,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    this.value,
    this.valueColor,
    this.progress,
    this.progressColor,
    this.progressTrackColor,
  });

  final ColorScheme colors;
  final ThemeData theme;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final String? value;
  final Color? valueColor;
  final double? progress;
  final Color? progressColor;
  final Color? progressTrackColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    if (value == null)
                      Text(
                        subtitle,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.outline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                if (value != null)
                  Text(
                    subtitle,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.outline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (progress != null) ...<Widget>[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9999),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: progress,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progressColor ?? colors.primary,
                      ),
                      backgroundColor:
                          progressTrackColor ?? colors.surfaceContainerHighest,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (value != null) ...<Widget>[
            const SizedBox(width: 12),
            Text(
              value!,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: valueColor ?? colors.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.colors, required this.theme});

  final ColorScheme colors;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: 0.9),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.flight_takeoff_rounded,
                  color: colors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      strings.overviewGoalTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9999),
                            child: LinearProgressIndicator(
                              value: 0.68,
                              minHeight: 6,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colors.primary,
                              ),
                              backgroundColor: colors.secondaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          strings.overviewGoalProgressPercent,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.primary.withValues(alpha: 0.12)),
            ),
            child: Text(
              strings.overviewGoalInsight,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.colors, required this.theme});

  final ColorScheme colors;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: <Color>[
            colors.tertiary.withValues(alpha: 0.45),
            colors.tertiary.withValues(alpha: 0.65),
          ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -6,
            bottom: -8,
            child: Icon(
              Icons.auto_awesome,
              size: 90,
              color: colors.onSurface.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 14,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    strings.overviewInsightDayLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                strings.overviewInsightBody,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
