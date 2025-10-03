import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/presentation/account_details_screen.dart';
import 'package:kopim/features/accounts/presentation/accounts_add_screen.dart';
import 'package:kopim/features/app_shell/presentation/models/navigation_tab_content.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/home/domain/models/day_section.dart';
import 'package:kopim/features/home/domain/models/home_account_monthly_summary.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/presentation/add_transaction_screen.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_editor.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';

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
  final bool isWideLayout = MediaQuery.of(context).size.width >= 720;

  return NavigationTabContent(
    appBarBuilder: (BuildContext context, WidgetRef ref) =>
        AppBar(title: Text(strings.homeTitle)),
    bodyBuilder: (BuildContext context, WidgetRef ref) => SafeArea(
      child: _HomeBody(
        authState: authState,
        accountsAsync: accountsAsync,
        strings: strings,
        isWideLayout: isWideLayout,
        accountSummariesAsync: accountSummariesAsync,
        groupedTransactionsAsync: groupedTransactionsAsync,
      ),
    ),
    floatingActionButtonBuilder: (BuildContext context, WidgetRef ref) =>
        _AddTransactionButton(strings: strings),
  );
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.authState,
    required this.accountsAsync,
    required this.strings,
    required this.isWideLayout,
    required this.accountSummariesAsync,
    required this.groupedTransactionsAsync,
  });

  final AsyncValue<AuthUser?> authState;
  final AsyncValue<List<AccountEntity>> accountsAsync;
  final AppLocalizations strings;
  final bool isWideLayout;
  final AsyncValue<Map<String, HomeAccountMonthlySummary>>
  accountSummariesAsync;
  final AsyncValue<List<DaySection>> groupedTransactionsAsync;

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
      data: (_) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double horizontalPadding = isWideLayout
                ? constraints.maxWidth * 0.1
                : 16;
            final EdgeInsets accountsPadding = EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              0,
            );
            final EdgeInsets transactionsHeaderPadding = EdgeInsets.fromLTRB(
              horizontalPadding,
              32,
              horizontalPadding,
              12,
            );
            final EdgeInsets transactionsContentPadding = EdgeInsets.fromLTRB(
              horizontalPadding,
              0,
              horizontalPadding,
              16,
            );

            final Widget accountsSection = accountsAsync.when(
              data: (List<AccountEntity> accounts) => _AccountsList(
                accounts: accounts,
                strings: strings,
                monthlySummaries:
                    accountSummariesAsync.asData?.value ??
                    const <String, HomeAccountMonthlySummary>{},
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

            return CustomScrollView(
              slivers: <Widget>[
                SliverPadding(
                  padding: accountsPadding,
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(<Widget>[
                      _SectionHeader(
                        title: strings.homeAccountsSection,
                        action: IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: strings.homeAccountsAddTooltip,
                          onPressed: () => Navigator.of(
                            context,
                          ).pushNamed(AddAccountScreen.routeName),
                        ),
                      ),
                      const SizedBox(height: 12),
                      accountsSection,
                    ]),
                  ),
                ),
                SliverPadding(
                  padding: transactionsHeaderPadding,
                  sliver: SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: strings.homeTransactionsSection,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: transactionsContentPadding,
                  sliver: transactionsSliver,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AddTransactionButton extends StatelessWidget {
  const _AddTransactionButton({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        final bool? created = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(builder: (_) => const AddTransactionScreen()),
        );
        if (created == true && context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(strings.addTransactionSuccess)),
            );
        }
      },
      child: const Icon(Icons.add),
    );
  }
}

class _AccountsList extends StatefulWidget {
  const _AccountsList({
    required this.accounts,
    required this.strings,
    required this.monthlySummaries,
  });

  final List<AccountEntity> accounts;
  final AppLocalizations strings;
  final Map<String, HomeAccountMonthlySummary> monthlySummaries;

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

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isWide = constraints.maxWidth >= 720;
        final double targetFraction = widget.accounts.length == 1
            ? 0.95
            : (isWide ? 0.45 : 0.85);
        if ((_viewportFraction - targetFraction).abs() > 0.001) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _updateViewportFraction(targetFraction);
          });
        }

        return Column(
          children: <Widget>[
            SizedBox(
              height: 160,
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
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Card(
                      elevation: 0,
                      clipBehavior: Clip.antiAlias,
                      surfaceTintColor: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AccountDetailsScreen.routeName,
                            arguments: AccountDetailsScreenArgs(
                              accountId: account.id,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          account.name,
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _resolveAccountTypeLabel(
                                            widget.strings,
                                            account.type,
                                          ),
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    currencyFormat.format(account.balance),
                                    textAlign: TextAlign.right,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: _AccountMonthlyValue(
                                      label: widget
                                          .strings
                                          .homeAccountMonthlyIncomeLabel,
                                      value: currencyFormat.format(
                                        summary.income,
                                      ),
                                      valueColor: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _AccountMonthlyValue(
                                      label: widget
                                          .strings
                                          .homeAccountMonthlyExpenseLabel,
                                      value: currencyFormat.format(
                                        summary.expense,
                                      ),
                                      valueColor: theme.colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (widget.accounts.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(widget.accounts.length, (
                    int index,
                  ) {
                    final bool isActive = index == _currentPage;
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

String _resolveAccountTypeLabel(AppLocalizations strings, String type) {
  switch (type.toLowerCase()) {
    case 'cash':
      return strings.accountTypeCash;
    case 'card':
      return strings.accountTypeCard;
    case 'bank':
      return strings.accountTypeBank;
    default:
      return strings.accountTypeOther;
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
        Text(label, style: theme.textTheme.bodySmall),
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
    final DateFormat headerFormat = _TransactionFormatters.dayHeader(
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

  static const double extent = 120;

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
    final DateTime? date = ref.watch(
      homeTransactionByIdProvider(
        transactionId,
      ).select((TransactionEntity? tx) => tx?.date),
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

    if (amount == null || date == null || type == null || accountId == null) {
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
        : _TransactionFormatters.fallbackCurrencySymbol(localeName);
    final NumberFormat moneyFormat = _TransactionFormatters.currency(
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

    final DateFormat timeFormat = _TransactionFormatters.time(localeName);

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
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
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
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor:
                        categoryColor ??
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    foregroundColor: avatarIconColor,
                    child: categoryIcon != null
                        ? Icon(categoryIcon)
                        : const Icon(Icons.category_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          categoryName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeFormat.format(date),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        if (note != null && note.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              note,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
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
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: amountColor),
                      ),
                      if (accountName != null)
                        Text(
                          accountName,
                          style: Theme.of(context).textTheme.bodySmall,
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

class _TransactionFormatters {
  static final Map<String, DateFormat> _timeCache = <String, DateFormat>{};
  static final Map<String, NumberFormat> _currencyCache =
      <String, NumberFormat>{};
  static final Map<String, String> _fallbackSymbols = <String, String>{};
  static final Map<String, DateFormat> _dayHeaderCache = <String, DateFormat>{};

  static DateFormat time(String locale) {
    return _timeCache.putIfAbsent(locale, () => DateFormat.Hm(locale));
  }

  static DateFormat dayHeader(String locale) {
    return _dayHeaderCache.putIfAbsent(locale, () => DateFormat.yMMMMd(locale));
  }

  static NumberFormat currency(String locale, String symbol) {
    final String cacheKey = '$locale|$symbol';
    return _currencyCache.putIfAbsent(
      cacheKey,
      () => NumberFormat.currency(locale: locale, symbol: symbol),
    );
  }

  static String fallbackCurrencySymbol(String locale) {
    return _fallbackSymbols.putIfAbsent(
      locale,
      () => NumberFormat.simpleCurrency(locale: locale).currencySymbol,
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

  static const double _height = _TransactionListItem.extent - 12;

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
