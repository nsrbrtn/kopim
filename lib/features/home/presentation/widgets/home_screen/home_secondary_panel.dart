import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kopim/core/widgets/collapsible_list/collapsible_list.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/presentation/screens/saving_goal_details_screen.dart';
import 'package:kopim/features/upcoming_payments/domain/models/upcoming_item.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/features/upcoming_payments/presentation/screens/upcoming_payments_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:kopim/features/home/presentation/widgets/home_budget_progress_card.dart';
import 'package:kopim/features/home/presentation/widgets/home_savings_overview_card.dart';
import 'package:kopim/features/home/presentation/widgets/home_upcoming_items_card.dart';
import 'home_screen_commons.dart';

class HomeSecondaryPanel extends StatelessWidget {
  const HomeSecondaryPanel({
    super.key,
    required this.dashboardPreferencesAsync,
    required this.strings,
    required this.upcomingItemsAsync,
    required this.timeService,
  });

  final AsyncValue<HomeDashboardPreferences> dashboardPreferencesAsync;
  final AppLocalizations strings;
  final AsyncValue<List<UpcomingItem>> upcomingItemsAsync;
  final TimeService timeService;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final HomeDashboardPreferences? preferences =
        dashboardPreferencesAsync.asData?.value;

    final List<Widget> children = <Widget>[];
    void addSection(Widget widget) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: 8));
      }
      children.add(widget);
    }

    if (dashboardPreferencesAsync.isLoading && preferences == null) {
      addSection(
        Card(
          color: theme.colorScheme.surfaceContainerHigh,
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }

    if (dashboardPreferencesAsync.hasError) {
      addSection(
        HomeErrorMessage(
          message: strings.homeDashboardPreferencesError(
            dashboardPreferencesAsync.error.toString(),
          ),
        ),
      );
    }

    if (preferences != null && preferences.showBudgetWidget) {
      addSection(HomeBudgetProgressCard(preferences: preferences));
    }

    if (preferences?.showSavingsWidget ?? false) {
      addSection(
        HomeSavingsOverviewCard(
          onOpenGoal: (SavingGoal goal) {
            Navigator.of(context).push(SavingGoalDetailsScreen.route(goal.id));
          },
        ),
      );
    }

    if (preferences?.showRecurringWidget ?? false) {
      addSection(
        upcomingItemsAsync.when(
          data: (List<UpcomingItem> items) => HomeUpcomingItemsCard(
            items: items,
            strings: strings,
            timeService: timeService,
            onMore: () {
              context.push(UpcomingPaymentsScreen.routeName);
            },
          ),
          loading: () => Card(
            color: theme.colorScheme.surfaceContainerHigh,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (Object error, _) => HomeErrorMessage(
            message: strings.homeUpcomingPaymentsError(error.toString()),
          ),
        ),
      );
    }

    if (children.isEmpty) {
      addSection(
        KopimExpandableSectionPlayful(
          title: strings.settingsHomeSectionTitle,
          initiallyExpanded: true,
          child: Text(
            strings.homeBudgetWidgetEmpty,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}
