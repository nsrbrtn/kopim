import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/app_shell/presentation/models/navigation_tab_content.dart';
import 'package:kopim/features/app_shell/presentation/widgets/navigation_responsive_breakpoints.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/features/home/domain/models/day_section.dart';
import 'package:kopim/features/home/domain/models/home_account_monthly_summary.dart';
import 'package:kopim/features/home/presentation/controllers/home_dashboard_preferences_controller.dart';
import 'package:kopim/features/home/presentation/widgets/home_budget_progress_card.dart';
import 'package:kopim/features/home/presentation/widgets/home_overview_summary_card.dart';
import 'package:kopim/features/home/presentation/widgets/home_savings_overview_card.dart';
import 'package:kopim/features/home/presentation/widgets/home_upcoming_items_card.dart';
import 'package:kopim/features/getting_started/presentation/widgets/getting_started_card.dart';
import 'package:kopim/features/home/presentation/widgets/quick_add_transaction.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/feature_access_provider.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_sheet_controller.dart';
import 'package:kopim/features/transactions/presentation/screens/all_transactions_screen.dart';
import 'package:kopim/features/overview/presentation/overview_screen.dart';
import 'package:kopim/features/savings/presentation/screens/saving_goal_details_screen.dart';
import 'package:kopim/features/upcoming_payments/domain/models/upcoming_item.dart';
import 'package:kopim/features/upcoming_payments/presentation/screens/upcoming_payments_screen.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/features/upcoming_payments/domain/providers/upcoming_payments_providers.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:kopim/core/services/sync_service.dart';
import 'package:kopim/core/services/sync_status.dart';

import '../controllers/home_providers.dart';

// Extracted widgets imports
import 'package:kopim/features/home/presentation/widgets/home_screen/home_app_bar.dart';
import 'package:kopim/features/home/presentation/widgets/home_screen/home_fab.dart';
import 'package:kopim/features/home/presentation/widgets/home_screen/home_screen_commons.dart';
import 'package:kopim/features/home/presentation/widgets/home_screen/home_accounts_section.dart';
import 'package:kopim/features/home/presentation/widgets/home_screen/home_transactions_section.dart';
import 'package:kopim/features/home/presentation/widgets/home_screen/home_transactions_skeleton.dart';
import 'package:kopim/features/home/presentation/widgets/home_screen/home_secondary_panel.dart';

NavigationTabContent buildHomeTabContent(BuildContext context, WidgetRef ref) {
  final AppLocalizations strings = AppLocalizations.of(context)!;
  final AsyncValue<AuthUser?> authState = ref.watch(authControllerProvider);
  final AsyncValue<List<AccountEntity>> accountsAsync = ref.watch(
    homeAccountsProvider,
  );
  final AsyncValue<Map<String, HomeAccountMonthlySummary>>
  accountSummariesAsync = ref.watch(homeAccountMonthlySummariesProvider);
  final AsyncValue<List<DaySection>> groupedTransactionsAsync = ref.watch(
    homeGroupedTransactionsProvider,
  );
  final AsyncValue<List<UpcomingItem>> upcomingItemsAsync = ref.watch(
    homeUpcomingItemsProvider(limit: 6),
  );
  final TimeService timeService = ref.watch(timeServiceProvider);
  final AsyncValue<HomeDashboardPreferences> dashboardPreferencesAsync = ref
      .watch(homeDashboardPreferencesControllerProvider);

  return NavigationTabContent(
    bodyBuilder: (BuildContext context, WidgetRef ref) => SafeArea(
      bottom: false,
      child: _HomeBody(
        authState: authState,
        accountsAsync: accountsAsync,
        strings: strings,
        accountSummariesAsync: accountSummariesAsync,
        groupedTransactionsAsync: groupedTransactionsAsync,
        upcomingItemsAsync: upcomingItemsAsync,
        timeService: timeService,
        dashboardPreferencesAsync: dashboardPreferencesAsync,
      ),
    ),
    floatingActionButtonBuilder: (BuildContext context, WidgetRef ref) {
      final bool isTransactionSheetVisible = ref.watch(
        transactionSheetControllerProvider.select(
          (TransactionSheetState state) => state.isVisible,
        ),
      );
      if (isTransactionSheetVisible) {
        return null;
      }
      return HomeAddTransactionButton(strings: strings);
    },
    secondaryBodyBuilder: (BuildContext context, WidgetRef ref) =>
        HomeSecondaryPanel(
          dashboardPreferencesAsync: dashboardPreferencesAsync,
          strings: strings,
          upcomingItemsAsync: upcomingItemsAsync,
          timeService: timeService,
        ),
  );
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({
    required this.authState,
    required this.accountsAsync,
    required this.strings,
    required this.accountSummariesAsync,
    required this.groupedTransactionsAsync,
    required this.upcomingItemsAsync,
    required this.timeService,
    required this.dashboardPreferencesAsync,
  });

  final AsyncValue<AuthUser?> authState;
  final AsyncValue<List<AccountEntity>> accountsAsync;
  final AppLocalizations strings;
  final AsyncValue<Map<String, HomeAccountMonthlySummary>>
  accountSummariesAsync;
  final AsyncValue<List<DaySection>> groupedTransactionsAsync;
  final AsyncValue<List<UpcomingItem>> upcomingItemsAsync;
  final TimeService timeService;
  final AsyncValue<HomeDashboardPreferences> dashboardPreferencesAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return authState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(strings.homeAuthError(error.toString())),
        ),
      ),
      data: (AuthUser? user) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints _) {
            const double horizontalPadding = 8;
            final HomeDashboardPreferences? dashboardPreferences =
                dashboardPreferencesAsync.asData?.value;
            final ThemeData theme = Theme.of(context);
            final List<Widget> slivers = <Widget>[];
            final bool showSecondaryPanel =
                MediaQuery.sizeOf(context).width >=
                kMainNavigationRailBreakpoint;

            slivers.add(HomeAppBar(strings: strings, userId: user?.uid));

            double nextTopPadding = 8;

            void addBoxSection(Widget child) {
              slivers.add(
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    nextTopPadding,
                    horizontalPadding,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(child: child),
                ),
              );
              nextTopPadding = 8;
            }

            addBoxSection(
              HomeOverviewSummaryCard(
                onTap: () => context.push(OverviewScreen.routeName),
              ),
            );

            addBoxSection(
              GettingStartedCardHost(
                onRouteRequested: (String routeName) {
                  context.push(routeName);
                },
              ),
            );

            const EdgeInsets accountsPadding = EdgeInsets.fromLTRB(8, 8, 8, 0);
            final Widget accountsSection = HomeAccountsSection(
              accountsAsync: accountsAsync,
              strings: strings,
              accountSummariesAsync: accountSummariesAsync,
              isWideLayout: showSecondaryPanel,
            );

            final Widget transactionsSection = groupedTransactionsAsync.when(
              data: (List<DaySection> sections) => HomeTransactionsSectionCard(
                sections: sections,
                localeName: strings.localeName,
                strings: strings,
                onSeeAll: () {
                  context.push(AllTransactionsScreen.routeName);
                },
              ),
              loading: () => const HomeTransactionsSectionLoading(),
              error: (Object error, _) => HomeTransactionsContainer(
                child: HomeErrorMessage(
                  message: strings.homeTransactionsError(error.toString()),
                ),
              ),
            );

            slivers.add(
              SliverPadding(
                padding: accountsPadding,
                sliver: SliverList(
                  delegate: SliverChildListDelegate(<Widget>[accountsSection]),
                ),
              ),
            );

            addBoxSection(QuickAddTransactionCard(strings: strings));

            if (!showSecondaryPanel && dashboardPreferencesAsync.hasError) {
              addBoxSection(
                HomeErrorMessage(
                  message: strings.homeDashboardPreferencesError(
                    dashboardPreferencesAsync.error.toString(),
                  ),
                ),
              );
            }

            if (!showSecondaryPanel &&
                dashboardPreferences != null &&
                dashboardPreferences.showBudgetWidget) {
              addBoxSection(
                HomeBudgetProgressCard(preferences: dashboardPreferences),
              );
            }

            if (!showSecondaryPanel &&
                (dashboardPreferences?.showSavingsWidget ?? false)) {
              addBoxSection(
                HomeSavingsOverviewCard(
                  onOpenGoal: (SavingGoal goal) {
                    Navigator.of(
                      context,
                    ).push(SavingGoalDetailsScreen.route(goal.id));
                  },
                ),
              );
            }

            if (!showSecondaryPanel &&
                (dashboardPreferences?.showRecurringWidget ?? false)) {
              final Widget upcomingPaymentsSection = upcomingItemsAsync.when(
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
              );
              addBoxSection(upcomingPaymentsSection);
            }
            slivers.add(
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
                sliver: SliverToBoxAdapter(child: transactionsSection),
              ),
            );
            slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 80)));

            return RefreshIndicator.adaptive(
              onRefresh: () => _handleRefresh(context, ref),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: slivers,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleRefresh(BuildContext context, WidgetRef ref) async {
    final FeatureGate cloudSyncGate = ref.read(featureAccessProvider).cloudSync;
    if (cloudSyncGate.status != FeatureAccessStatus.enabled) {
      if (!context.mounted) return;
      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Text(_cloudSyncDisabledMessage(cloudSyncGate)),
        ),
      );
      return;
    }

    final SyncService syncService = ref.read(syncServiceProvider);
    final IncrementalSyncStatus status = await syncService.triggerManualSync();
    if (!context.mounted) return;

    final String message = switch (status.result) {
      IncrementalSyncResult.success => strings.homeSyncStatusSuccessWithCount(
        status.pulledCount,
      ),
      IncrementalSyncResult.noChanges => strings.homeSyncStatusNoChanges,
      IncrementalSyncResult.pushFailed => strings.homeSyncStatusPushFailed,
      IncrementalSyncResult.offline => strings.homeSyncStatusOffline,
      IncrementalSyncResult.unauthenticated =>
        strings.homeSyncStatusAuthRequired,
      IncrementalSyncResult.alreadySyncing => strings.homeSyncStatusInProgress,
      IncrementalSyncResult.cloudSyncDisabled => _cloudSyncDisabledMessage(
        cloudSyncGate,
      ),
      IncrementalSyncResult.blockedByLocalData =>
        strings.homeSyncStatusBlockedByLocalData,
      IncrementalSyncResult.dependencyCycleDetected =>
        strings.homeSyncStatusDependencyCycle,
      IncrementalSyncResult.error =>
        status.errorMessage == 'full_sync_required'
            ? strings.homeSyncStatusFullSyncRequired
            : strings.homeSyncStatusError(status.errorMessage ?? ''),
    };

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(duration: const Duration(seconds: 3), content: Text(message)),
    );
  }

  String _cloudSyncDisabledMessage(FeatureGate cloudSyncGate) {
    return switch (cloudSyncGate.status) {
      FeatureAccessStatus.disabledByBuild =>
        strings.homeSyncStatusDisabledByBuild,
      FeatureAccessStatus.requiresEntitlement =>
        strings.homeSyncStatusRequiresEntitlement,
      FeatureAccessStatus.requiresSignIn =>
        strings.homeSyncStatusRequiresSignIn,
      FeatureAccessStatus.blockedByLocalData =>
        strings.homeSyncStatusBlockedByLocalDataFeature,
      FeatureAccessStatus.unavailable => strings.homeSyncStatusUnavailable,
      FeatureAccessStatus.enabled =>
        strings.homeSyncStatusTemporarilyUnavailable,
    };
  }
}
