import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/utils/account_type_utils.dart';
import 'package:kopim/features/accounts/presentation/account_details_screen.dart';
import 'package:kopim/features/accounts/presentation/accounts_add_screen.dart';
import 'package:kopim/features/app_shell/presentation/models/navigation_tab_content.dart';
import 'package:kopim/features/app_shell/presentation/widgets/navigation_responsive_breakpoints.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/features/home/domain/models/day_section.dart';
import 'package:kopim/features/home/domain/models/home_account_monthly_summary.dart';
import 'package:kopim/features/home/presentation/controllers/home_dashboard_preferences_controller.dart';
import 'package:kopim/features/home/presentation/controllers/home_transactions_filter_controller.dart';
import 'package:kopim/features/home/presentation/widgets/home_budget_progress_card.dart';
import 'package:kopim/features/home/presentation/widgets/home_gamification_app_bar.dart';
import 'package:kopim/features/home/presentation/widgets/home_savings_overview_card.dart';
import 'package:kopim/features/home/presentation/widgets/home_upcoming_items_card.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/screens/general_settings_screen.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/presentation/add_transaction_screen.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_actions_controller.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_editor.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_tile_formatters.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_form_view.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/kopim_floating_action_button.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/profile/presentation/screens/profile_management_screen.dart';
import 'package:kopim/features/transactions/presentation/screens/all_transactions_screen.dart';
import 'package:kopim/features/savings/presentation/screens/saving_goal_details_screen.dart';
import 'package:kopim/features/upcoming_payments/domain/models/upcoming_item.dart';
import 'package:kopim/features/upcoming_payments/domain/providers/upcoming_payments_providers.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/features/upcoming_payments/presentation/screens/upcoming_payments_screen.dart';

import '../controllers/home_providers.dart';

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
    floatingActionButtonBuilder: (BuildContext context, WidgetRef ref) =>
        _AddTransactionButton(strings: strings),
    secondaryBodyBuilder: (BuildContext context, WidgetRef ref) =>
        _HomeSecondaryPanel(
          dashboardPreferencesAsync: dashboardPreferencesAsync,
          strings: strings,
          upcomingItemsAsync: upcomingItemsAsync,
          timeService: timeService,
        ),
  );
}

class _HomeBody extends StatelessWidget {
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
  Widget build(BuildContext context) {
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

            if (showGamificationHeader) {
              slivers.add(HomeGamificationAppBar(userId: user.uid));
            } else {
              slivers.add(_HomePinnedTitleAppBar(strings: strings));
            }

            double nextTopPadding = 24;

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
              nextTopPadding = 16;
            }

            const EdgeInsets accountsPadding = EdgeInsets.fromLTRB(8, 16, 8, 0);
            const EdgeInsets transactionsHeaderPadding = EdgeInsets.fromLTRB(
              8,
              24,
              8,
              8,
            );
            const EdgeInsets transactionsContentPadding = EdgeInsets.fromLTRB(
              8,
              0,
              8,
              12,
            );

            final Widget accountsSection = accountsAsync.when(
              data: (List<AccountEntity> accounts) => _AccountsList(
                accounts: accounts,
                strings: strings,
                monthlySummaries:
                    accountSummariesAsync.asData?.value ??
                    const <String, HomeAccountMonthlySummary>{},
                isWideLayout: showSecondaryPanel,
              ),
              loading: () => const _TransactionsSkeletonList(),
              error: (Object error, _) => _ErrorMessage(
                message: strings.homeAccountsError(error.toString()),
              ),
            );

            final Widget transactionsSliver = groupedTransactionsAsync.when(
              data: (List<DaySection> sections) {
                if (sections.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _EmptyMessage(
                      message: strings.homeTransactionsEmpty,
                    ),
                  );
                }
                return _TransactionsSliver(
                  sections: sections,
                  localeName: strings.localeName,
                  strings: strings,
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              error: (Object error, _) => SliverToBoxAdapter(
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
                        icon: const Icon(Icons.add),
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
                HomeBudgetProgressCard(
                  preferences: dashboardPreferences,
                  onConfigure: () {
                    context.push(GeneralSettingsScreen.routeName);
                  },
                ),
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
                padding: transactionsHeaderPadding,
                sliver: SliverToBoxAdapter(
                  child: _SectionHeader(title: strings.homeTransactionsSection),
                ),
              ),
            );
            slivers.add(
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                sliver: SliverToBoxAdapter(
                  child: _TransactionsFilterBar(strings: strings),
                ),
              ),
            );
            slivers.add(
              SliverPadding(
                padding: transactionsContentPadding,
                sliver: transactionsSliver,
              ),
            );
            slivers.add(
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 20),
                sliver: SliverToBoxAdapter(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        context.push(AllTransactionsScreen.routeName);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary.withValues(
                          alpha: 0.9,
                        ),
                      ),
                      child: Text(strings.homeTransactionsSeeAll),
                    ),
                  ),
                ),
              ),
            );

            return CustomScrollView(slivers: slivers);
          },
        );
      },
    );
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
        children.add(const SizedBox(height: 16));
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
      addSection(
        HomeBudgetProgressCard(
          preferences: preferences,
          onConfigure: () {
            context.push(GeneralSettingsScreen.routeName);
          },
        ),
      );
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
        Card(
          color: theme.colorScheme.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  strings.settingsHomeSectionTitle,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  strings.homeBudgetWidgetEmpty,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
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

class _HomePinnedTitleAppBar extends StatelessWidget {
  const _HomePinnedTitleAppBar({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double topPadding = MediaQuery.of(context).padding.top;

    return SliverAppBar(
      automaticallyImplyLeading: false,
      floating: false,
      pinned: false,
      snap: false,
      elevation: 4,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      toolbarHeight: HomeGamificationAppBar.appBarHeight,
      collapsedHeight: topPadding + HomeGamificationAppBar.appBarHeight,
      expandedHeight: topPadding + HomeGamificationAppBar.appBarHeight,
      titleSpacing: 20,
      title: Text(
        'Копим',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: <Widget>[
        Semantics(
          label: strings.homeProfileTooltip,
          button: true,
          child: IconButton(
            tooltip: strings.homeProfileTooltip,
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              context.push(ProfileManagementScreen.routeName);
            },
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _AddTransactionButton extends StatelessWidget {
  const _AddTransactionButton({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return KopimFloatingActionButton(
      onPressed: () async {
        final TransactionFormResult? result = await Navigator.of(context)
            .push<TransactionFormResult>(
              MaterialPageRoute<TransactionFormResult>(
                builder: (_) => const AddTransactionScreen(),
              ),
            );
        if (!context.mounted || result == null) {
          return;
        }
        final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar();
        final TransactionEntity? createdTransaction = result.createdTransaction;
        if (createdTransaction == null) {
          messenger.showSnackBar(
            SnackBar(content: Text(strings.addTransactionSuccess)),
          );
          return;
        }
        messenger.showSnackBar(
          SnackBar(
            content: Text(strings.addTransactionSuccess),
            action: SnackBarAction(
              label: strings.commonUndo,
              onPressed: () {
                final ProviderContainer container = ProviderScope.containerOf(
                  context,
                );
                container
                    .read(transactionActionsControllerProvider.notifier)
                    .deleteTransaction(createdTransaction.id)
                    .then((bool undone) {
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              undone
                                  ? strings.addTransactionUndoSuccess
                                  : strings.addTransactionUndoError,
                            ),
                          ),
                        );
                      container
                          .read(transactionActionsControllerProvider.notifier)
                          .reset();
                    });
              },
            ),
          ),
        );
      },
      icon: const Icon(Icons.add),
    );
  }
}

class _AccountsList extends StatefulWidget {
  const _AccountsList({
    required this.accounts,
    required this.strings,
    required this.monthlySummaries,
    required this.isWideLayout,
  });

  final List<AccountEntity> accounts;
  final AppLocalizations strings;
  final Map<String, HomeAccountMonthlySummary> monthlySummaries;
  final bool isWideLayout;

  @override
  State<_AccountsList> createState() => _AccountsListState();
}

class _AccountsListState extends State<_AccountsList> {
  late PageController _pageController;
  late double _viewportFraction;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _viewportFraction = 0.85;
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
    final int initialPage = _pageController.hasClients
        ? _pageController.page?.round().clamp(0, widget.accounts.length - 1) ??
              0
        : _currentPage.clamp(0, widget.accounts.length - 1);
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

  @override
  Widget build(BuildContext context) {
    if (widget.accounts.isEmpty) {
      return _EmptyMessage(message: widget.strings.homeAccountsEmpty);
    }

    final ThemeData theme = Theme.of(context);
    final String localeName = widget.strings.localeName;

    if (widget.isWideLayout) {
      return Column(
        children: <Widget>[
          for (final AccountEntity account in widget.accounts)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: _AccountCard(
                account: account,
                strings: widget.strings,
                currencyFormat: NumberFormat.currency(
                  locale: localeName,
                  symbol: account.currency.toUpperCase(),
                ),
                summary:
                    widget.monthlySummaries[account.id] ??
                    const HomeAccountMonthlySummary(income: 0, expense: 0),
              ),
            ),
        ],
      );
    }

    final int maxIndex = widget.accounts.length - 1;
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
        final double targetFraction = widget.accounts.length == 1
            ? 0.95
            : (isCarouselWide ? 0.45 : 0.85);
        final double cardHeight = isCarouselWide ? 160 : 132;
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
                itemCount: widget.accounts.length,
                onPageChanged: (int index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  final AccountEntity account = widget.accounts[index];
                  final NumberFormat currencyFormat = NumberFormat.currency(
                    locale: localeName,
                    symbol: account.currency.toUpperCase(),
                  );
                  final HomeAccountMonthlySummary summary =
                      widget.monthlySummaries[account.id] ??
                      const HomeAccountMonthlySummary(income: 0, expense: 0);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _AccountCard(
                      account: account,
                      strings: widget.strings,
                      currencyFormat: currencyFormat,
                      summary: summary,
                    ),
                  );
                },
              ),
            ),
            if (widget.accounts.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(widget.accounts.length, (
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

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.strings,
    required this.currencyFormat,
    required this.summary,
  });

  final AccountEntity account;
  final AppLocalizations strings;
  final NumberFormat currencyFormat;
  final HomeAccountMonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      surfaceTintColor: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          context.push(
            AccountDetailsScreenArgs(accountId: account.id).location,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        Text(account.name, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          _resolveAccountTypeLabel(strings, account.type),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topRight,
                        child: Text(
                          currencyFormat.format(account.balance),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _AccountMonthlyValue(
                      label: strings.homeAccountMonthlyIncomeLabel,
                      value: currencyFormat.format(summary.income),
                      valueColor: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AccountMonthlyValue(
                      label: strings.homeAccountMonthlyExpenseLabel,
                      value: currencyFormat.format(summary.expense),
                      valueColor: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _resolveAccountTypeLabel(AppLocalizations strings, String type) {
  final String normalized = type.trim();
  if (normalized.isEmpty) {
    return strings.accountTypeOther;
  }
  final String stripped = stripCustomAccountPrefix(normalized);
  if (stripped.isEmpty) {
    return strings.accountTypeOther;
  }
  final String lower = stripped.toLowerCase();
  switch (lower) {
    case 'cash':
      return strings.accountTypeCash;
    case 'card':
      return strings.accountTypeCard;
    case 'bank':
      return strings.accountTypeBank;
    case 'other':
      return strings.accountTypeOther;
    default:
      return stripped;
  }
}

class _AccountMonthlyValue extends StatelessWidget {
  const _AccountMonthlyValue({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(color: valueColor),
        ),
      ],
    );
  }
}

class _TransactionsSliver extends StatelessWidget {
  const _TransactionsSliver({
    required this.sections,
    required this.localeName,
    required this.strings,
  });

  final List<DaySection> sections;
  final String localeName;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
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
      entries.add(_TransactionHeaderEntry(title: title));
      for (final TransactionEntity transaction in section.transactions) {
        entries.add(_TransactionItemEntry(transactionId: transaction.id));
      }
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final _TransactionSliverEntry entry = entries[index];
          if (entry is _TransactionHeaderEntry) {
            return Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : 24, bottom: 8),
              child: Text(
                entry.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }
          if (entry is _TransactionItemEntry) {
            return _TransactionListItem(
              transactionId: entry.transactionId,
              localeName: localeName,
              strings: strings,
            );
          }
          return const SizedBox.shrink();
        },
        childCount: entries.length,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
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

    TextButton buildFilterButton(HomeTransactionsFilter filter, String label) {
      final bool isSelected = selected == filter;
      final TextStyle baseStyle =
          theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
      final TextStyle style = baseStyle.copyWith(
        fontWeight: isSelected ? FontWeight.w600 : baseStyle.fontWeight,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.68),
      );
      return TextButton(
        onPressed: () => ref
            .read(homeTransactionsFilterControllerProvider.notifier)
            .update(filter),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(label, style: style),
      );
    }

    return Row(
      children: <Widget>[
        buildFilterButton(
          HomeTransactionsFilter.all,
          strings.homeTransactionsFilterAll,
        ),
        const SizedBox(width: 12),
        buildFilterButton(
          HomeTransactionsFilter.income,
          strings.homeTransactionsFilterIncome,
        ),
        const SizedBox(width: 12),
        buildFilterButton(
          HomeTransactionsFilter.expense,
          strings.homeTransactionsFilterExpense,
        ),
      ],
    );
  }
}

sealed class _TransactionSliverEntry {
  const _TransactionSliverEntry();
}

class _TransactionHeaderEntry extends _TransactionSliverEntry {
  const _TransactionHeaderEntry({required this.title});

  final String title;
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
    final bool hasTransaction = ref.watch(
      homeTransactionByIdProvider(
        transactionId,
      ).select((TransactionEntity? tx) => tx != null),
    );

    if (!hasTransaction) {
      return const _TransactionTileSkeleton();
    }

    final String? accountId = ref.watch(
      homeTransactionByIdProvider(
        transactionId,
      ).select((TransactionEntity? tx) => tx?.accountId),
    );
    final String? categoryId = ref.watch(
      homeTransactionByIdProvider(
        transactionId,
      ).select((TransactionEntity? tx) => tx?.categoryId),
    );
    final double? amount = ref.watch(
      homeTransactionByIdProvider(
        transactionId,
      ).select((TransactionEntity? tx) => tx?.amount),
    );
    final String? note = ref.watch(
      homeTransactionByIdProvider(
        transactionId,
      ).select((TransactionEntity? tx) => tx?.note),
    );
    final String? type = ref.watch(
      homeTransactionByIdProvider(
        transactionId,
      ).select((TransactionEntity? tx) => tx?.type),
    );

    if (amount == null || type == null || accountId == null) {
      return const _TransactionTileSkeleton();
    }

    final String? accountName = ref.watch(
      homeAccountByIdProvider(
        accountId,
      ).select((AccountEntity? account) => account?.name),
    );
    final String? accountCurrency = ref.watch(
      homeAccountByIdProvider(
        accountId,
      ).select((AccountEntity? account) => account?.currency),
    );
    final String currencySymbol = accountCurrency != null
        ? accountCurrency.toUpperCase()
        : TransactionTileFormatters.fallbackCurrencySymbol(localeName);
    final NumberFormat moneyFormat = TransactionTileFormatters.currency(
      localeName,
      currencySymbol,
    );

    final Category? category = categoryId == null
        ? null
        : ref.watch(
            homeCategoryByIdProvider(categoryId).select((Category? cat) => cat),
          );
    final String categoryName =
        category?.name ?? strings.homeTransactionsUncategorized;
    final PhosphorIconData? categoryIcon = resolvePhosphorIconData(
      category?.icon,
    );
    final Color? categoryColor = parseHexColor(category?.color);
    final Color avatarIconColor = categoryColor != null
        ? (ThemeData.estimateBrightnessForColor(categoryColor) ==
                  Brightness.dark
              ? Colors.white
              : Colors.black87)
        : Theme.of(context).colorScheme.onSurfaceVariant;

    final bool isExpense = type == TransactionType.expense.storageValue;
    final Color amountColor = isExpense
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return Dismissible(
      key: ValueKey<String>(transactionId),
      direction: DismissDirection.endToStart,
      background: buildDeleteBackground(Theme.of(context).colorScheme.error),
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
            onTap: () {
              final TransactionEntity? transaction = ref.read(
                homeTransactionByIdProvider(transactionId),
              );
              if (transaction == null) {
                return;
              }
              showTransactionEditorSheet(
                context: context,
                ref: ref,
                transaction: transaction,
                submitLabel: strings.editTransactionSubmit,
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        categoryColor ??
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    foregroundColor: avatarIconColor,
                    child: categoryIcon != null
                        ? Icon(categoryIcon, size: 22)
                        : const Icon(Icons.category_outlined, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          categoryName,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.68),
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        moneyFormat.format(amount.abs()),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: amountColor,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      if (accountName != null)
                        Text(
                          accountName,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.68),
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
      return Text(title, style: style);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
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
