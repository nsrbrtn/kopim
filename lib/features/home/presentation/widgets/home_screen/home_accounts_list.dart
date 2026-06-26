import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/home/domain/models/home_account_monthly_summary.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_tile_formatters.dart';
import 'package:kopim/core/formatting/currency_symbols.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'home_account_card.dart';
import 'home_account_card_layout.dart';
import 'home_screen_commons.dart';

class HomeAccountsList extends StatefulWidget {
  const HomeAccountsList({
    super.key,
    required this.accounts,
    required this.hiddenAccounts,
    required this.strings,
    required this.monthlySummaries,
    required this.isWideLayout,
    required this.showHiddenAccounts,
  });

  final List<AccountEntity> accounts;
  final List<AccountEntity> hiddenAccounts;
  final AppLocalizations strings;
  final Map<String, HomeAccountMonthlySummary> monthlySummaries;
  final bool isWideLayout;
  final bool showHiddenAccounts;

  @override
  State<HomeAccountsList> createState() => _HomeAccountsListState();
}

class _HomeAccountsListState extends State<HomeAccountsList> {
  late PageController _pageController;
  late double _viewportFraction;
  int _currentPage = 0;

  List<AccountEntity> get _displayedAccounts => <AccountEntity>[
    ...widget.accounts,
    if (widget.showHiddenAccounts) ...widget.hiddenAccounts,
  ];

  int get _totalItems => _displayedAccounts.length;

  int _resolveActivePage(int maxIndex) {
    if (maxIndex <= 0) {
      return 0;
    }
    if (!_pageController.hasClients) {
      return _currentPage.clamp(0, maxIndex);
    }

    final ScrollPosition position = _pageController.position;
    if (position.maxScrollExtent <= 0) {
      return 0;
    }
    if (position.pixels >= position.maxScrollExtent - 1) {
      return maxIndex;
    }
    final double progress = (position.pixels / position.maxScrollExtent).clamp(
      0.0,
      1.0,
    );
    return (progress * maxIndex).round().clamp(0, maxIndex);
  }

  void _handlePageScroll() {
    if (!mounted) {
      return;
    }
    final int maxIndex = math.max(0, _totalItems - 1);
    final int activePage = _resolveActivePage(maxIndex);
    if (activePage == _currentPage) {
      return;
    }
    setState(() {
      _currentPage = activePage;
    });
  }

  @override
  void initState() {
    super.initState();
    _viewportFraction = _totalItems == 1 ? 1.0 : 0.65;
    _pageController = PageController(viewportFraction: _viewportFraction);
    _pageController.addListener(_handlePageScroll);
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageScroll);
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
    oldController.removeListener(_handlePageScroll);
    newController.addListener(_handlePageScroll);
    setState(() {
      _viewportFraction = fraction;
      _pageController = newController;
      _currentPage = initialPage;
    });
    oldController.dispose();
  }

  Map<String, NumberFormat> _buildCurrencyFormats({
    required List<AccountEntity> accounts,
    required String localeName,
    int? decimalDigits,
  }) {
    final Map<String, NumberFormat> formats = <String, NumberFormat>{};
    for (final AccountEntity account in accounts) {
      formats.putIfAbsent(account.currency, () {
        return TransactionTileFormatters.currency(
          localeName,
          resolveCurrencySymbol(account.currency, locale: localeName),
          decimalDigits: decimalDigits,
        );
      });
    }
    return formats;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasHiddenAccounts = widget.hiddenAccounts.isNotEmpty;
    if (widget.accounts.isEmpty && !hasHiddenAccounts) {
      return HomeEmptyMessage(message: widget.strings.homeAccountsEmpty);
    }

    final ThemeData theme = Theme.of(context);
    final String localeName = widget.strings.localeName;
    final int totalItems = _totalItems;
    final List<AccountEntity> displayedAccounts = _displayedAccounts;

    if (totalItems == 0 && hasHiddenAccounts) {
      return const SizedBox.shrink();
    }

    if (widget.isWideLayout) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double cardHeight = HomeAccountCardLayout.estimateHeight(
            context,
          );
          final double cardWidth = math.min(360, constraints.maxWidth * 0.6);
          final Map<String, NumberFormat> currencyFormats =
              _buildCurrencyFormats(
                accounts: displayedAccounts,
                localeName: localeName,
              );
          return SizedBox(
            height: cardHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.zero,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: totalItems,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (BuildContext context, int index) {
                      final AccountEntity account = displayedAccounts[index];
                      final NumberFormat currencyFormat =
                          currencyFormats[account.currency]!;
                      return SizedBox(
                        width: cardWidth,
                        child: HomeAccountCard(
                          key: ValueKey<String>(account.id),
                          account: account,
                          strings: widget.strings,
                          currencyFormat: currencyFormat,
                          summary:
                              widget.monthlySummaries[account.id] ??
                              HomeAccountMonthlySummary(
                                income: MoneyAmount(
                                  minor: BigInt.zero,
                                  scale: 2,
                                ),
                                expense: MoneyAmount(
                                  minor: BigInt.zero,
                                  scale: 2,
                                ),
                              ),
                          isHighlighted: index == 0,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    final int maxIndex = math.max(0, totalItems - 1);
    final int activePage = _resolveActivePage(maxIndex);

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
        final double targetFraction = math.min(
          isSingleAccount ? 1.0 : 0.98,
          math.max(baseFraction, minScrollableFraction),
        );
        final double baseHeight = HomeAccountCardLayout.estimateHeight(context);
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

        final Map<String, NumberFormat> currencyFormats = _buildCurrencyFormats(
          accounts: displayedAccounts,
          localeName: localeName,
          decimalDigits: 0,
        );
        return Column(
          children: <Widget>[
            SizedBox(
              height: cardHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.zero,
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      padEnds: false,
                      itemCount: totalItems,
                      itemBuilder: (BuildContext context, int index) {
                        final AccountEntity account = displayedAccounts[index];
                        final NumberFormat currencyFormat =
                            currencyFormats[account.currency]!;
                        final HomeAccountMonthlySummary summary =
                            widget.monthlySummaries[account.id] ??
                            HomeAccountMonthlySummary(
                              income: MoneyAmount(minor: BigInt.zero, scale: 2),
                              expense: MoneyAmount(
                                minor: BigInt.zero,
                                scale: 2,
                              ),
                            );

                        final bool isLast = index == totalItems - 1;
                        return Padding(
                          padding: EdgeInsets.only(right: isLast ? 0 : 8),
                          child: HomeAccountCard(
                            key: ValueKey<String>(account.id),
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
                ],
              ),
            ),
            if (totalItems > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(totalItems, (int index) {
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
