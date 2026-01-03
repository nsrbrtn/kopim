import 'dart:math' as math;
import 'dart:ui' as ui show TextDirection;

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show StreamProviderFamily;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/use_cases/add_account_use_case.dart';
import 'package:kopim/features/accounts/presentation/account_details_screen.dart';
import 'package:kopim/features/accounts/presentation/accounts_add_screen.dart';
import 'package:kopim/features/accounts/presentation/utils/account_card_gradients.dart';
import 'package:kopim/features/app_shell/presentation/models/navigation_tab_content.dart';
import 'package:kopim/features/app_shell/presentation/widgets/navigation_responsive_breakpoints.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/credits/domain/utils/credit_card_calculations.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/features/home/domain/models/day_section.dart';
import 'package:kopim/features/home/domain/models/home_account_monthly_summary.dart';
import 'package:kopim/features/home/presentation/controllers/home_dashboard_preferences_controller.dart';
import 'package:kopim/features/home/presentation/controllers/home_transactions_filter_controller.dart';
import 'package:kopim/features/home/presentation/widgets/home_budget_progress_card.dart';
import 'package:kopim/features/home/presentation/widgets/home_gamification_widget.dart';
import 'package:kopim/features/home/presentation/widgets/home_savings_overview_card.dart';
import 'package:kopim/features/home/presentation/widgets/home_upcoming_items_card.dart';
import 'package:kopim/core/widgets/animated_fab.dart';
import 'package:kopim/core/widgets/kopim_glass_fab.dart';
import 'package:kopim/features/home/presentation/widgets/quick_add_transaction.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_sheet_controller.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_editor.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_tile_formatters.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:kopim/core/formatting/currency_symbols.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/collapsible_list/collapsible_list.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/services/sync_service.dart';
import 'package:kopim/core/services/sync_status.dart';
import 'package:kopim/features/profile/presentation/screens/profile_management_screen.dart';
import 'package:kopim/features/transactions/presentation/screens/all_transactions_screen.dart';
import 'package:kopim/features/savings/presentation/screens/saving_goal_details_screen.dart';
import 'package:kopim/features/upcoming_payments/domain/models/upcoming_item.dart';
import 'package:kopim/features/upcoming_payments/domain/providers/upcoming_payments_providers.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/features/upcoming_payments/presentation/screens/upcoming_payments_screen.dart';
import 'package:kopim/features/home/presentation/widgets/top_bar_avatar_icon.dart';
import 'package:kopim/features/home/presentation/widgets/sync_status_indicator.dart';

import '../controllers/home_providers.dart';

final StreamProviderFamily<List<TagEntity>, String> _homeTransactionTagsProvider =
    StreamProvider.autoDispose.family<List<TagEntity>, String>((
      Ref ref,
      String transactionId,
    ) {
      return ref
          .watch(watchTransactionTagsUseCaseProvider)
          .call(transactionId);
    });

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
      return _AddTransactionButton(strings: strings);
    },
    secondaryBodyBuilder: (BuildContext context, WidgetRef ref) =>
        _HomeSecondaryPanel(
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
            final bool showGamificationHeader =
                user != null &&
                (dashboardPreferences?.showGamificationWidget ?? false);

            slivers.add(
              _HomePinnedTitleAppBar(strings: strings, userId: user?.uid),
            );

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

            if (showGamificationHeader) {
              addBoxSection(HomeGamificationWidget(userId: user.uid));
            }

            const EdgeInsets accountsPadding = EdgeInsets.fromLTRB(8, 8, 8, 0);
            final Widget accountsSection = accountsAsync.when(
              data: (List<AccountEntity> accounts) {
                final List<AccountEntity> visibleAccounts = accounts
                    .where((AccountEntity account) => !account.isHidden)
                    .toList(growable: false);
                final List<AccountEntity> hiddenAccounts = accounts
                    .where((AccountEntity account) => account.isHidden)
                    .toList(growable: false);
                return _AccountsList(
                  accounts: visibleAccounts,
                  hiddenAccounts: hiddenAccounts,
                  strings: strings,
                  monthlySummaries:
                      accountSummariesAsync.asData?.value ??
                      const <String, HomeAccountMonthlySummary>{},
                  isWideLayout: showSecondaryPanel,
                  onRevealHidden: hiddenAccounts.isEmpty
                      ? null
                      : () async {
                          final DateTime now = DateTime.now().toUtc();
                          final AddAccountUseCase addAccountUseCase = ref.read(
                            addAccountUseCaseProvider,
                          );
                          await Future.wait(
                            hiddenAccounts.map(
                              (AccountEntity account) => addAccountUseCase(
                                account.copyWith(
                                  isHidden: false,
                                  updatedAt: now,
                                ),
                              ),
                            ),
                          );
                        },
                );
              },
              loading: () => const _TransactionsSkeletonList(),
              error: (Object error, _) => _ErrorMessage(
                message: strings.homeAccountsError(error.toString()),
              ),
            );

            final Widget transactionsSection = groupedTransactionsAsync.when(
              data: (List<DaySection> sections) => _TransactionsSectionCard(
                sections: sections,
                localeName: strings.localeName,
                strings: strings,
                onSeeAll: () {
                  context.push(AllTransactionsScreen.routeName);
                },
              ),
              loading: () => const _TransactionsSectionLoading(),
              error: (Object error, _) => _TransactionsContainer(
                child: _ErrorMessage(
                  message: strings.homeTransactionsError(error.toString()),
                ),
              ),
            );

            slivers.add(
              SliverPadding(
                padding: accountsPadding,
                sliver: SliverList(
                  delegate: SliverChildListDelegate(<Widget>[
                    _SectionHeader(
                      title: strings.homeAccountsSection,
                      action: IconButton(
                        icon: Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        tooltip: strings.homeAccountsAddTooltip,
                        onPressed: () =>
                            context.push(AddAccountScreen.routeName),
                      ),
                    ),
                    const SizedBox(height: 12),
                    accountsSection,
                  ]),
                ),
              ),
            );

            addBoxSection(QuickAddTransactionCard(strings: strings));

            if (!showSecondaryPanel && dashboardPreferencesAsync.hasError) {
              addBoxSection(
                _ErrorMessage(
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
                error: (Object error, _) => _ErrorMessage(
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
    final SyncService syncService = ref.read(syncServiceProvider);
    final SyncActionResult result = await syncService.triggerSync();
    if (!context.mounted) return;
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final String message = switch (result) {
      SyncActionResult.synced => strings.homeSyncStatusSuccess,
      SyncActionResult.offline => strings.homeSyncStatusOffline,
      SyncActionResult.unauthenticated => strings.homeSyncStatusAuthRequired,
      SyncActionResult.alreadySyncing => strings.homeSyncStatusInProgress,
      SyncActionResult.noChanges => strings.homeSyncStatusNoChanges,
    };
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}

class _HomeSecondaryPanel extends StatelessWidget {
  const _HomeSecondaryPanel({
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
        _ErrorMessage(
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
          error: (Object error, _) => _ErrorMessage(
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

class _HomePinnedTitleAppBar extends ConsumerWidget {
  const _HomePinnedTitleAppBar({required this.strings, required this.userId});

  final AppLocalizations strings;
  final String? userId;
  static const double appBarHeight = 40;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final double topPadding = MediaQuery.of(context).padding.top;
    final AsyncValue<Profile?> profileAsync = userId == null
        ? const AsyncValue<Profile?>.data(null)
        : ref.watch(profileControllerProvider(userId!));

    return SliverAppBar(
      automaticallyImplyLeading: false,
      floating: false,
      pinned: false,
      snap: false,
      elevation: 4,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      toolbarHeight: appBarHeight,
      collapsedHeight: topPadding + appBarHeight,
      expandedHeight: topPadding + appBarHeight,
      titleSpacing: 20,
      title: Image.asset(
        'assets/icons/logo_dark.png',
        height: 24,
        fit: BoxFit.contain,
        semanticLabel: 'Копим',
      ),
      actions: <Widget>[
        const Center(child: SyncStatusIndicator()),
        const SizedBox(width: 12),
        Semantics(
          label: strings.homeProfileTooltip,
          button: true,
          child: profileAsync.when(
            data: (Profile? profile) => IconButton(
              tooltip: strings.homeProfileTooltip,
              padding: EdgeInsets.zero,
              iconSize: 48,
              icon: SizedBox(
                width: 48,
                height: 48,
                child: TopBarAvatarIcon(photoUrl: profile?.photoUrl),
              ),
              onPressed: () {
                context.push(ProfileManagementScreen.routeName);
              },
            ),
            loading: () => IconButton(
              tooltip: strings.homeProfileTooltip,
              padding: EdgeInsets.zero,
              onPressed: () {
                context.push(ProfileManagementScreen.routeName);
              },
              icon: const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (Object error, StackTrace? stackTrace) => IconButton(
              tooltip: strings.homeProfileTooltip,
              padding: EdgeInsets.zero,
              iconSize: 48,
              icon: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(Icons.account_circle_outlined),
              ),
              onPressed: () {
                context.push(ProfileManagementScreen.routeName);
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _AddTransactionButton extends ConsumerWidget {
  const _AddTransactionButton({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AnimatedFab(
      child: KopimGlassFab(
        icon: Icon(Icons.add, color: colorScheme.primary),
        foregroundColor: colorScheme.primary,
        onPressed: () =>
            ref.read(transactionSheetControllerProvider.notifier).openForAdd(),
      ),
    );
  }
}

class _AccountsList extends StatefulWidget {
  const _AccountsList({
    required this.accounts,
    required this.hiddenAccounts,
    required this.strings,
    required this.monthlySummaries,
    required this.isWideLayout,
    required this.onRevealHidden,
  });

  final List<AccountEntity> accounts;
  final List<AccountEntity> hiddenAccounts;
  final AppLocalizations strings;
  final Map<String, HomeAccountMonthlySummary> monthlySummaries;
  final bool isWideLayout;
  final Future<void> Function()? onRevealHidden;

  @override
  State<_AccountsList> createState() => _AccountsListState();
}

class _AccountsListState extends State<_AccountsList> {
  late PageController _pageController;
  late double _viewportFraction;
  int _currentPage = 0;

  int get _totalItems =>
      widget.accounts.length + (widget.hiddenAccounts.isNotEmpty ? 1 : 0);

  @override
  void initState() {
    super.initState();
    _viewportFraction = _totalItems == 1 ? 1.0 : 0.65;
    _pageController = PageController(viewportFraction: _viewportFraction);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateViewportFraction(double fraction) {
    if ((_viewportFraction - fraction).abs() < 0.001) {
      return;
    }
    final int maxIndex = math.max(0, _totalItems - 1);
    final int initialPage = _pageController.hasClients
        ? _pageController.page?.round().clamp(0, maxIndex) ?? 0
        : _currentPage.clamp(0, maxIndex);
    final PageController oldController = _pageController;
    final PageController newController = PageController(
      viewportFraction: fraction,
      initialPage: initialPage,
    );
    setState(() {
      _viewportFraction = fraction;
      _pageController = newController;
      _currentPage = initialPage;
    });
    oldController.dispose();
  }

  double _calculateRequiredFraction({
    required BuildContext context,
    required BoxConstraints constraints,
    required String localeName,
  }) {
    final double maxWidth = constraints.maxWidth;
    if (maxWidth <= 0 || widget.accounts.isEmpty) {
      return 0;
    }
    double requiredWidth = 0;
    for (final AccountEntity account in widget.accounts) {
      final NumberFormat format = NumberFormat.currency(
        locale: localeName,
        symbol: resolveCurrencySymbol(account.currency, locale: localeName),
      );
      final double width = _AccountCardLayout.measureBalanceWidth(
        context: context,
        text: format.format(account.balance),
      );
      requiredWidth = math.max(requiredWidth, width);
    }
    requiredWidth += _AccountCardLayout.horizontalPadding;
    return (requiredWidth / maxWidth).clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasHiddenAccounts = widget.hiddenAccounts.isNotEmpty;
    if (widget.accounts.isEmpty && !hasHiddenAccounts) {
      return _EmptyMessage(message: widget.strings.homeAccountsEmpty);
    }

    final ThemeData theme = Theme.of(context);
    final String localeName = widget.strings.localeName;
    final int totalItems = _totalItems;

    if (widget.isWideLayout) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double cardHeight = _AccountCardLayout.estimateHeight(context);
          final double cardWidth =
              math.min(360, constraints.maxWidth * 0.6);
          final double revealWidth = cardWidth * 0.75;
          return SizedBox(
            height: cardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: totalItems,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(width: 12),
              itemBuilder: (BuildContext context, int index) {
                if (index >= widget.accounts.length) {
                  return SizedBox(
                    width: revealWidth,
                    child: _HiddenAccountsRevealCard(
                      onTap: widget.onRevealHidden,
                    ),
                  );
                }
                final AccountEntity account = widget.accounts[index];
                final NumberFormat currencyFormat = NumberFormat.currency(
                  locale: localeName,
                  symbol: resolveCurrencySymbol(
                    account.currency,
                    locale: localeName,
                  ),
                );
                return SizedBox(
                  width: cardWidth,
                  child: _AccountCard(
                    account: account,
                    strings: widget.strings,
                    currencyFormat: currencyFormat,
                    summary:
                        widget.monthlySummaries[account.id] ??
                        const HomeAccountMonthlySummary(income: 0, expense: 0),
                    isHighlighted: index == 0,
                  ),
                );
              },
            ),
          );
        },
      );
    }

    final int maxIndex = math.max(0, totalItems - 1);
    final int activePage = _currentPage.clamp(0, maxIndex);
    if (_currentPage != activePage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _currentPage = activePage;
        });
      });
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isCarouselWide = constraints.maxWidth >= 720;

        final bool isSingleAccount = totalItems == 1;
        final double baseFraction = isSingleAccount
            ? 1.0
            : (isCarouselWide ? 0.45 : 0.65);
        final double minScrollableFraction = isSingleAccount
            ? 1.0
            : (1 / totalItems) + 0.02;
        final double requiredFraction = _calculateRequiredFraction(
          context: context,
          constraints: constraints,
          localeName: localeName,
        );
        final double targetFraction = math.min(
          isSingleAccount ? 1.0 : 0.98,
          math.max(
            baseFraction,
            math.max(requiredFraction, minScrollableFraction),
          ),
        );
        final double baseHeight = _AccountCardLayout.estimateHeight(context);
        final double cardHeight = math.max(
          baseHeight,
          isCarouselWide ? 168 : 176,
        );
        if ((_viewportFraction - targetFraction).abs() > 0.001) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _updateViewportFraction(targetFraction);
          });
        }

        return Column(
          children: <Widget>[
            SizedBox(
              height: cardHeight,
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                padEnds: false,
                itemCount: totalItems,
                onPageChanged: (int index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  if (index >= widget.accounts.length) {
                    final bool isLast = index == totalItems - 1;
                    return Padding(
                      padding: EdgeInsets.only(right: isLast ? 0 : 8),
                      child: LayoutBuilder(
                        builder: (
                          BuildContext context,
                          BoxConstraints constraints,
                        ) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: constraints.maxWidth * 0.82,
                              child: _HiddenAccountsRevealCard(
                                onTap: widget.onRevealHidden,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  final AccountEntity account = widget.accounts[index];
                  final NumberFormat currencyFormat = NumberFormat.currency(
                    locale: localeName,
                    symbol: resolveCurrencySymbol(
                      account.currency,
                      locale: localeName,
                    ),
                    decimalDigits: 0,
                  );
                  final HomeAccountMonthlySummary summary =
                      widget.monthlySummaries[account.id] ??
                      const HomeAccountMonthlySummary(income: 0, expense: 0);

                  final bool isLast = index == totalItems - 1;
                  return Padding(
                    padding: EdgeInsets.only(right: isLast ? 0 : 8),
                    child: _AccountCard(
                      account: account,
                      strings: widget.strings,
                      currencyFormat: currencyFormat,
                      summary: summary,
                      isHighlighted: index == 0,
                    ),
                  );
                },
              ),
            ),
            if (totalItems > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(totalItems, (
                    int index,
                  ) {
                    final bool isActive = index == activePage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: isActive ? 24 : 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AccountCard extends ConsumerWidget {
  const _AccountCard({
    required this.account,
    required this.strings,
    required this.currencyFormat,
    required this.summary,
    required this.isHighlighted,
  });

  final AccountEntity account;
  final AppLocalizations strings;
  final NumberFormat currencyFormat;
  final HomeAccountMonthlySummary summary;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final Color? accountColor = parseHexColor(account.color);
    final AccountCardGradient? gradient = resolveAccountCardGradient(
      account.gradientId,
    );
    final PhosphorIconData? accountIcon = _resolveAccountIconData(account);
    final _AccountCardPalette palette = _AccountCardPalette.fromAccount(
      colorScheme: theme.colorScheme,
      accountColor: accountColor,
      gradient: gradient,
      isHighlighted: isHighlighted,
    );
    final double cardRadius = context.kopimLayout.radius.xxl;
    final BorderRadius borderRadius = BorderRadius.circular(cardRadius);
    final TextStyle labelStyle =
        (theme.textTheme.labelSmall ??
                const TextStyle(fontSize: 11, height: 1.45))
            .copyWith(
              color: palette.support,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            );
    final TextStyle balanceStyle =
        (theme.textTheme.displaySmall ??
                theme.textTheme.headlineMedium ??
                const TextStyle(fontSize: 36, height: 44 / 36))
            .copyWith(
              fontWeight: FontWeight.w500,
              color: palette.emphasis,
              letterSpacing: 0.1,
            );
    final TextStyle summaryTextStyle =
        (theme.textTheme.titleSmall ??
                theme.textTheme.titleMedium ??
                const TextStyle(fontSize: 14))
            .copyWith(
              color: palette.emphasis,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            );
    final TextStyle summaryHeaderStyle = labelStyle.copyWith(
      color: palette.summaryLabel,
    );
    final Widget standardContent = _StandardAccountContent(
      account: account,
      strings: strings,
      currencyFormat: currencyFormat,
      summary: summary,
      labelStyle: labelStyle,
      balanceStyle: balanceStyle,
      summaryTextStyle: summaryTextStyle,
      summaryHeaderStyle: summaryHeaderStyle,
      accountIcon: accountIcon,
      palette: palette,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () {
          context.push(
            AccountDetailsScreenArgs(accountId: account.id).location,
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            color: gradient == null ? palette.background : null,
            gradient: gradient?.toGradient(),
            borderRadius: borderRadius,
          ),
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(24),
                child: switch (account.type) {
                  'credit' => _CreditCardContent(
                    account: account,
                    strings: strings,
                    currencyFormat: currencyFormat,
                    palette: palette,
                    labelStyle: labelStyle,
                    balanceStyle: balanceStyle,
                    summaryTextStyle: summaryTextStyle,
                    summaryHeaderStyle: summaryHeaderStyle,
                    accountIcon: accountIcon,
                  ),
                  'credit_card' => _CreditCardAccountContent(
                    account: account,
                    strings: strings,
                    currencyFormat: currencyFormat,
                    labelStyle: labelStyle,
                    balanceStyle: balanceStyle,
                    summaryTextStyle: summaryTextStyle,
                    accountIcon: accountIcon,
                    palette: palette,
                    fallback: standardContent,
                  ),
                  _ => standardContent,
                },
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: _AccountHideButton(
                  account: account,
                  color: palette.support,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountHideButton extends ConsumerWidget {
  const _AccountHideButton({required this.account, required this.color});

  final AccountEntity account;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      type: MaterialType.transparency,
      child: InkResponse(
        onTap: () async {
          final DateTime now = DateTime.now().toUtc();
          final AddAccountUseCase addAccountUseCase = ref.read(
            addAccountUseCaseProvider,
          );
          await addAccountUseCase(
            account.copyWith(isHidden: true, updatedAt: now),
          );
        },
        radius: 20,
        containedInkWell: true,
        child: SizedBox(
          width: _AccountIconBadge.size,
          height: _AccountIconBadge.size,
          child: Icon(
            PhosphorIcons.eyeSlash(PhosphorIconsStyle.regular),
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _HiddenAccountsRevealCard extends StatelessWidget {
  const _HiddenAccountsRevealCard({required this.onTap});

  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double cardRadius = context.kopimLayout.radius.xxl;
    final BorderRadius borderRadius = BorderRadius.circular(cardRadius);
    final Color background = theme.colorScheme.surfaceContainerHighest;
    final Color iconColor = theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap == null ? null : () => onTap!(),
        child: Ink(
          decoration: BoxDecoration(
            color: background,
            borderRadius: borderRadius,
          ),
          child: Center(
            child: Icon(
              PhosphorIcons.eye(PhosphorIconsStyle.regular),
              size: 48,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

PhosphorIconData? _resolveAccountIconData(AccountEntity account) {
  final String? iconName = account.iconName;
  if (iconName == null || iconName.isEmpty) {
    return null;
  }
  final PhosphorIconDescriptor descriptor = PhosphorIconDescriptor(
    name: iconName,
    style: PhosphorIconStyleX.fromName(account.iconStyle),
  );
  return resolvePhosphorIconData(descriptor);
}

class _AccountIconBadge extends StatelessWidget {
  const _AccountIconBadge({required this.icon, required this.color});

  static const double size = 28;

  final PhosphorIconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}

class _StandardAccountContent extends StatelessWidget {
  const _StandardAccountContent({
    required this.account,
    required this.strings,
    required this.currencyFormat,
    required this.summary,
    required this.labelStyle,
    required this.balanceStyle,
    required this.summaryTextStyle,
    required this.summaryHeaderStyle,
    required this.accountIcon,
    required this.palette,
  });

  final AccountEntity account;
  final AppLocalizations strings;
  final NumberFormat currencyFormat;
  final HomeAccountMonthlySummary summary;
  final TextStyle labelStyle;
  final TextStyle balanceStyle;
  final TextStyle summaryTextStyle;
  final TextStyle summaryHeaderStyle;
  final PhosphorIconData? accountIcon;
  final _AccountCardPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            if (accountIcon != null)
              _AccountIconBadge(icon: accountIcon!, color: palette.emphasis),
            if (accountIcon != null) const SizedBox(width: 8),
            Expanded(
              child: Text(
                account.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: labelStyle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          currencyFormat.format(account.balance),
          style: balanceStyle,
          softWrap: true,
        ),
        const SizedBox(height: 16),
        Text(strings.analyticsCurrentMonthTitle, style: summaryHeaderStyle),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _AccountMonthlyValue(
              label: strings.homeAccountMonthlyIncomeLabel,
              value: currencyFormat.format(summary.income),
              textStyle: summaryTextStyle,
            ),
            const SizedBox(height: 4),
            _AccountMonthlyValue(
              label: strings.homeAccountMonthlyExpenseLabel,
              value: currencyFormat.format(summary.expense),
              textStyle: summaryTextStyle,
            ),
          ],
        ),
      ],
    );
  }
}

class _CreditCardAccountContent extends ConsumerWidget {
  const _CreditCardAccountContent({
    required this.account,
    required this.strings,
    required this.currencyFormat,
    required this.labelStyle,
    required this.balanceStyle,
    required this.summaryTextStyle,
    required this.accountIcon,
    required this.palette,
    required this.fallback,
  });

  final AccountEntity account;
  final AppLocalizations strings;
  final NumberFormat currencyFormat;
  final TextStyle labelStyle;
  final TextStyle balanceStyle;
  final TextStyle summaryTextStyle;
  final PhosphorIconData? accountIcon;
  final _AccountCardPalette palette;
  final Widget fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Stream<List<CreditCardEntity>> creditCardsAsync = ref
        .watch(watchCreditCardsUseCaseProvider)
        .call();

    return StreamBuilder<List<CreditCardEntity>>(
      stream: creditCardsAsync,
      builder:
          (
            BuildContext context,
            AsyncSnapshot<List<CreditCardEntity>> snapshot,
          ) {
            final CreditCardEntity? creditCard = snapshot.data?.firstWhereOrNull(
              (CreditCardEntity item) => item.accountId == account.id,
            );
            if (creditCard == null) {
              return fallback;
            }

            final double availableLimit = calculateCreditCardAvailableLimit(
              creditLimit: creditCard.creditLimit,
              balance: account.balance,
            );
            final double debt = calculateCreditCardDebt(account.balance);
            final TextStyle debtStyle = summaryTextStyle.copyWith(
              color: palette.support,
              fontWeight: FontWeight.w500,
            );
            final TextStyle limitLabelStyle = labelStyle.copyWith(
              color: palette.support,
            );

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    if (accountIcon != null)
                      _AccountIconBadge(
                        icon: accountIcon!,
                        color: palette.emphasis,
                      ),
                    if (accountIcon != null) const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        account.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: labelStyle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(strings.creditCardAvailableLimitLabel, style: limitLabelStyle),
                const SizedBox(height: 4),
                Text(
                  currencyFormat.format(availableLimit),
                  style: balanceStyle,
                  softWrap: true,
                ),
                const SizedBox(height: 10),
                Text(strings.creditCardSpentLabel, style: limitLabelStyle),
                const SizedBox(height: 4),
                Text(currencyFormat.format(debt), style: debtStyle),
              ],
            );
          },
    );
  }
}

class _CreditCardContent extends ConsumerWidget {
  const _CreditCardContent({
    required this.account,
    required this.strings,
    required this.currencyFormat,
    required this.palette,
    required this.labelStyle,
    required this.balanceStyle,
    required this.summaryTextStyle,
    required this.summaryHeaderStyle,
    required this.accountIcon,
  });

  final AccountEntity account;
  final AppLocalizations strings;
  final NumberFormat currencyFormat;
  final _AccountCardPalette palette;
  final TextStyle labelStyle;
  final TextStyle balanceStyle;
  final TextStyle summaryTextStyle;
  final TextStyle summaryHeaderStyle;
  final PhosphorIconData? accountIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Stream<List<CreditEntity>> creditsAsync = ref
        .watch(watchCreditsUseCaseProvider)
        .call();

    return StreamBuilder<List<CreditEntity>>(
      stream: creditsAsync,
      builder:
          (BuildContext context, AsyncSnapshot<List<CreditEntity>> snapshot) {
            final CreditEntity? credit = snapshot.data?.firstWhereOrNull(
              (CreditEntity item) => item.accountId == account.id,
            );

            if (credit == null) {
              return const SizedBox();
            }

            final DateTime nextPaymentDate = _calculateNextPaymentDate(credit);
            final int remainingPayments = _calculateRemainingPayments(credit);
            final double progress =
                (credit.totalAmount + account.balance).abs() /
                credit.totalAmount;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          if (accountIcon != null)
                            _AccountIconBadge(
                              icon: accountIcon!,
                              color: palette.emphasis,
                            ),
                          if (accountIcon != null) const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              account.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: labelStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(account.balance.abs()),
                  style: balanceStyle,
                  softWrap: true,
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: palette.support.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(palette.emphasis),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          strings.creditsNextPaymentLabel,
                          style: summaryHeaderStyle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat.yMd(
                            strings.localeName,
                          ).format(nextPaymentDate),
                          style: summaryTextStyle,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          strings.creditsRemainingPaymentsLabel,
                          style: summaryHeaderStyle,
                        ),
                        const SizedBox(height: 4),
                        Text('$remainingPayments', style: summaryTextStyle),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
    );
  }

  DateTime _calculateNextPaymentDate(CreditEntity credit) {
    final DateTime now = DateTime.now();
    final int paymentDay = credit.paymentDay;

    // Пробуем текущий месяц
    DateTime candidate = DateTime(now.year, now.month, paymentDay);

    // Если дата уже прошла, берем следующий месяц
    if (candidate.isBefore(now) || candidate.isAtSameMomentAs(now)) {
      candidate = DateTime(now.year, now.month + 1, paymentDay);
    }

    return candidate;
  }

  int _calculateRemainingPayments(CreditEntity credit) {
    final DateTime now = DateTime.now();
    final int monthsPassed = _monthsBetween(credit.startDate, now);
    final int remaining = credit.termMonths - monthsPassed;
    return remaining > 0 ? remaining : 0;
  }

  int _monthsBetween(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + end.month - start.month;
  }
}

class _AccountMonthlyValue extends StatelessWidget {
  const _AccountMonthlyValue({
    required this.label,
    required this.value,
    required this.textStyle,
  });

  final String label;
  final String value;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Text('$label: $value', style: textStyle, softWrap: true);
  }
}

class _AccountCardPalette {
  const _AccountCardPalette({
    required this.background,
    required this.emphasis,
    required this.support,
    required this.summaryLabel,
  });

  factory _AccountCardPalette.fromAccount({
    required ColorScheme colorScheme,
    Color? accountColor,
    AccountCardGradient? gradient,
    required bool isHighlighted,
  }) {
    final Color defaultBackground = isHighlighted
        ? colorScheme.primary
        : colorScheme.tertiary;
    final Color background =
        gradient?.sampleColor ?? accountColor ?? defaultBackground;
    final Brightness brightness = ThemeData.estimateBrightnessForColor(
      background,
    );
    final Color emphasis = brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
    final Color support = brightness == Brightness.dark
        ? Colors.white70
        : Colors.black54;
    return _AccountCardPalette(
      background: background,
      emphasis: emphasis,
      support: support,
      summaryLabel: support,
    );
  }

  final Color background;
  final Color emphasis;
  final Color support;
  final Color summaryLabel;
}

class _AccountCardLayout {
  static const double horizontalPadding = 48;

  static double estimateHeight(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double label = _textHeight(
      theme.textTheme.labelSmall ?? const TextStyle(fontSize: 11, height: 1.45),
    );
    final double header = math.max(label, _AccountIconBadge.size);
    final double balance = _textHeight(
      theme.textTheme.displaySmall ??
          theme.textTheme.headlineMedium ??
          const TextStyle(fontSize: 36, height: 44 / 36),
    );
    final double summaryTitle = _textHeight(
      theme.textTheme.labelSmall ?? const TextStyle(fontSize: 11, height: 1.45),
    );
    final double summaryValue = _textHeight(
      theme.textTheme.titleSmall ??
          theme.textTheme.bodyLarge ??
          const TextStyle(fontSize: 14),
    );

    const double padding = 24 * 2;
    const double gaps = 8 + 16 + 8 + 4;

    return padding +
        header +
        balance +
        summaryTitle +
        (summaryValue * 2) +
        gaps;
  }

  static double measureBalanceWidth({
    required BuildContext context,
    required String text,
  }) {
    final ThemeData theme = Theme.of(context);
    final TextStyle style =
        theme.textTheme.displaySmall ??
        theme.textTheme.headlineMedium ??
        const TextStyle(fontSize: 36, height: 44 / 36);
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: ui.TextDirection.ltr,
    )..layout();
    return painter.width;
  }

  static double _textHeight(TextStyle style) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: 'Hg', style: style),
      maxLines: 1,
      textDirection: ui.TextDirection.ltr,
    )..layout();
    return painter.height;
  }
}

List<_TransactionSliverEntry> _buildTransactionEntries(
  List<DaySection> sections,
  String localeName,
  AppLocalizations strings,
) {
  final DateTime today = DateUtils.dateOnly(DateTime.now());
  final DateTime yesterday = DateUtils.dateOnly(
    today.subtract(const Duration(days: 1)),
  );
  final DateFormat headerFormat = TransactionTileFormatters.dayHeader(
    localeName,
  );
  final List<_TransactionSliverEntry> entries = <_TransactionSliverEntry>[];
  for (final DaySection section in sections) {
    final String title = _formatSectionTitle(
      date: section.date,
      today: today,
      yesterday: yesterday,
      dateFormat: headerFormat,
      strings: strings,
    );
    final double netAmount = _calculateDayNet(section.transactions);
    entries.add(_TransactionHeaderEntry(title: title, netAmount: netAmount));
    for (final TransactionEntity transaction in section.transactions) {
      entries.add(_TransactionItemEntry(transactionId: transaction.id));
    }
  }
  return entries;
}

class _TransactionsSectionCard extends StatefulWidget {
  const _TransactionsSectionCard({
    required this.sections,
    required this.localeName,
    required this.strings,
    required this.onSeeAll,
  });

  final List<DaySection> sections;
  final String localeName;
  final AppLocalizations strings;
  final VoidCallback onSeeAll;

  @override
  State<_TransactionsSectionCard> createState() =>
      _TransactionsSectionCardState();
}

class _TransactionsSectionCardState extends State<_TransactionsSectionCard> {
  late List<_TransactionSliverEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = _buildTransactionEntries(
      widget.sections,
      widget.localeName,
      widget.strings,
    );
  }

  @override
  void didUpdateWidget(covariant _TransactionsSectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.sections, widget.sections) ||
        oldWidget.localeName != widget.localeName) {
      _entries = _buildTransactionEntries(
        widget.sections,
        widget.localeName,
        widget.strings,
      );
    }
  }

  Widget _buildEntryList(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NumberFormat moneyFormat = TransactionTileFormatters.currency(
      widget.localeName,
      TransactionTileFormatters.fallbackCurrencySymbol(widget.localeName),
      decimalDigits: 0,
    );
    final TextStyle dateStyle =
        theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ) ??
        const TextStyle(fontSize: 16, height: 24 / 16);
    final TextStyle amountStyle =
        theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ) ??
        const TextStyle(fontSize: 14, height: 20 / 14);
    final bool hasTransactions = _entries.any(
      (_TransactionSliverEntry entry) => entry is _TransactionItemEntry,
    );
    if (!hasTransactions) {
      return _EmptyMessage(message: widget.strings.homeTransactionsEmpty);
    }
    final List<Widget> widgets = <Widget>[];
    for (int i = 0; i < _entries.length; i++) {
      final _TransactionSliverEntry entry = _entries[i];
      if (entry is _TransactionHeaderEntry) {
        final double netAmount = entry.netAmount;
        final String formattedAmount = moneyFormat.format(netAmount.abs());
        final String amountLabel = netAmount < 0
            ? '- $formattedAmount'
            : formattedAmount;
        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 24, bottom: 8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
              child: SizedBox(
                height: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        entry.title,
                        style: dateStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(amountLabel, style: amountStyle),
                  ],
                ),
              ),
            ),
          ),
        );
        continue;
      }
      if (entry is _TransactionItemEntry) {
        widgets.add(
          _TransactionListItem(
            transactionId: entry.transactionId,
            localeName: widget.localeName,
            strings: widget.strings,
          ),
        );
        continue;
      }
      widgets.add(const SizedBox.shrink());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? titleStyle = theme.textTheme.titleLarge?.copyWith(
      color: theme.colorScheme.onSurface,
    );
    return _TransactionsContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(widget.strings.homeTransactionsSection, style: titleStyle),
          const SizedBox(height: 16),
          _TransactionsFilterBar(strings: widget.strings),
          const SizedBox(height: 16),
          _buildEntryList(context),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: widget.onSeeAll,
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                textStyle: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
              child: Text(widget.strings.homeTransactionsSeeAll),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionsSectionLoading extends StatelessWidget {
  const _TransactionsSectionLoading();

  @override
  Widget build(BuildContext context) {
    return const _TransactionsContainer(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _TransactionsContainer extends StatelessWidget {
  const _TransactionsContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double containerRadius = context.kopimLayout.radius.xxl;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(containerRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: child,
      ),
    );
  }
}

class _TransactionsFilterBar extends ConsumerWidget {
  const _TransactionsFilterBar({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final HomeTransactionsFilter selected = ref.watch(
      homeTransactionsFilterControllerProvider,
    );
    final KopimLayout layout = context.kopimLayout;
    final double containerRadius = layout.radius.xxl;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(containerRadius),
      ),
      padding: const EdgeInsets.all(6),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double segmentWidth = constraints.maxWidth / 3;
          final Color accent = theme.colorScheme.primary;
          const Duration duration = Duration(milliseconds: 260);

          int selectedIndex = 0;
          switch (selected) {
            case HomeTransactionsFilter.all:
              selectedIndex = 0;
            case HomeTransactionsFilter.income:
              selectedIndex = 1;
            case HomeTransactionsFilter.expense:
              selectedIndex = 2;
          }

          return SizedBox(
            height: 48,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: duration,
                  curve: Curves.easeOutBack,
                  left: selectedIndex * segmentWidth,
                  top: 0,
                  bottom: 0,
                  width: segmentWidth,
                  child: AnimatedContainer(
                    duration: duration,
                    curve: Curves.easeOutBack,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: accent,
                      boxShadow: const <BoxShadow>[],
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _FilterSegmentItem(
                        label: strings.homeTransactionsFilterAll,
                        selected: selected == HomeTransactionsFilter.all,
                        onTap: () => ref
                            .read(
                              homeTransactionsFilterControllerProvider.notifier,
                            )
                            .update(HomeTransactionsFilter.all),
                        selectedTextColor: theme.colorScheme.onPrimary,
                      ),
                    ),
                    Expanded(
                      child: _FilterSegmentItem(
                        label: strings.homeTransactionsFilterIncome,
                        selected: selected == HomeTransactionsFilter.income,
                        onTap: () => ref
                            .read(
                              homeTransactionsFilterControllerProvider.notifier,
                            )
                            .update(HomeTransactionsFilter.income),
                        selectedTextColor: theme.colorScheme.onPrimary,
                      ),
                    ),
                    Expanded(
                      child: _FilterSegmentItem(
                        label: strings.homeTransactionsFilterExpense,
                        selected: selected == HomeTransactionsFilter.expense,
                        onTap: () => ref
                            .read(
                              homeTransactionsFilterControllerProvider.notifier,
                            )
                            .update(HomeTransactionsFilter.expense),
                        selectedTextColor: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FilterSegmentItem extends StatelessWidget {
  const _FilterSegmentItem({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedTextColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedTextColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle baseStyle =
        theme.textTheme.labelLarge ?? const TextStyle(fontSize: 16);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          scale: selected ? 1.0 : 0.95,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            style: baseStyle.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected
                  ? selectedTextColor
                  : theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
    );
  }
}

sealed class _TransactionSliverEntry {
  const _TransactionSliverEntry();
}

class _TransactionHeaderEntry extends _TransactionSliverEntry {
  const _TransactionHeaderEntry({required this.title, required this.netAmount});

  final String title;
  final double netAmount;
}

class _TransactionItemEntry extends _TransactionSliverEntry {
  const _TransactionItemEntry({required this.transactionId});

  final String transactionId;
}

String _formatSectionTitle({
  required DateTime date,
  required DateTime today,
  required DateTime yesterday,
  required DateFormat dateFormat,
  required AppLocalizations strings,
}) {
  if (date.isAtSameMomentAs(today)) {
    return strings.homeTransactionsTodayLabel;
  }
  if (date.isAtSameMomentAs(yesterday)) {
    return strings.homeTransactionsYesterdayLabel;
  }
  final String formatted = dateFormat.format(date);
  return toBeginningOfSentenceCase(formatted) ?? formatted;
}

String? _buildTransferLabel({
  required String? sourceAccount,
  required String? targetAccount,
  required AppLocalizations strings,
}) {
  if (sourceAccount == null && targetAccount == null) {
    return null;
  }
  if (sourceAccount == null) {
    return strings.transactionTransferAccountSingle(targetAccount!);
  }
  if (targetAccount == null) {
    return strings.transactionTransferAccountSingle(sourceAccount);
  }
  return strings.transactionTransferAccountPair(sourceAccount, targetAccount);
}

Widget _buildTitleWithTags({
  required BuildContext context,
  required String title,
  required String tagLabel,
}) {
  final ThemeData theme = Theme.of(context);
  final TextStyle? baseStyle = theme.textTheme.labelMedium?.copyWith(
    fontWeight: FontWeight.w500,
    color: theme.colorScheme.onSurface,
  );
  if (tagLabel.isEmpty) {
    return Text(
      title,
      style: baseStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  final TextStyle? tagStyle = baseStyle?.copyWith(
    color: theme.colorScheme.onSurfaceVariant,
    fontWeight: FontWeight.w400,
  );

  return Text.rich(
    TextSpan(
      children: <InlineSpan>[
        TextSpan(text: title),
        const TextSpan(text: '  '),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Icon(
            Icons.local_offer_outlined,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const TextSpan(text: ' '),
        TextSpan(text: tagLabel, style: tagStyle),
      ],
    ),
    style: baseStyle,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

double _calculateDayNet(List<TransactionEntity> transactions) {
  double income = 0;
  double expense = 0;
  for (final TransactionEntity transaction in transactions) {
    if (transaction.type == TransactionType.income.storageValue) {
      income += transaction.amount.abs();
    } else if (transaction.type == TransactionType.expense.storageValue) {
      expense += transaction.amount.abs();
    }
  }
  return income - expense;
}

class _TransactionListItem extends ConsumerWidget {
  const _TransactionListItem({
    required this.transactionId,
    required this.localeName,
    required this.strings,
  });

  static const double extent = 112;

  final String transactionId;
  final String localeName;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TransactionEntity? transaction = ref.watch(
      homeTransactionByIdProvider(transactionId),
    );

    if (transaction == null) {
      return const _TransactionTileSkeleton();
    }

    final String accountId = transaction.accountId;
    final String? categoryId = transaction.categoryId;
    final double amount = transaction.amount;
    final String? note = transaction.note;
    final bool isTransfer =
        transaction.type == TransactionType.transfer.storageValue;
    final List<TagEntity> tags = isTransfer
        ? const <TagEntity>[]
        : ref
                .watch(_homeTransactionTagsProvider(transactionId))
                .asData
                ?.value ??
            const <TagEntity>[];
    final String tagLabel = tags.map((TagEntity tag) => tag.name).join(', ');

    final ThemeData theme = Theme.of(context);
    final ({String? name, String? currency}) accountData = ref.watch(
      homeAccountByIdProvider(accountId).select(
        (AccountEntity? account) =>
            (name: account?.name, currency: account?.currency),
      ),
    );
    final String? transferAccountId = transaction.transferAccountId;
    final String? transferAccountName = isTransfer && transferAccountId != null
        ? ref.watch(
            homeAccountByIdProvider(
              transferAccountId,
            ).select((AccountEntity? account) => account?.name),
          )
        : null;
    final String currencySymbol = accountData.currency != null
        ? resolveCurrencySymbol(accountData.currency!, locale: localeName)
        : TransactionTileFormatters.fallbackCurrencySymbol(localeName);
    final NumberFormat moneyFormat = TransactionTileFormatters.currency(
      localeName,
      currencySymbol,
      decimalDigits: 0,
    );

    final ({String? name, PhosphorIconDescriptor? icon, String? color})
    categoryData = categoryId == null
        ? (name: null, icon: null, color: null)
        : ref.watch(
            homeCategoryByIdProvider(categoryId).select(
              (Category? cat) =>
                  (name: cat?.name, icon: cat?.icon, color: cat?.color),
            ),
          );
    final String categoryName =
        categoryData.name ?? strings.homeTransactionsUncategorized;
    final String title = isTransfer
        ? strings.addTransactionTypeTransfer
        : categoryName;
    final PhosphorIconData? categoryIcon = resolvePhosphorIconData(
      categoryData.icon,
    );
    final Color? categoryColor = parseHexColor(categoryData.color);
    final Color avatarIconColor = isTransfer
        ? theme.colorScheme.onPrimaryContainer
        : categoryColor != null
        ? (ThemeData.estimateBrightnessForColor(categoryColor) ==
                  Brightness.dark
              ? Colors.white
              : Colors.black87)
        : theme.colorScheme.onSurfaceVariant;
    final Color avatarBackground = isTransfer
        ? theme.colorScheme.primaryContainer
        : categoryColor ?? theme.colorScheme.surfaceContainerHighest;
    final String? accountLabel = isTransfer
        ? _buildTransferLabel(
            sourceAccount: accountData.name,
            targetAccount: transferAccountName,
            strings: strings,
          )
        : accountData.name;

    return Dismissible(
      key: ValueKey<String>(transactionId),
      direction: DismissDirection.endToStart,
      background: buildDeleteBackground(
        theme.colorScheme.errorContainer,
        iconColor: theme.colorScheme.onErrorContainer,
      ),
      confirmDismiss: (DismissDirection direction) async {
        return deleteTransactionWithFeedback(
          context: context,
          ref: ref,
          transactionId: transactionId,
          strings: strings,
        );
      },
      child: RepaintBoundary(
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          surfaceTintColor: Colors.transparent,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(18)),
            onTap: () => ref
                .read(transactionSheetControllerProvider.notifier)
                .openForEdit(transaction),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: avatarBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        categoryIcon ??
                            (isTransfer
                                ? Icons.swap_horiz
                                : Icons.category_outlined),
                        size: 22,
                        color: avatarIconColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        _buildTitleWithTags(
                          context: context,
                          title: title,
                          tagLabel: tagLabel,
                        ),
                        if (note != null && note.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              note,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        moneyFormat.format(amount.abs()),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (accountLabel != null && accountLabel.isNotEmpty)
                        Text(
                          accountLabel,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionTileSkeleton extends StatelessWidget {
  const _TransactionTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: _SkeletonContainer(),
    );
  }
}

class _TransactionsSkeletonList extends StatelessWidget {
  const _TransactionsSkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (BuildContext context, int index) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: _SkeletonContainer(),
        );
      },
    );
  }
}

class _SkeletonContainer extends StatelessWidget {
  const _SkeletonContainer();

  static const double _height = _TransactionListItem.extent - 10;

  @override
  Widget build(BuildContext context) {
    final Color base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.titleLarge;
    if (action == null) {
      return Padding(
        padding: const EdgeInsets.only(left: 24),
        child: Text(title, style: style),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const SizedBox(width: 24),
        Expanded(child: Text(title, style: style)),
        const SizedBox(width: 8),
        action!,
      ],
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.error,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(message, style: style, textAlign: TextAlign.center),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
