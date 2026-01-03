import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show StreamProviderFamily;
import 'package:intl/intl.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/formatting/currency_symbols.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_draft_controller.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_editor.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_form_open_container.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_tile_formatters.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

final StreamProviderFamily<List<TagEntity>, String> _transactionTagsProvider =
    StreamProvider.autoDispose.family<List<TagEntity>, String>((
      Ref ref,
      String transactionId,
    ) {
      return ref
          .watch(watchTransactionTagsUseCaseProvider)
          .call(transactionId);
    });

class TransactionListTile extends ConsumerWidget {
  const TransactionListTile({
    super.key,
    required this.transaction,
    required this.category,
    required this.currency,
    required this.strings,
    this.accountName,
    this.transferAccountName,
  });

  static const double extent = 112;

  final TransactionEntity transaction;
  final Category? category;
  final String currency;
  final AppLocalizations strings;
  final String? accountName;
  final String? transferAccountName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String localeName = strings.localeName;
    final String? note = transaction.note;

    final ThemeData theme = Theme.of(context);
    final String currencySymbol = resolveCurrencySymbol(
      currency,
      locale: localeName,
    );
    final NumberFormat moneyFormat = TransactionTileFormatters.currency(
      localeName,
      currencySymbol,
      decimalDigits: 0,
    );

    final bool isTransfer =
        transaction.type == TransactionType.transfer.storageValue;
    final List<TagEntity> tags = isTransfer
        ? const <TagEntity>[]
        : ref.watch(_transactionTagsProvider(transaction.id)).asData?.value ??
            const <TagEntity>[];
    final String tagLabel = tags.map((TagEntity tag) => tag.name).join(', ');
    final String categoryName =
        category?.name ?? strings.homeTransactionsUncategorized;
    final String title = isTransfer
        ? strings.addTransactionTypeTransfer
        : categoryName;
    final PhosphorIconData? categoryIcon = resolvePhosphorIconData(
      category?.icon,
    );
    final Color? categoryColor = parseHexColor(category?.color);
    final Color avatarBackground = isTransfer
        ? theme.colorScheme.primaryContainer
        : (categoryColor ?? theme.colorScheme.surfaceContainerHighest);
    final Color avatarIconColor = isTransfer
        ? theme.colorScheme.onPrimaryContainer
        : categoryColor != null
        ? (ThemeData.estimateBrightnessForColor(categoryColor) ==
                  Brightness.dark
              ? Colors.white
              : Colors.black87)
        : theme.colorScheme.onSurfaceVariant;
    final String? accountLabel = isTransfer
        ? _buildTransferLabel(
            sourceAccount: accountName,
            targetAccount: transferAccountName,
            strings: strings,
          )
        : accountName;

    return Dismissible(
      key: ValueKey<String>(transaction.id),
      direction: DismissDirection.endToStart,
      background: buildDeleteBackground(
        theme.colorScheme.errorContainer,
        iconColor: theme.colorScheme.onErrorContainer,
      ),
      confirmDismiss: (DismissDirection direction) async {
        return deleteTransactionWithFeedback(
          context: context,
          ref: ref,
          transactionId: transaction.id,
          strings: strings,
        );
      },
      child: RepaintBoundary(
        child: TransactionFormOpenContainer(
          formArgs: TransactionFormArgs(initialTransaction: transaction),
          closedBuilder: (BuildContext context, VoidCallback openContainer) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              surfaceTintColor: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(18)),
                onTap: openContainer,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: avatarBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            categoryIcon ??
                                (isTransfer
                                    ? Icons.swap_horiz
                                    : Icons.category_outlined),
                            size: 22,
                            color: avatarIconColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _TransactionTitleWithTags(
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
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                            // Add date if it's not grouped by date in the list
                            if (note == null || note.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  DateFormat.yMMMd(
                                    localeName,
                                  ).add_Hm().format(transaction.date),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
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
                            moneyFormat.format(transaction.amount.abs()),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                          if (accountLabel != null && accountLabel.isNotEmpty)
                            Text(
                              accountLabel,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TransactionTitleWithTags extends StatelessWidget {
  const _TransactionTitleWithTags({
    required this.title,
    required this.tagLabel,
  });

  final String title;
  final String tagLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? baseStyle = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.onSurface,
    );
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
      fontWeight: FontWeight.w400,
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
}

String? _buildTransferLabel({
  required String? sourceAccount,
  required String? targetAccount,
  required AppLocalizations strings,
}) {
  if (sourceAccount == null && targetAccount == null) {
    return null;
  }
  if (sourceAccount == null) {
    return strings.transactionTransferAccountSingle(targetAccount!);
  }
  if (targetAccount == null) {
    return strings.transactionTransferAccountSingle(sourceAccount);
  }
  return strings.transactionTransferAccountPair(sourceAccount, targetAccount);
}
