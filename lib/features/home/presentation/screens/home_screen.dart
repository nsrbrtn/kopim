import 'dart:math' as math;
import 'dart:ui' as ui show TextDirection;

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/presentation/account_details_screen.dart';
import 'package:kopim/features/accounts/presentation/accounts_add_screen.dart';
import 'package:kopim/features/app_shell/presentation/models/navigation_tab_content.dart';
import 'package:kopim/features/app_shell/presentation/widgets/navigation_responsive_breakpoints.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/features/home/domain/models/day_section.dart';
import 'package:kopim/features/home/domain/models/home_account_monthly_summary.dart';
import 'package:kopim/features/home/presentation/controllers/home_dashboard_preferences_controller.dart';
import 'package:kopim/features/home/presentation/controllers/home_transactions_filter_controller.dart';
import 'package:kopim/features/home/presentation/widgets/home_budget_progress_card.dart';
import 'package:kopim/features/home/presentation/widgets/home_gamification_app_bar.dart';
import 'package:kopim/features/home/presentation/widgets/home_savings_overview_card.dart';
import 'package:kopim/features/home/presentation/widgets/home_upcoming_items_card.dart';
import 'package:kopim/core/widgets/kopim_glass_fab.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/presentation/add_transaction_screen.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_actions_controller.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_editor.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_tile_formatters.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_form_view.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:kopim/core/formatting/currency_symbols.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/collapsible_list/collapsible_list.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/features/profile/presentation/screens/profile_management_screen.dart';
import 'package:kopim/features/transactions/presentation/screens/all_transactions_screen.dart';
import 'package:kopim/features/savings/presentation/screens/saving_goal_details_screen.dart';
import 'package:kopim/features/upcoming_payments/domain/models/upcoming_item.dart';
import 'package:kopim/features/upcoming_payments/domain/providers/upcoming_payments_providers.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/features/upcoming_payments/presentation/screens/upcoming_payments_screen.dart';
import 'package:kopim/features/home/presentation/widgets/top_bar_avatar_icon.dart';

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
              slivers.add(
                _HomePinnedTitleAppBar(strings: strings, userId: user?.uid),
              );
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
              nextTopPadding = 0;
            }

            const EdgeInsets accountsPadding = EdgeInsets.fromLTRB(8, 16, 8, 0);
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
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 20),
                sliver: SliverToBoxAdapter(child: transactionsSection),
              ),
            );
            slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 80)));

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

class _AddTransactionButton extends StatelessWidget {
  const _AddTransactionButton({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return KopimGlassFab(
      icon: Icon(Icons.add, color: colorScheme.primary),
      foregroundColor: colorScheme.primary,
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
                    });
              },
            ),
          ),
        );
      },
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
    if (widget.accounts.isEmpty) {
      return _EmptyMessage(message: widget.strings.homeAccountsEmpty);
    }

    final ThemeData theme = Theme.of(context);
    final String localeName = widget.strings.localeName;

    if (widget.isWideLayout) {
      return Column(
        children: <Widget>[
          for (int i = 0; i < widget.accounts.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: _AccountCard(
                account: widget.accounts[i],
                strings: widget.strings,
                currencyFormat: NumberFormat.currency(
                  locale: localeName,
                  symbol: resolveCurrencySymbol(
                    widget.accounts[i].currency,
                    locale: localeName,
                  ),
                ),
                summary:
                    widget.monthlySummaries[widget.accounts[i].id] ??
                    const HomeAccountMonthlySummary(income: 0, expense: 0),
                isHighlighted: i == 0,
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
        final double baseFraction = widget.accounts.length == 1
            ? 0.95
            : (isCarouselWide ? 0.45 : 0.85);
        final double requiredFraction = _calculateRequiredFraction(
          context: context,
          constraints: constraints,
          localeName: localeName,
        );
        final double targetFraction = math.min(
          0.98,
          math.max(baseFraction, requiredFraction),
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
                    symbol: resolveCurrencySymbol(
                      account.currency,
                      locale: localeName,
                    ),
                    decimalDigits: 0,
                  );
                  final HomeAccountMonthlySummary summary =
                      widget.monthlySummaries[account.id] ??
                      const HomeAccountMonthlySummary(income: 0, expense: 0);

                  final bool isLast = index == widget.accounts.length - 1;
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
            const SizedBox(height: 8),
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
    required this.isHighlighted,
  });

  final AccountEntity account;
  final AppLocalizations strings;
  final NumberFormat currencyFormat;
  final HomeAccountMonthlySummary summary;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color? accountColor = parseHexColor(account.color);
    final _AccountCardPalette palette = _AccountCardPalette.fromAccount(
      colorScheme: theme.colorScheme,
      accountColor: accountColor,
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
            color: palette.background,
            borderRadius: borderRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  account.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(account.balance),
                  style: balanceStyle,
                  softWrap: true,
                ),
                const SizedBox(height: 16),
                Text(
                  strings.analyticsCurrentMonthTitle,
                  style: summaryHeaderStyle,
                ),
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
            ),
          ),
        ),
      ),
    );
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
    required bool isHighlighted,
  }) {
    final Color defaultBackground = isHighlighted
        ? colorScheme.primary
        : colorScheme.tertiary;
    final Color background = accountColor ?? defaultBackground;
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

    return padding + label + balance + summaryTitle + (summaryValue * 2) + gaps;
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
    entries.add(_TransactionHeaderEntry(title: title));
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
        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 24, bottom: 8),
            child: Text(entry.title, style: theme.textTheme.titleMedium),
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

    final ThemeData theme = Theme.of(context);
    final ({String? name, String? currency}) accountData = ref.watch(
      homeAccountByIdProvider(accountId).select(
        (AccountEntity? account) =>
            (name: account?.name, currency: account?.currency),
      ),
    );
    final String currencySymbol = accountData.currency != null
        ? resolveCurrencySymbol(accountData.currency!, locale: localeName)
        : TransactionTileFormatters.fallbackCurrencySymbol(localeName);
    final NumberFormat moneyFormat = TransactionTileFormatters.currency(
      localeName,
      currencySymbol,
      decimalDigits: 0,
    );

    final ({
      String? name,
      PhosphorIconDescriptor? icon,
      String? color,
    }) categoryData =
        categoryId == null
            ? (name: null, icon: null, color: null)
            : ref.watch(
                homeCategoryByIdProvider(categoryId).select(
                  (Category? cat) =>
                      (name: cat?.name, icon: cat?.icon, color: cat?.color),
                ),
              );
    final String categoryName =
        categoryData.name ?? strings.homeTransactionsUncategorized;
    final PhosphorIconData? categoryIcon =
        resolvePhosphorIconData(categoryData.icon);
    final Color? categoryColor = parseHexColor(categoryData.color);
    final Color avatarIconColor = categoryColor != null
        ? (ThemeData.estimateBrightnessForColor(categoryColor) ==
                  Brightness.dark
              ? Colors.white
              : Colors.black87)
        : Theme.of(context).colorScheme.onSurfaceVariant;

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
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          categoryColor ??
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        categoryIcon ?? Icons.category_outlined,
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
                        Text(
                          categoryName,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
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
                      if (accountData.name != null)
                        Text(
                          accountData.name!,
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
