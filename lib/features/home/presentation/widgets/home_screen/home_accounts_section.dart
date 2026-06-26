import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/presentation/accounts_add_screen.dart';
import 'package:kopim/features/home/domain/models/home_account_monthly_summary.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'home_accounts_list.dart';
import 'home_hidden_accounts_toggle.dart';
import 'home_screen_commons.dart';
import 'home_transactions_skeleton.dart';

class HomeAccountsSection extends StatefulWidget {
  const HomeAccountsSection({
    super.key,
    required this.accountsAsync,
    required this.strings,
    required this.accountSummariesAsync,
    required this.isWideLayout,
  });

  final AsyncValue<List<AccountEntity>> accountsAsync;
  final AppLocalizations strings;
  final AsyncValue<Map<String, HomeAccountMonthlySummary>>
  accountSummariesAsync;
  final bool isWideLayout;

  @override
  State<HomeAccountsSection> createState() => _HomeAccountsSectionState();
}

class _HomeAccountsSectionState extends State<HomeAccountsSection> {
  bool _showHiddenAccounts = false;

  void _toggleHiddenAccountsVisibility() {
    setState(() {
      _showHiddenAccounts = !_showHiddenAccounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<AccountEntity> accounts =
        widget.accountsAsync.asData?.value ?? <AccountEntity>[];
    final bool hasHiddenAccounts = accounts.any(
      (AccountEntity account) => account.isHidden,
    );
    final Widget headerAction = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (hasHiddenAccounts) ...<Widget>[
          HomeHiddenAccountsToggleButton(
            isShowingHiddenAccounts: _showHiddenAccounts,
            strings: widget.strings,
            onToggle: _toggleHiddenAccountsVisibility,
          ),
          const SizedBox(width: 4),
        ],
        IconButton(
          icon: Icon(Icons.add, color: theme.colorScheme.primary),
          tooltip: widget.strings.homeAccountsAddTooltip,
          onPressed: () => context.push(AddAccountScreen.routeName),
        ),
      ],
    );
    final Widget content = widget.accountsAsync.when(
      data: (List<AccountEntity> accounts) {
        final List<AccountEntity> visibleAccounts = accounts
            .where((AccountEntity account) => !account.isHidden)
            .toList(growable: false);
        final List<AccountEntity> hiddenAccounts = accounts
            .where((AccountEntity account) => account.isHidden)
            .toList(growable: false);
        return HomeAccountsList(
          accounts: visibleAccounts,
          hiddenAccounts: hiddenAccounts,
          strings: widget.strings,
          monthlySummaries:
              widget.accountSummariesAsync.asData?.value ??
              const <String, HomeAccountMonthlySummary>{},
          isWideLayout: widget.isWideLayout,
          showHiddenAccounts: _showHiddenAccounts,
        );
      },
      loading: () => const HomeTransactionsSkeletonList(),
      error: (Object error, _) => HomeErrorMessage(
        message: widget.strings.homeAccountsError(error.toString()),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        HomeSectionHeader(
          title: widget.strings.homeAccountsSection,
          action: headerAction,
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }
}
