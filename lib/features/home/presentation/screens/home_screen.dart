import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/presentation/accounts_add_screen.dart';
import 'package:kopim/features/app_shell/presentation/models/navigation_tab_content.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/presentation/add_transaction_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';

import '../controllers/home_providers.dart';

NavigationTabContent buildHomeTabContent(BuildContext context, WidgetRef ref) {
  final AppLocalizations strings = AppLocalizations.of(context)!;
  final AsyncValue<AuthUser?> authState = ref.watch(authControllerProvider);
  final AsyncValue<List<TransactionEntity>> transactionsAsync =
      ref.watch(homeRecentTransactionsProvider());
  final AsyncValue<List<AccountEntity>> accountsAsync =
      ref.watch(homeAccountsProvider);
  final AsyncValue<List<Category>> categoriesAsync =
      ref.watch(homeCategoriesProvider);
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
  });

  final AsyncValue<AuthUser?> authState;
  final AsyncValue<List<TransactionEntity>> transactionsAsync;
  final AsyncValue<List<AccountEntity>> accountsAsync;
  final AsyncValue<List<Category>> categoriesAsync;
  final AppLocalizations strings;
  final bool isWideLayout;

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
                    onPressed: () => Navigator.of(context)
                        .pushNamed(AddAccountScreen.routeName),
                  ),
                ),
                const SizedBox(height: 12),
                accountsAsync.when(
                  data: (List<AccountEntity> accounts) =>
                      _AccountsList(accounts: accounts, strings: strings),
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
                        accountsById: {
                          for (final AccountEntity account in accounts)
                            account.id: account,
                        },
                        categoriesById: {
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
                        message: strings.homeTransactionsError(error.toString()),
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
                    message: strings.homeTransactionsError(
                      error.toString(),
                    ),
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
          MaterialPageRoute<bool>(
            builder: (_) => const AddTransactionScreen(),
          ),
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

class _AccountsList extends StatelessWidget {
  const _AccountsList({required this.accounts, required this.strings});

  final List<AccountEntity> accounts;
  final AppLocalizations strings;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('accountCount', accounts.length))
      ..add(StringProperty('localeName', strings.localeName));
  }

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return _EmptyMessage(message: strings.homeAccountsEmpty);
    }

    final String localeName = strings.localeName;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: accounts.length,
      itemBuilder: (BuildContext context, int index) {
        final AccountEntity account = accounts[index];
        final NumberFormat format = NumberFormat.currency(
          locale: localeName,
          symbol: account.currency.toUpperCase(),
        );
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(account.name),
            subtitle: Text(strings.homeAccountType(account.type)),
            trailing: Text(format.format(account.balance)),
          ),
        );
      },
    );
  }
}

class _TransactionsList extends StatelessWidget {
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
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('transactionCount', transactions.length))
      ..add(StringProperty('localeName', localeName))
      ..add(IntProperty('accountCount', accountsById.length))
      ..add(IntProperty('categoryCount', categoriesById.length));
    properties.add(DiagnosticsProperty<AppLocalizations>('strings', strings));
  }

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return _EmptyMessage(message: strings.homeTransactionsEmpty);
    }

    final DateFormat dateFormat = DateFormat.yMMMd(localeName);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (BuildContext context, int index) {
        final TransactionEntity transaction = transactions[index];
        final String transactionType = transaction.type.toLowerCase();
        final bool isExpense = transactionType.contains('expense');
        final AccountEntity? account = transaction.accountId == null
            ? null
            : accountsById[transaction.accountId];
        final NumberFormat format = NumberFormat.currency(
          locale: localeName,
          symbol: account?.currency.toUpperCase() ??
              NumberFormat.simpleCurrency(locale: localeName).currencySymbol,
        );
        final String amountText = format.format(transaction.amount.abs());
        final String dateText = dateFormat.format(transaction.date);
        final Category? category = transaction.categoryId == null
            ? null
            : categoriesById[transaction.categoryId!];
        final String categoryName = category?.name ??
            strings.homeTransactionsUncategorized;
        final PhosphorIconData? categoryIcon =
            resolvePhosphorIconData(category?.icon);
        final Color? categoryColor = parseHexColor(category?.color);
        final String? note = transaction.note;
        final ThemeData theme = Theme.of(context);
        final Color amountColor = isExpense
            ? theme.colorScheme.error
            : theme.colorScheme.primary;
        final Color avatarIconColor = categoryColor != null
            ? (ThemeData.estimateBrightnessForColor(categoryColor) ==
                    Brightness.dark
                ? Colors.white
                : Colors.black87)
            : theme.colorScheme.onSurfaceVariant;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            isThreeLine: note != null && note.isNotEmpty,
            leading: CircleAvatar(
              backgroundColor:
                  categoryColor ?? theme.colorScheme.surfaceVariant,
              foregroundColor: avatarIconColor,
              child: categoryIcon != null
                  ? Icon(categoryIcon)
                  : const Icon(Icons.category_outlined),
            ),
            title: Text(
              amountText,
              style: theme.textTheme.titleMedium?.copyWith(color: amountColor),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  categoryName,
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  dateText,
                  style: theme.textTheme.bodySmall,
                ),
                if (note != null && note.isNotEmpty)
                  Text(
                    note,
                    style: theme.textTheme.bodySmall,
                  ),
              ],
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
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('title', title))
      ..add(DiagnosticsProperty<Widget>('action', action, defaultValue: null));
  }

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
        ?action,
      ],
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('message', message));
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.error,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          message,
          style: style,
          textAlign: TextAlign.center,
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
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
