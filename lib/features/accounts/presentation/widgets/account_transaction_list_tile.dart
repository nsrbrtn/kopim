import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_editor.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_tile_formatters.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AccountTransactionListTile extends ConsumerWidget {
  const AccountTransactionListTile({
    super.key,
    required this.transaction,
    required this.category,
    required this.currencySymbol,
    required this.strings,
  });

  final TransactionEntity transaction;
  final Category? category;
  final String currencySymbol;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final String localeName = strings.localeName;

    final double amount = transaction.amount;
    final String? note = transaction.note;

    final NumberFormat moneyFormat = TransactionTileFormatters.currency(
      localeName,
      currencySymbol,
      decimalDigits: 0,
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
        : theme.colorScheme.onSurfaceVariant;

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
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          surfaceTintColor: Colors.transparent,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(18)),
            onTap: () {
              showTransactionEditorSheet(
                context: context,
                ref: ref,
                transaction: transaction,
                submitLabel: strings.editTransactionSubmit,
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          categoryColor ??
                          theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        categoryIcon ?? Icons.category_outlined,
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
                        Text(
                          categoryName,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (note != null && note.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              note,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
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
                        moneyFormat.format(amount.abs()),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w400,
                        ),
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
