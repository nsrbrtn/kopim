import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/formatting/currency_symbols.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/credits/presentation/widgets/grouped_credit_payment_tile.dart';
import 'package:kopim/features/transactions/domain/models/feed_item.dart';
import 'package:kopim/features/home/presentation/controllers/home_providers.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'home_account_content.dart';

class HomeGroupedCreditPaymentListItem extends ConsumerWidget {
  const HomeGroupedCreditPaymentListItem({
    super.key,
    required this.item,
    required this.localeName,
    required this.strings,
  });

  final GroupedCreditPaymentFeedItem item;
  final String localeName;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String firstTransactionAccountId = item.transactions.first.accountId;
    final AccountEntity? creditAccount = ref.watch(
      homeAccountByIdProvider(firstTransactionAccountId),
    );

    final PhosphorIconData? creditIcon = creditAccount == null
        ? null
        : resolveAccountIconData(creditAccount);
    final String currencySymbol = creditAccount?.currency != null
        ? resolveCurrencySymbol(creditAccount!.currency, locale: localeName)
        : resolveFallbackCurrencySymbol(localeName);

    return GroupedCreditPaymentTile(
      group: item,
      currencySymbol: currencySymbol,
      strings: strings,
      title: creditAccount?.name,
      leadingIcon: creditIcon,
    );
  }
}
