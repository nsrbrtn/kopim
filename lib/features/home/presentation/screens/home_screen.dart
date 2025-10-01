import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/presentation/account_details_screen.dart';
import 'package:kopim/features/accounts/presentation/accounts_add_screen.dart';
import 'package:kopim/features/app_shell/presentation/models/navigation_tab_content.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/home/domain/models/home_account_monthly_summary.dart';
import 'package:kopim/features/home/presentation/utils/transaction_grouping.dart';
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
  final AsyncValue<List<TransactionEntity>> transactionsAsync = ref.watch(
    homeRecentTransactionsProvider(),
  );
  final AsyncValue<List<AccountEntity>> accountsAsync = ref.watch(
    homeAccountsProvider,
  );
  final AsyncValue<Map<String, HomeAccountMonthlySummary>>
  accountSummariesAsync = ref.watch(homeAccountMonthlySummariesProvider);
  final AsyncValue<List<Category>> categoriesAsync = ref.watch(
    homeCategoriesProvider,
  );
  final double totalBalance = ref.watch(homeTotalBalanceProvider);
  final bool isWideLayout = MediaQuery.of(context).size.width >= 720;
  final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
    locale: strings.localeName,
  );

  final String appBarTitle = accountsAsync.maybeWhen(
    data: (List<AccountEntity> accounts) {
      if (accounts.isEmpty) {
        return strings.homeTitle;
      }
      return strings.homeTotalBalance(currencyFormat.format(totalBalance));
    },
    orElse: () => strings.homeTitle,
  );

  return NavigationTabContent(
    appBarBuilder: (BuildContext context, WidgetRef ref) =>
        AppBar(title: Text(appBarTitle)),
    bodyBuilder: (BuildContext context, WidgetRef ref) => SafeArea(
      child: _HomeBody(
        authState: authState,
        transactionsAsync: transactionsAsync,
        accountsAsync: accountsAsync,
        categoriesAsync: categoriesAsync,
        strings: strings,
        isWideLayout: isWideLayout,
        accountSummariesAsync: accountSummariesAsync,
      ),
    ),
    floatingActionButtonBuilder: (BuildContext context, WidgetRef ref) =>
        _AddTransactionButton(strings: strings),
  );
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.authState,
    required this.transactionsAsync,
    required this.accountsAsync,
    required this.categoriesAsync,
    required this.strings,
    required this.isWideLayout,
    required this.accountSummariesAsync,
  });

  final AsyncValue<AuthUser?> authState;
  final AsyncValue<List<TransactionEntity>> transactionsAsync;
  final AsyncValue<List<AccountEntity>> accountsAsync;
  final AsyncValue<List<Category>> categoriesAsync;
  final AppLocalizations strings;
  final bool isWideLayout;
  final AsyncValue<Map<String, HomeAccountMonthlySummary>>
  accountSummariesAsync;

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
            final EdgeInsets padding = EdgeInsets.symmetric(
              horizontal: isWideLayout ? constraints.maxWidth * 0.1 : 16,
              vertical: 16,
            );
            return ListView(
              padding: padding,
              children: <Widget>[
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
                accountsAsync.when(
                  data: (List<AccountEntity> accounts) => _AccountsList(
                    accounts: accounts,
                    strings: strings,
                    monthlySummaries:
                        accountSummariesAsync.asData?.value ??
                        const <String, HomeAccountMonthlySummary>{},
                  ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (Object error, _) => _ErrorMessage(
                    message: strings.homeAccountsError(error.toString()),
                  ),
                ),
                const SizedBox(height: 32),
                _SectionHeader(title: strings.homeTransactionsSection),
                const SizedBox(height: 12),
                transactionsAsync.when(
                  data: (List<TransactionEntity> transactions) {
                    final List<AccountEntity> accounts =
                        accountsAsync.asData?.value ?? const <AccountEntity>[];
                    return categoriesAsync.when(
                      data: (List<Category> categories) => _TransactionsList(
                        transactions: transactions,
                        localeName: strings.localeName,
                        strings: strings,
                        accountsById: <String, AccountEntity>{
                          for (final AccountEntity account in accounts)
                            account.id: account,
                        },
                        categoriesById: <String, Category>{
                          for (final Category category in categories)
                            category.id: category,
                        },
                      ),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (Object error, _) => _ErrorMessage(
                        message: strings.homeTransactionsError(
                          error.toString(),
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (Object error, _) => _ErrorMessage(
                    message: strings.homeTransactionsError(error.toString()),
                  ),
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
              height: 240,
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
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
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
                              const SizedBox(height: 16),
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

class _TransactionsList extends ConsumerWidget {
  const _TransactionsList({
    required this.transactions,
    required this.localeName,
    required this.strings,
    required this.accountsById,
    required this.categoriesById,
  });

  final List<TransactionEntity> transactions;
  final String localeName;
  final AppLocalizations strings;
  final Map<String, AccountEntity> accountsById;
  final Map<String, Category> categoriesById;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (transactions.isEmpty) {
      return _EmptyMessage(message: strings.homeTransactionsEmpty);
    }

    final ThemeData theme = Theme.of(context);
    final List<TransactionListSection> sections = groupTransactionsByDay(
      transactions: transactions,
      today: DateTime.now(),
      localeName: localeName,
      todayLabel: strings.homeTransactionsTodayLabel,
    );
    final List<Object> items = <Object>[];
    for (final TransactionListSection section in sections) {
      items
        ..add(section.title)
        ..addAll(section.transactions);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final Object item = items[index];
        if (item is String) {
          return Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : 24, bottom: 8),
            child: Text(item, style: theme.textTheme.titleMedium),
          );
        }

        final TransactionEntity transaction = item as TransactionEntity;
        final bool isExpense =
            transaction.type == TransactionType.expense.storageValue;
        final AccountEntity? account = accountsById[transaction.accountId];
        final NumberFormat format = NumberFormat.currency(
          locale: localeName,
          symbol:
              account?.currency.toUpperCase() ??
              NumberFormat.simpleCurrency(locale: localeName).currencySymbol,
        );
        final String amountText = format.format(transaction.amount.abs());
        final Category? category = transaction.categoryId == null
            ? null
            : categoriesById[transaction.categoryId!];
        final String categoryName =
            category?.name ?? strings.homeTransactionsUncategorized;
        final PhosphorIconData? categoryIcon = resolvePhosphorIconData(
          category?.icon,
        );
        final Color? categoryColor = parseHexColor(category?.color);
        final String? note = transaction.note;
        final Color amountColor = isExpense
            ? theme.colorScheme.error
            : theme.colorScheme.primary;
        final Color avatarIconColor = categoryColor != null
            ? (ThemeData.estimateBrightnessForColor(categoryColor) ==
                      Brightness.dark
                  ? Colors.white
                  : Colors.black87)
            : theme.colorScheme.onSurfaceVariant;

        return Dismissible(
          key: ValueKey<String>(transaction.id),
          direction: DismissDirection.endToStart,
          background: buildDeleteBackground(theme.colorScheme.error),
          confirmDismiss: (DismissDirection direction) async {
            return deleteTransactionWithFeedback(
              context: context,
              ref: ref,
              transactionId: transaction.id,
              strings: strings,
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              onTap: () => showTransactionEditorSheet(
                context: context,
                ref: ref,
                transaction: transaction,
                submitLabel: strings.editTransactionSubmit,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor:
                          categoryColor ??
                          theme.colorScheme.surfaceContainerHighest,
                      foregroundColor: avatarIconColor,
                      child: categoryIcon != null
                          ? Icon(categoryIcon)
                          : const Icon(Icons.category_outlined),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(categoryName, style: theme.textTheme.bodyMedium),
                          if (note != null && note.isNotEmpty)
                            Text(note, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          amountText,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: amountColor,
                          ),
                        ),
                        if (account != null)
                          Text(account.name, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
