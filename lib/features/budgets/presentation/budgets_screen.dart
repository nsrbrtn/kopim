import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/widgets/kopim_floating_action_button.dart';
import 'package:kopim/core/widgets/kopim_glass_surface.dart';
import 'package:kopim/features/app_shell/presentation/models/navigation_tab_content.dart';
import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/presentation/controllers/budgets_providers.dart';
import 'package:kopim/features/budgets/presentation/models/budget_category_spend.dart';
import 'package:kopim/features/budgets/presentation/widgets/budget_card.dart';
import 'package:kopim/features/budgets/presentation/widgets/budget_category_spending_chart_card.dart';
import 'package:kopim/features/budgets/presentation/budget_detail_screen.dart';
import 'package:kopim/features/budgets/presentation/budget_form_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  static const String routeName = '/budgets';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NavigationTabContent content = buildBudgetsTabContent(context, ref);
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

NavigationTabContent buildBudgetsTabContent(
  BuildContext context,
  WidgetRef ref,
) {
  final AppLocalizations strings = AppLocalizations.of(context)!;
  return NavigationTabContent(
    appBarBuilder: (BuildContext context, WidgetRef ref) =>
        AppBar(title: Text(strings.budgetsTitle)),
    floatingActionButtonBuilder: (BuildContext context, WidgetRef ref) {
      final ThemeData theme = Theme.of(context);
      final bool isDark = theme.brightness == Brightness.dark;
      final ColorScheme colorScheme = theme.colorScheme;
      final KopimLayout layout = context.kopimLayout;
      final double fabSize = layout.spacing.section + 64;
      return SizedBox(
        height: fabSize,
        width: fabSize,
        child: KopimGlassSurface(
          padding: const EdgeInsets.all(4),
          borderRadius: BorderRadius.circular(layout.radius.xxl),
          blurSigma: 20,
          baseOpacity: isDark ? 0.15 : 0.25,
          enableBorder: true,
          enableShadow: true,
          gradientHighlightIntensity: 1.5,
          gradientTintColor: colorScheme.secondaryContainer.withValues(
            alpha: 0.9,
          ),
          child: KopimFloatingActionButton(
            decorationColor: Colors.transparent,
            foregroundColor: colorScheme.primary,
            iconSize: layout.iconSizes.xl,
            icon: Icon(
              Icons.add,
              color: colorScheme.primary,
            ),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const BudgetFormScreen(),
                ),
              );
            },
          ),
        ),
      );
    },
    bodyBuilder: (BuildContext context, WidgetRef ref) {
      final KopimLayout layout = context.kopimLayout;
      final KopimSpacingScale spacing = layout.spacing;
      final AsyncValue<List<BudgetProgress>> budgetsAsync = ref.watch(
        budgetsWithProgressProvider,
      );
      final AsyncValue<List<BudgetCategorySpend>> categorySpendAsync = ref
          .watch(budgetCategorySpendProvider);
      final Widget content = budgetsAsync.when(
        data: (List<BudgetProgress> items) {
          if (items.isEmpty) {
            return _BudgetsEmptyState(strings: strings);
          }
          final Widget chartSection = categorySpendAsync.when(
            data: (List<BudgetCategorySpend> chartData) =>
                BudgetCategorySpendingChartCard(
                  data: chartData,
                  localeName: strings.localeName,
                  strings: strings,
                ),
            loading: () => const BudgetCategorySpendingChartSkeleton(),
            error: (Object error, StackTrace stackTrace) =>
                BudgetCategorySpendingChartError(
                  message: error.toString(),
                  strings: strings,
                ),
          );
          final List<Widget> budgetCards = <Widget>[];
          for (int index = 0; index < items.length; index++) {
            if (index > 0) {
              budgetCards.add(SizedBox(height: spacing.section));
            }
            final BudgetProgress progress = items[index];
            budgetCards.add(
              BudgetCard(
                progress: progress,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          BudgetDetailScreen(budgetId: progress.budget.id),
                    ),
                  );
                },
              ),
            );
          }
          final List<Widget> children = <Widget>[
            ...budgetCards,
            if (budgetCards.isNotEmpty) SizedBox(height: spacing.section),
            chartSection,
          ];
          return ListView(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            children: children,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) {
          return _BudgetsErrorState(
            message: error.toString(),
            strings: strings,
          );
        },
      );
      return MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: content,
        ),
      );
    },
  );
}

class _BudgetsEmptyState extends StatelessWidget {
  const _BudgetsEmptyState({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final KopimLayout layout = context.kopimLayout;
    final KopimSpacingScale spacing = layout.spacing;
    final KopimIconSizes iconSizes = layout.iconSizes;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.pie_chart_outline,
              size: iconSizes.xl,
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: spacing.section),
            Text(
              strings.budgetsEmptyTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.between),
            Text(
              strings.budgetsEmptyMessage,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetsErrorState extends StatelessWidget {
  const _BudgetsErrorState({required this.message, required this.strings});

  final String message;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final KopimLayout layout = context.kopimLayout;
    final KopimSpacingScale spacing = layout.spacing;
    final KopimIconSizes iconSizes = layout.iconSizes;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.sectionLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.warning_amber_rounded,
              size: iconSizes.lg,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: spacing.section),
            Text(
              strings.budgetsErrorTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.between),
            Text(
              message,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
