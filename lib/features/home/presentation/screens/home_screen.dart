import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/home/presentation/controllers/home_providers.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/l10n/app_localizations.dart';

import 'package:kopim/features/analytics/presentation/analytics_screen.dart';
import 'package:kopim/features/profile/presentation/screens/profile_screen.dart';
import 'package:kopim/features/transactions/presentation/add_transaction_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<AuthUser?> authState = ref.watch(authControllerProvider);
    final AsyncValue<List<TransactionEntity>> transactionsAsync =
        ref.watch(homeRecentTransactionsProvider);
    final AsyncValue<List<AccountEntity>> accountsAsync =
        ref.watch(homeAccountsProvider);
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
        return strings.homeTotalBalance(
          currencyFormat.format(totalBalance),
        );
      },
      orElse: () => strings.homeTitle,
    );

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: SafeArea(
        child: authState.when(
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
                    _SectionHeader(title: strings.homeAccountsSection),
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
                      data: (List<TransactionEntity> transactions) =>
                          _TransactionsList(
                        transactions: transactions,
                        localeName: strings.localeName,
                        strings: strings,
                      ),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (Object error, _) => _ErrorMessage(
                        message:
                            strings.homeTransactionsError(error.toString()),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(AddTransactionScreen.routeName),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (int index) {
          switch (index) {
            case 0:
              return;
            case 1:
              Navigator.of(context).pushNamed(AnalyticsScreen.routeName);
              break;
            case 2:
              Navigator.of(context).pushNamed(ProfileScreen.routeName);
              break;
          }
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: strings.homeNavHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.show_chart_outlined),
            activeIcon: const Icon(Icons.show_chart),
            label: strings.homeNavAnalytics,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: strings.homeNavSettings,
          ),
        ],
      ),
    );
  }
}

class _AccountsList extends StatelessWidget {
  const _AccountsList({
    required this.accounts,
    required this.strings,
  });

  final List<AccountEntity> accounts;
  final AppLocalizations strings;

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
  });

  final List<TransactionEntity> transactions;
  final String localeName;
  final AppLocalizations strings;

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
        final bool isIncome = transactionType.contains('income');
        final bool isExpense = transactionType.contains('expense');
        final NumberFormat format = NumberFormat.currency(
          locale: localeName,
          symbol: isIncome
              ? strings.homeTransactionSymbolPositive
              : strings.homeTransactionSymbolNegative,
        );
        final String amountText = format.format(transaction.amount.abs());
        final String dateText = dateFormat.format(transaction.date);
        final String categoryText = transaction.categoryId == null
            ? strings.homeTransactionsUncategorized
            : strings.homeTransactionsCategory(transaction.categoryId!);
        final String? note = transaction.note;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Icon(
              isExpense ? Icons.arrow_downward : Icons.arrow_upward,
              color: isExpense ? Colors.redAccent : Colors.green,
            ),
            title: Text(amountText),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(dateText),
                Text(categoryText),
                if (note != null && note.isNotEmpty)
                  Text(note, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          message,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.error),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
