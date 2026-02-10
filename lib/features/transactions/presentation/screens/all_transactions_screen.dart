import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show StreamProviderFamily;
import 'package:intl/intl.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/formatting/currency_symbols.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/presentation/utils/category_gradients.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_tile_formatters.dart';
import 'package:kopim/features/transactions/domain/models/feed_item.dart';
import 'package:kopim/features/transactions/presentation/controllers/all_transactions_providers.dart';
import 'package:kopim/features/transactions/presentation/controllers/all_transactions_filter_controller.dart';
import 'package:kopim/features/credits/presentation/widgets/grouped_credit_payment_tile.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_editor.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_draft_controller.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_form_open_container.dart';
import 'package:kopim/features/home/domain/use_cases/group_transactions_by_day_use_case.dart';
import 'package:kopim/features/home/domain/models/day_section.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:kopim/l10n/app_localizations.dart';

final StreamProviderFamily<List<TagEntity>, String>
_allTransactionsTagsProvider = StreamProvider.autoDispose
    .family<List<TagEntity>, String>((Ref ref, String transactionId) {
      return ref.watch(watchTransactionTagsUseCaseProvider).call(transactionId);
    });

class AllTransactionsScreenArgs {
  const AllTransactionsScreenArgs({this.creditId});

  final String? creditId;
}

class AllTransactionsScreen extends ConsumerWidget {
  const AllTransactionsScreen({this.args, super.key});

  static const String routeName = '/transactions/all';
  final AllTransactionsScreenArgs? args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final String? scopedCreditId = args?.creditId;
    final AsyncValue<List<TransactionEntity>> baseTransactionsAsync = ref.watch(
      filteredTransactionsProvider,
    );
    final AsyncValue<List<CreditEntity>> creditsAsync = ref.watch(
      allTransactionsCreditsProvider,
    );
    final AsyncValue<List<TransactionEntity>> transactionsAsync =
        scopedCreditId == null
        ? baseTransactionsAsync
        : _applyCreditFilterAsync(
            transactionsAsync: baseTransactionsAsync,
            creditsAsync: creditsAsync,
            creditId: scopedCreditId,
          );
    final AsyncValue<List<AccountEntity>> accountsAsync = ref.watch(
      allTransactionsAccountsProvider,
    );
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      allTransactionsCategoriesProvider,
    );

    final Map<String, AccountEntity> accountsMap = <String, AccountEntity>{
      for (final AccountEntity account
          in accountsAsync.asData?.value ?? const <AccountEntity>[])
        account.id: account,
    };
    final Map<String, Category> categoriesMap = <String, Category>{
      for (final Category category
          in categoriesAsync.asData?.value ?? const <Category>[])
        category.id: category,
    };

    return Scaffold(
      appBar: AppBar(title: Text(strings.allTransactionsTitle)),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: _FiltersPanel(
                strings: strings,
                accountsAsync: accountsAsync,
                categoriesAsync: categoriesAsync,
              ),
            ),
            const Divider(height: 0),
            Expanded(
              child: transactionsAsync.when(
                data: (List<TransactionEntity> transactions) {
                  if (transactions.isEmpty) {
                    return _TransactionsEmpty(
                      message: strings.allTransactionsEmpty,
                    );
                  }
                  final GroupTransactionsByDayUseCase useCase = ref.watch(
                    groupTransactionsByDayUseCaseProvider,
                  );
                  final List<DaySection> sections = useCase(
                    transactions: transactions,
                  );
                  return _TransactionsList(
                    sections: sections,
                    strings: strings,
                    accounts: accountsMap,
                    categories: categoriesMap,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (Object error, _) => _TransactionsError(
                  message: strings.allTransactionsError(error.toString()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

AsyncValue<List<TransactionEntity>> _applyCreditFilterAsync({
  required AsyncValue<List<TransactionEntity>> transactionsAsync,
  required AsyncValue<List<CreditEntity>> creditsAsync,
  required String creditId,
}) {
  if (creditsAsync.hasError) {
    return AsyncValue<List<TransactionEntity>>.error(
      creditsAsync.error!,
      creditsAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (creditsAsync.isLoading) {
    return const AsyncValue<List<TransactionEntity>>.loading();
  }
  final CreditEntity? credit = creditsAsync.asData?.value
      .cast<CreditEntity?>()
      .firstWhere(
        (CreditEntity? entity) => entity?.id == creditId,
        orElse: () => null,
      );
  if (credit == null) {
    return const AsyncValue<List<TransactionEntity>>.data(
      <TransactionEntity>[],
    );
  }
  return transactionsAsync.whenData(
    (List<TransactionEntity> transactions) => transactions
        .where(
          (TransactionEntity transaction) =>
              _belongsToCredit(transaction, credit),
        )
        .toList(growable: false),
  );
}

bool _belongsToCredit(TransactionEntity transaction, CreditEntity credit) {
  if (transaction.accountId == credit.accountId ||
      transaction.transferAccountId == credit.accountId) {
    return true;
  }
  final String? categoryId = transaction.categoryId;
  if (categoryId == null || categoryId.isEmpty) {
    return false;
  }
  return categoryId == credit.categoryId ||
      categoryId == credit.interestCategoryId ||
      categoryId == credit.feesCategoryId;
}

class _FiltersPanel extends ConsumerWidget {
  const _FiltersPanel({
    required this.strings,
    required this.accountsAsync,
    required this.categoriesAsync,
  });

  final AppLocalizations strings;
  final AsyncValue<List<AccountEntity>> accountsAsync;
  final AsyncValue<List<Category>> categoriesAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AllTransactionsFilterState filters = ref.watch(
      allTransactionsFilterControllerProvider,
    );
    final DateFormat dateFormat = DateFormat.yMMMd(strings.localeName);
    final List<AccountEntity> accounts =
        accountsAsync.asData?.value ?? const <AccountEntity>[];
    final List<Category> categories =
        categoriesAsync.asData?.value ?? const <Category>[];

    final String dateSubtitle = filters.dateRange == null
        ? strings.allTransactionsFiltersDateAny
        : '${dateFormat.format(filters.dateRange!.start)} — '
              '${dateFormat.format(filters.dateRange!.end)}';

    final String accountSubtitle = accountsAsync.when(
      data: (List<AccountEntity> data) {
        if (filters.accountId == null) {
          return strings.allTransactionsFiltersAccountAny;
        }
        final AccountEntity? match = data.firstWhereOrNull(
          (AccountEntity a) => a.id == filters.accountId,
        );
        return match?.name ?? strings.allTransactionsFiltersAccountAny;
      },
      loading: () => strings.allTransactionsFiltersLoading,
      error: (Object error, _) => strings.allTransactionsFiltersAccountAny,
    );

    final String categorySubtitle = categoriesAsync.when(
      data: (List<Category> data) {
        if (filters.categoryId == null) {
          return strings.allTransactionsFiltersCategoryAny;
        }
        final Category? match = data.firstWhereOrNull(
          (Category c) => c.id == filters.categoryId,
        );
        return match?.name ?? strings.allTransactionsFiltersCategoryAny;
      },
      loading: () => strings.allTransactionsFiltersLoading,
      error: (Object error, _) => strings.allTransactionsFiltersCategoryAny,
    );

    Future<void> selectDateRange() async {
      final DateTimeRange? range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        currentDate: DateTime.now(),
        initialDateRange: filters.dateRange,
        locale: Locale(strings.localeName),
      );
      if (!context.mounted) {
        return;
      }
      ref
          .read(allTransactionsFilterControllerProvider.notifier)
          .setDateRange(range);
    }

    Future<void> selectAccount() async {
      if (accounts.isEmpty) {
        return;
      }
      final String? selection = await showModalBottomSheet<String>(
        context: context,
        builder: (BuildContext sheetContext) {
          return SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.clear),
                  title: Text(strings.allTransactionsFiltersAccountAny),
                  selected: filters.accountId == null,
                  onTap: () => Navigator.of(sheetContext).pop(null),
                ),
                ...accounts.map(
                  (AccountEntity account) => ListTile(
                    title: Text(account.name),
                    selected: filters.accountId == account.id,
                    onTap: () => Navigator.of(sheetContext).pop(account.id),
                  ),
                ),
              ],
            ),
          );
        },
      );
      if (!context.mounted) {
        return;
      }
      ref
          .read(allTransactionsFilterControllerProvider.notifier)
          .setAccount(selection);
    }

    Future<void> selectCategory() async {
      if (categories.isEmpty) {
        return;
      }
      final String? selection = await showModalBottomSheet<String>(
        context: context,
        builder: (BuildContext sheetContext) {
          return SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                    child: const Icon(Icons.all_inclusive, size: 20),
                  ),
                  title: Text(strings.allTransactionsFiltersCategoryAny),
                  selected: filters.categoryId == null,
                  onTap: () => Navigator.of(sheetContext).pop(null),
                ),
                ...categories.map((Category category) {
                  final PhosphorIconData? iconData = resolvePhosphorIconData(
                    category.icon,
                  );
                  final CategoryColorStyle colorStyle =
                      resolveCategoryColorStyle(category.color);
                  final Color? categoryColor = colorStyle.sampleColor;
                  final Gradient? categoryGradient =
                      colorStyle.backgroundGradient;
                  final Color avatarForeground = categoryColor != null
                      ? (ThemeData.estimateBrightnessForColor(categoryColor) ==
                                Brightness.dark
                            ? Colors.white
                            : Colors.black87)
                      : theme.colorScheme.onSurfaceVariant;
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: categoryGradient,
                        color: categoryGradient == null
                            ? (categoryColor ??
                                  theme.colorScheme.surfaceContainerHighest)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        iconData ?? Icons.category_outlined,
                        size: 20,
                        color: avatarForeground,
                      ),
                    ),
                    title: Text(category.name),
                    selected: filters.categoryId == category.id,
                    onTap: () => Navigator.of(sheetContext).pop(category.id),
                  );
                }),
              ],
            ),
          );
        },
      );
      if (!context.mounted) {
        return;
      }
      ref
          .read(allTransactionsFilterControllerProvider.notifier)
          .setCategory(selection);
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(
          Icons.filter_alt_outlined,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          strings.allTransactionsFiltersTitle,
          style: theme.textTheme.titleMedium,
        ),
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.date_range_outlined),
            title: Text(strings.allTransactionsFiltersDate),
            subtitle: Text(dateSubtitle),
            onTap: selectDateRange,
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: Text(strings.allTransactionsFiltersAccount),
            subtitle: Text(accountSubtitle),
            enabled: accounts.isNotEmpty,
            onTap: accounts.isNotEmpty ? selectAccount : null,
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: Text(strings.allTransactionsFiltersCategory),
            subtitle: Text(categorySubtitle),
            enabled: categories.isNotEmpty,
            onTap: categories.isNotEmpty ? selectCategory : null,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: filters.hasFilters
                  ? () => ref
                        .read(allTransactionsFilterControllerProvider.notifier)
                        .clear()
                  : null,
              icon: const Icon(Icons.refresh),
              label: Text(strings.allTransactionsFiltersClear),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionsList extends StatelessWidget {
  const _TransactionsList({
    required this.sections,
    required this.strings,
    required this.accounts,
    required this.categories,
  });

  final List<DaySection> sections;
  final AppLocalizations strings;
  final Map<String, AccountEntity> accounts;
  final Map<String, Category> categories;

  @override
  Widget build(BuildContext context) {
    final List<_FlatItem> flatItems = <_FlatItem>[];
    for (final DaySection section in sections) {
      flatItems.add(_FlatItem.header(section.date));
      for (final FeedItem item in section.items) {
        flatItems.add(_FlatItem.feed(item));
      }
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: flatItems.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final _FlatItem flatItem = flatItems[index];
        return flatItem.when(
          header: (DateTime date) => _DayHeader(date: date, strings: strings),
          feed: (FeedItem item) => item.when(
            transaction: (TransactionEntity transaction) {
              final AccountEntity? account = accounts[transaction.accountId];
              final AccountEntity? transferAccount =
                  transaction.transferAccountId == null
                  ? null
                  : accounts[transaction.transferAccountId!];
              final Category? category = transaction.categoryId == null
                  ? null
                  : categories[transaction.categoryId!];
              return _TransactionListTile(
                transaction: transaction,
                account: account,
                transferAccount: transferAccount,
                category: category,
                strings: strings,
              );
            },
            groupedCreditPayment:
                (
                  String groupId,
                  String creditId,
                  List<TransactionEntity> transactions,
                  Money totalOutflow,
                  DateTime date,
                  String? note,
                ) {
                  final AccountEntity? account =
                      accounts[transactions.first.accountId];
                  final String currencySymbol = account != null
                      ? resolveCurrencySymbol(
                          account.currency,
                          locale: strings.localeName,
                        )
                      : TransactionTileFormatters.fallbackCurrencySymbol(
                          strings.localeName,
                        );
                  return GroupedCreditPaymentTile(
                    group: item as GroupedCreditPaymentFeedItem,
                    currencySymbol: currencySymbol,
                    strings: strings,
                  );
                },
          ),
        );
      },
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.date, required this.strings});
  final DateTime date;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    final DateTime yesterday = today.subtract(const Duration(days: 1));

    String label;
    if (DateUtils.isSameDay(date, today)) {
      label = strings.homeTransactionsTodayLabel;
    } else if (DateUtils.isSameDay(date, yesterday)) {
      label = strings.homeTransactionsYesterdayLabel;
    } else {
      label = DateFormat.yMMMd(strings.localeName).format(date);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4, left: 4),
      child: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

enum _FlatItemType { header, feed }

class _FlatItem {
  const _FlatItem._(this.type, {this.date, this.item});
  const _FlatItem.header(DateTime date)
    : this._(_FlatItemType.header, date: date);
  const _FlatItem.feed(FeedItem item) : this._(_FlatItemType.feed, item: item);

  final _FlatItemType type;
  final DateTime? date;
  final FeedItem? item;

  T when<T>({
    required T Function(DateTime date) header,
    required T Function(FeedItem item) feed,
  }) {
    switch (type) {
      case _FlatItemType.header:
        return header(date!);
      case _FlatItemType.feed:
        return feed(item!);
    }
  }
}

class _TransactionListTile extends ConsumerWidget {
  const _TransactionListTile({
    required this.transaction,
    required this.account,
    required this.transferAccount,
    required this.category,
    required this.strings,
  });

  final TransactionEntity transaction;
  final AccountEntity? account;
  final AccountEntity? transferAccount;
  final Category? category;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AccountEntity? accountValue = account;
    final String currencySymbol = accountValue != null
        ? resolveCurrencySymbol(
            accountValue.currency,
            locale: strings.localeName,
          )
        : TransactionTileFormatters.fallbackCurrencySymbol(strings.localeName);
    final NumberFormat moneyFormat = TransactionTileFormatters.currency(
      strings.localeName,
      currencySymbol,
      decimalDigits:
          transaction.amountScale ?? accountValue?.currencyScale ?? 2,
    );
    final bool isTransfer =
        transaction.type == TransactionType.transfer.storageValue;
    final List<TagEntity> tags = isTransfer
        ? const <TagEntity>[]
        : ref
                  .watch(_allTransactionsTagsProvider(transaction.id))
                  .asData
                  ?.value ??
              const <TagEntity>[];
    final String tagLabel = tags.map((TagEntity tag) => tag.name).join(', ');
    final bool isExpense =
        transaction.type == TransactionType.expense.storageValue;
    final Color amountColor = isTransfer
        ? theme.colorScheme.onSurface
        : (isExpense ? theme.colorScheme.error : theme.colorScheme.primary);
    final PhosphorIconData? iconData = resolvePhosphorIconData(category?.icon);
    final CategoryColorStyle colorStyle = resolveCategoryColorStyle(
      category?.color,
    );
    final Color? categoryColor = colorStyle.sampleColor;
    final Gradient? categoryGradient = colorStyle.backgroundGradient;
    final Color avatarForeground = isTransfer
        ? theme.colorScheme.onPrimaryContainer
        : categoryColor != null
        ? (ThemeData.estimateBrightnessForColor(categoryColor) ==
                  Brightness.dark
              ? Colors.white
              : Colors.black87)
        : theme.colorScheme.onSurfaceVariant;
    final String categoryName =
        category?.name ?? strings.homeTransactionsUncategorized;
    final String title = isTransfer
        ? strings.addTransactionTypeTransfer
        : categoryName;
    final String? note = transaction.note?.trim();
    final DateFormat dateFormat = DateFormat.yMMMd(strings.localeName);
    final String? accountName = account?.name;
    final String? transferAccountName = transferAccount?.name;
    final List<String> subtitleParts = <String>[
      if (isTransfer && accountName != null && transferAccountName != null)
        strings.transactionTransferAccountPair(accountName, transferAccountName)
      else if (accountName != null)
        accountName,
      dateFormat.format(transaction.date),
    ];
    final String subtitle = subtitleParts.join(' • ');

    return Dismissible(
      key: ValueKey<String>(transaction.id),
      direction: DismissDirection.endToStart,
      background: buildDeleteBackground(theme.colorScheme.error),
      confirmDismiss: (DismissDirection direction) =>
          deleteTransactionWithFeedback(
            context: context,
            ref: ref,
            transactionId: transaction.id,
            strings: strings,
          ),
      child: TransactionFormOpenContainer(
        formArgs: TransactionFormArgs(initialTransaction: transaction),
        closedBuilder: (BuildContext context, VoidCallback openContainer) {
          return Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            surfaceTintColor: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              onTap: openContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isTransfer ? null : categoryGradient,
                        color: isTransfer
                            ? theme.colorScheme.primaryContainer
                            : (categoryGradient == null
                                  ? (categoryColor ??
                                        theme
                                            .colorScheme
                                            .surfaceContainerHighest)
                                  : null),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        iconData ??
                            (isTransfer
                                ? Icons.swap_horiz
                                : Icons.category_outlined),
                        color: avatarForeground,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      TransactionTileFormatters.formatAmount(
                        formatter: moneyFormat,
                        amount: transaction.amountValue,
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: amountColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TransactionsEmpty extends StatelessWidget {
  const _TransactionsEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _TransactionsError extends StatelessWidget {
  const _TransactionsError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
}

Widget _buildTitleWithTags({
  required BuildContext context,
  required String title,
  required String tagLabel,
}) {
  final ThemeData theme = Theme.of(context);
  final TextStyle? baseStyle = theme.textTheme.bodyMedium;
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
