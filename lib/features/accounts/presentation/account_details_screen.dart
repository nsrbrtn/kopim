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
import 'package:kopim/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AccountDetailsScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<AccountEntity?> accountAsync = ref.watch(
      accountDetailsProvider(accountId),
    );
    final AsyncValue<AccountTransactionSummary> summaryAsync = ref.watch(
      accountTransactionSummaryProvider(accountId),
    );
    final AsyncValue<List<TransactionEntity>> transactionsAsync = ref.watch(
      filteredAccountTransactionsProvider(accountId),
    );
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      accountCategoriesProvider,
    );
    final AccountTransactionsFilter filter = ref.watch(
      accountTransactionsFilterControllerProvider(accountId),
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

            final Map<String, Category> categoriesById = <String, Category>{
              for (final Category category
                  in categoriesAsync.asData?.value ?? const <Category>[])
                category.id: category,
            };

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

            final Widget filtersSection = categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, _) => _ErrorMessage(
                message: strings.accountDetailsCategoriesError(
                  error.toString(),
                ),
              ),
              data: (List<Category> categories) => _AccountFilters(
                filter: filter,
                categories: categories,
                strings: strings,
                onDateRangeChanged: (DateTimeRange? range) async {
                  ref
                      .read(
                        accountTransactionsFilterControllerProvider(
                          accountId,
                        ).notifier,
                      )
                      .setDateRange(range);
                },
                onTypeChanged: (TransactionType? type) {
                  ref
                      .read(
                        accountTransactionsFilterControllerProvider(
                          accountId,
                        ).notifier,
                      )
                      .setType(type);
                },
                onCategoryChanged: (String? categoryId) {
                  ref
                      .read(
                        accountTransactionsFilterControllerProvider(
                          accountId,
                        ).notifier,
                      )
                      .setCategory(categoryId);
                },
                onClear: () {
                  ref
                      .read(
                        accountTransactionsFilterControllerProvider(
                          accountId,
                        ).notifier,
                      )
                      .clear();
                },
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
                  children: List<Widget>.generate(transactions.length, (
                    int index,
                  ) {
                    final TransactionEntity transaction = transactions[index];
                    return _TransactionTile(
                      transaction: transaction,
                      account: account,
                      currencyFormat: currencyFormat,
                      strings: strings,
                      category: transaction.categoryId == null
                          ? null
                          : categoriesById[transaction.categoryId!],
                    );
                  }),
                );
              },
            );

            return ListView(
              padding: padding,
              children: <Widget>[
                summarySection,
                const SizedBox(height: 24),
                filtersSection,
                const SizedBox(height: 24),
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

class _AccountFilters extends StatelessWidget {
  const _AccountFilters({
    required this.filter,
    required this.categories,
    required this.strings,
    required this.onDateRangeChanged,
    required this.onTypeChanged,
    required this.onCategoryChanged,
    required this.onClear,
  });

  final AccountTransactionsFilter filter;
  final List<Category> categories;
  final AppLocalizations strings;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final ValueChanged<TransactionType?> onTypeChanged;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              strings.accountDetailsFiltersTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _DateFilterButton(
                  filter: filter,
                  strings: strings,
                  onChanged: onDateRangeChanged,
                ),
                _TypeDropdown(
                  filter: filter,
                  strings: strings,
                  onChanged: onTypeChanged,
                ),
                _CategoryDropdown(
                  filter: filter,
                  strings: strings,
                  categories: categories,
                  onChanged: onCategoryChanged,
                ),
                if (filter.hasActiveFilters)
                  TextButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.clear),
                    label: Text(strings.accountDetailsFiltersClear),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DateFilterButton extends StatelessWidget {
  const _DateFilterButton({
    required this.filter,
    required this.strings,
    required this.onChanged,
  });

  final AccountTransactionsFilter filter;
  final AppLocalizations strings;
  final ValueChanged<DateTimeRange?> onChanged;

  Future<void> _selectRange(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDateRange: filter.dateRange,
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String label;
    if (filter.dateRange == null) {
      label = strings.accountDetailsFiltersDateAny;
    } else {
      final Locale locale = Localizations.localeOf(context);
      final DateFormat formatter = DateFormat.yMMMd(locale.toString());
      label = strings.accountDetailsFiltersDateValue(
        formatter.format(filter.dateRange!.start),
        formatter.format(filter.dateRange!.end),
      );
    }

    return OutlinedButton.icon(
      onPressed: () => _selectRange(context),
      onLongPress: filter.dateRange == null ? null : () => onChanged(null),
      icon: const Icon(Icons.calendar_today_outlined),
      label: Text(label),
    );
  }
}

class _TypeDropdown extends StatelessWidget {
  const _TypeDropdown({
    required this.filter,
    required this.strings,
    required this.onChanged,
  });

  final AccountTransactionsFilter filter;
  final AppLocalizations strings;
  final ValueChanged<TransactionType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: strings.accountDetailsFiltersTypeLabel,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<TransactionType?>(
            value: filter.type,
            isExpanded: true,
            onChanged: onChanged,
            items: <DropdownMenuItem<TransactionType?>>[
              DropdownMenuItem<TransactionType?>(
                value: null,
                child: Text(strings.accountDetailsFiltersTypeAll),
              ),
              DropdownMenuItem<TransactionType?>(
                value: TransactionType.income,
                child: Text(strings.accountDetailsFiltersTypeIncome),
              ),
              DropdownMenuItem<TransactionType?>(
                value: TransactionType.expense,
                child: Text(strings.accountDetailsFiltersTypeExpense),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.filter,
    required this.strings,
    required this.categories,
    required this.onChanged,
  });

  final AccountTransactionsFilter filter;
  final AppLocalizations strings;
  final List<Category> categories;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: strings.accountDetailsFiltersCategoryLabel,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: filter.categoryId,
            isExpanded: true,
            onChanged: onChanged,
            items: <DropdownMenuItem<String?>>[
              DropdownMenuItem<String?>(
                value: null,
                child: Text(strings.accountDetailsFiltersCategoryAll),
              ),
              ...categories.map(
                (Category category) => DropdownMenuItem<String?>(
                  value: category.id,
                  child: Text(category.name),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
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
  Widget build(BuildContext context) {
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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              backgroundColor:
                  categoryColor ?? theme.colorScheme.surfaceContainerHighest,
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
                  if (transaction.note != null && transaction.note!.isNotEmpty)
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
