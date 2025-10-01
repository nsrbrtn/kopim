import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/presentation/controllers/account_details_providers.dart';
import 'package:kopim/features/accounts/presentation/edit_account_screen.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_editor.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AccountDetailsScreen extends ConsumerStatefulWidget {
  const AccountDetailsScreen({super.key, required this.accountId});

  static const String routeName = '/accounts/details';

  final String accountId;

  static Route<void> route({required String accountId}) {
    return MaterialPageRoute<void>(
      builder: (_) => AccountDetailsScreen(accountId: accountId),
      settings: const RouteSettings(name: routeName),
    );
  }

  @override
  ConsumerState<AccountDetailsScreen> createState() =>
      _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends ConsumerState<AccountDetailsScreen> {
  bool _filtersExpanded = false;

  void _toggleFilters() {
    setState(() {
      _filtersExpanded = !_filtersExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<AccountEntity?> accountAsync = ref.watch(
      accountDetailsProvider(widget.accountId),
    );
    final AsyncValue<AccountTransactionSummary> summaryAsync = ref.watch(
      accountTransactionSummaryProvider(widget.accountId),
    );
    final AsyncValue<List<TransactionEntity>> transactionsAsync = ref.watch(
      filteredAccountTransactionsProvider(widget.accountId),
    );
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      accountCategoriesProvider,
    );
    return Scaffold(
      appBar: AppBar(
        title: accountAsync.maybeWhen(
          data: (AccountEntity? account) =>
              Text(account?.name ?? strings.accountDetailsTitle),
          orElse: () => Text(strings.accountDetailsTitle),
        ),
        actions: <Widget>[
          accountAsync.maybeWhen(
            data: (AccountEntity? account) => IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: strings.accountDetailsEditTooltip,
              onPressed: account == null
                  ? null
                  : () => _openEditScreen(context, account),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: accountAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, _) => _ErrorMessage(
            message: strings.accountDetailsError(error.toString()),
          ),
          data: (AccountEntity? account) {
            if (account == null) {
              return _ErrorMessage(message: strings.accountDetailsMissing);
            }

            final NumberFormat currencyFormat = NumberFormat.currency(
              locale: strings.localeName,
              symbol: account.currency.toUpperCase(),
            );
            final bool isWideLayout = MediaQuery.of(context).size.width >= 720;
            final EdgeInsets padding = EdgeInsets.symmetric(
              horizontal: isWideLayout
                  ? MediaQuery.of(context).size.width * 0.15
                  : 16,
              vertical: 16,
            );

            final List<Category> categoriesList =
                categoriesAsync.asData?.value ?? const <Category>[];
            final Map<String, Category> categoriesById = <String, Category>{
              for (final Category category in categoriesList)
                category.id: category,
            };
            final AccountTransactionsFilter filterState = ref.watch(
              accountTransactionsFilterControllerProvider(account.id),
            );

            final Widget filterButton = Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                icon: Icon(
                  _filtersExpanded ? Icons.filter_alt_off : Icons.filter_alt,
                ),
                label: Text(
                  filterState.hasActiveFilters
                      ? strings.accountDetailsFiltersButtonActive
                      : strings.accountDetailsFiltersTitle,
                ),
                onPressed: _toggleFilters,
              ),
            );

            final Widget filterPanel = AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _filtersExpanded
                  ? Padding(
                      key: const ValueKey<String>('filters'),
                      padding: const EdgeInsets.only(top: 12),
                      child: _AccountTransactionsFilterPanel(
                        accountId: account.id,
                        filter: filterState,
                        categories: categoriesList,
                        strings: strings,
                      ),
                    )
                  : const SizedBox.shrink(),
            );

            final Widget summarySection = summaryAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, _) => _ErrorMessage(
                message: strings.accountDetailsSummaryError(error.toString()),
              ),
              data: (AccountTransactionSummary summary) => _AccountSummaryCard(
                account: account,
                summary: summary,
                currencyFormat: currencyFormat,
                strings: strings,
              ),
            );

            final Widget transactionsSection = transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, _) => _ErrorMessage(
                message: strings.accountDetailsTransactionsError(
                  error.toString(),
                ),
              ),
              data: (List<TransactionEntity> transactions) {
                if (transactions.isEmpty) {
                  return _EmptyMessage(
                    message: strings.accountDetailsTransactionsEmpty,
                  );
                }

                return Column(
                  children: transactions.map((TransactionEntity transaction) {
                    return _AccountTransactionTile(
                      transaction: transaction,
                      account: account,
                      currencyFormat: currencyFormat,
                      strings: strings,
                      category: transaction.categoryId == null
                          ? null
                          : categoriesById[transaction.categoryId!],
                    );
                  }).toList(),
                );
              },
            );

            return ListView(
              padding: padding,
              children: <Widget>[
                summarySection,
                const SizedBox(height: 24),
                filterButton,
                filterPanel,
                if (_filtersExpanded) const SizedBox(height: 16),
                transactionsSection,
              ],
            );
          },
        ),
      ),
    );
  }

  void _openEditScreen(BuildContext context, AccountEntity account) {
    Navigator.of(context).pushNamed(
      EditAccountScreen.routeName,
      arguments: EditAccountScreenArgs(account: account),
    );
  }
}

class AccountDetailsScreenArgs {
  const AccountDetailsScreenArgs({required this.accountId});

  final String accountId;
}

class _AccountSummaryCard extends StatelessWidget {
  const _AccountSummaryCard({
    required this.account,
    required this.summary,
    required this.currencyFormat,
    required this.strings,
  });

  final AccountEntity account;
  final AccountTransactionSummary summary;
  final NumberFormat currencyFormat;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(account.name, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              strings.accountDetailsBalanceLabel(
                currencyFormat.format(account.balance),
              ),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: _SummaryValue(
                    label: strings.accountDetailsIncomeLabel,
                    value: currencyFormat.format(summary.totalIncome),
                    valueColor: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryValue(
                    label: strings.accountDetailsExpenseLabel,
                    value: currencyFormat.format(summary.totalExpense),
                    valueColor: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({
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

class _AccountTransactionsFilterPanel extends ConsumerWidget {
  const _AccountTransactionsFilterPanel({
    required this.accountId,
    required this.filter,
    required this.categories,
    required this.strings,
  });

  final String accountId;
  final AccountTransactionsFilter filter;
  final List<Category> categories;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AccountTransactionsFilterController controller = ref.read(
      accountTransactionsFilterControllerProvider(accountId).notifier,
    );
    final DateFormat dateFormat = DateFormat.yMMMd(strings.localeName);
    final String dateLabel = filter.dateRange == null
        ? strings.accountDetailsFiltersDateAny
        : '${dateFormat.format(filter.dateRange!.start)} – '
              '${dateFormat.format(filter.dateRange!.end)}';
    final List<Category> sortedCategories = List<Category>.from(categories)
      ..sort((Category a, Category b) => a.name.compareTo(b.name));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.date_range),
          title: Text(strings.accountDetailsFiltersDateLabel),
          subtitle: Text(dateLabel),
          trailing: filter.dateRange != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: strings.accountDetailsFiltersDateClear,
                  onPressed: () => controller.setDateRange(null),
                )
              : null,
          onTap: () async {
            final DateTimeRange? picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialDateRange:
                  filter.dateRange ??
                  DateTimeRange(
                    start: DateTime.now().subtract(const Duration(days: 30)),
                    end: DateTime.now(),
                  ),
            );
            if (picked != null) {
              controller.setDateRange(picked);
            }
          },
        ),
        const SizedBox(height: 12),
        Text(
          strings.accountDetailsFiltersTypeLabel,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: <Widget>[
            ChoiceChip(
              label: Text(strings.accountDetailsFiltersTypeAll),
              selected: filter.type == null,
              onSelected: (_) => controller.setType(null),
            ),
            ChoiceChip(
              label: Text(strings.accountDetailsTypeIncome),
              selected: filter.type == TransactionType.income,
              onSelected: (_) => controller.setType(TransactionType.income),
            ),
            ChoiceChip(
              label: Text(strings.accountDetailsTypeExpense),
              selected: filter.type == TransactionType.expense,
              onSelected: (_) => controller.setType(TransactionType.expense),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: filter.categoryId ?? '',
          decoration: InputDecoration(
            labelText: strings.accountDetailsFiltersCategoryLabel,
          ),
          items: <DropdownMenuItem<String>>[
            DropdownMenuItem<String>(
              value: '',
              child: Text(strings.accountDetailsFiltersCategoryAll),
            ),
            ...sortedCategories.map(
              (Category category) => DropdownMenuItem<String>(
                value: category.id,
                child: Text(category.name),
              ),
            ),
          ],
          onChanged: (String? value) {
            if (value == null || value.isEmpty) {
              controller.setCategory(null);
            } else {
              controller.setCategory(value);
            }
          },
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: filter.hasActiveFilters ? controller.clear : null,
          icon: const Icon(Icons.refresh),
          label: Text(strings.accountDetailsFiltersClear),
        ),
      ],
    );
  }
}

class _AccountTransactionTile extends ConsumerWidget {
  const _AccountTransactionTile({
    required this.transaction,
    required this.account,
    required this.currencyFormat,
    required this.strings,
    this.category,
  });

  final TransactionEntity transaction;
  final AccountEntity account;
  final NumberFormat currencyFormat;
  final AppLocalizations strings;
  final Category? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool isIncome =
        transaction.type == TransactionType.income.storageValue;
    final Color amountColor = isIncome
        ? theme.colorScheme.primary
        : theme.colorScheme.error;
    final String amountText = currencyFormat.format(transaction.amount.abs());
    final PhosphorIconData? categoryIcon = resolvePhosphorIconData(
      category?.icon,
    );
    final Color? categoryColor = parseHexColor(category?.color);
    final Color avatarIconColor = categoryColor != null
        ? (ThemeData.estimateBrightnessForColor(categoryColor) ==
                  Brightness.dark
              ? Colors.white
              : Colors.black87)
        : theme.colorScheme.onSurfaceVariant;
    final DateFormat dateFormat = DateFormat.yMMMd(strings.localeName);

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
                      Text(
                        category?.name ??
                            strings.accountDetailsTransactionsUncategorized,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(transaction.date),
                        style: theme.textTheme.bodySmall,
                      ),
                      if (transaction.note != null &&
                          transaction.note!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            transaction.note!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      amountText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: amountColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isIncome
                          ? strings.accountDetailsTypeIncome
                          : strings.accountDetailsTypeExpense,
                      style: theme.textTheme.bodySmall,
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

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ),
    );
  }
}
