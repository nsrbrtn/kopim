import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show StreamProviderFamily;
import 'package:intl/intl.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/core/formatting/currency_symbols.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/features/profile/presentation/controllers/active_currency_code_provider.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/presentation/utils/category_gradients.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_sheet_controller.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_tile_formatters.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_editor.dart';
import 'package:kopim/features/home/presentation/controllers/home_providers.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'home_transactions_skeleton.dart';

final StreamProviderFamily<List<TagEntity>, String>
_homeTransactionTagsProvider = StreamProvider.autoDispose
    .family<List<TagEntity>, String>((Ref ref, String transactionId) {
      return ref.watch(watchTransactionTagsUseCaseProvider).call(transactionId);
    });

class HomeTransactionListItem extends ConsumerWidget {
  const HomeTransactionListItem({
    super.key,
    required this.transactionId,
    required this.localeName,
    required this.strings,
  });

  static const double extent = 112;

  final String transactionId;
  final String localeName;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TransactionEntity? transaction = ref.watch(
      homeTransactionByIdProvider(transactionId),
    );

    if (transaction == null) {
      return const HomeTransactionTileSkeleton();
    }

    final String accountId = transaction.accountId;
    final String? categoryId = transaction.categoryId;
    final MoneyAmount amount = transaction.amountValue;
    final String? note = transaction.note;
    final bool isTransfer =
        transaction.type == TransactionType.transfer.storageValue;
    final List<TagEntity> tags = isTransfer
        ? const <TagEntity>[]
        : ref
                  .watch(_homeTransactionTagsProvider(transactionId))
                  .asData
                  ?.value ??
              const <TagEntity>[];
    final String tagLabel = tags.map((TagEntity tag) => tag.name).join(', ');

    final ThemeData theme = Theme.of(context);
    final ({String? name, String? currency}) accountData = ref.watch(
      homeAccountByIdProvider(accountId).select(
        (AccountEntity? account) =>
            (name: account?.name, currency: account?.currency),
      ),
    );
    final String? transferAccountId = transaction.transferAccountId;
    final String? transferAccountName = isTransfer && transferAccountId != null
        ? ref.watch(
            homeAccountByIdProvider(
              transferAccountId,
            ).select((AccountEntity? account) => account?.name),
          )
        : null;
    final String currencySymbol = accountData.currency != null
        ? resolveCurrencySymbol(accountData.currency!, locale: localeName)
        : resolveCurrencySymbol(
            activeCurrencyCodeOf(context),
            locale: localeName,
          );
    final NumberFormat moneyFormat = TransactionTileFormatters.currency(
      localeName,
      currencySymbol,
      decimalDigits: 0,
    );

    final ({
      String? name,
      PhosphorIconDescriptor? icon,
      String? color,
      String? parentId,
      bool isSystem,
    })
    categoryData = categoryId == null
        ? (name: null, icon: null, color: null, parentId: null, isSystem: false)
        : ref.watch(
            homeCategoryByIdProvider(categoryId).select(
              (Category? cat) => (
                name: cat?.name,
                icon: cat?.icon,
                color: cat?.color,
                parentId: cat?.parentId,
                isSystem: cat?.isSystem ?? false,
              ),
            ),
          );
    final String categoryName =
        categoryData.name ?? strings.homeTransactionsUncategorized;
    final bool isCreditTransferByCategory =
        isTransfer &&
        categoryData.name != null &&
        categoryData.parentId != null &&
        categoryData.isSystem;
    final String title = isCreditTransferByCategory
        ? categoryName
        : (isTransfer ? strings.addTransactionTypeTransfer : categoryName);
    final PhosphorIconData? categoryIcon = resolvePhosphorIconData(
      categoryData.icon,
    );
    final CategoryColorStyle categoryStyle = resolveCategoryColorStyle(
      categoryData.color,
    );
    final Color? categoryColor = categoryStyle.sampleColor;
    final Color avatarIconColor = theme.colorScheme.scrim;
    final Color avatarBackground = isTransfer
        ? theme.colorScheme.primaryContainer
        : categoryColor ?? theme.colorScheme.surfaceContainerHighest;
    final String? accountLabel = isTransfer
        ? _buildTransferLabel(
            sourceAccount: accountData.name,
            targetAccount: transferAccountName,
            strings: strings,
          )
        : accountData.name;

    return Dismissible(
      key: ValueKey<String>(transactionId),
      direction: DismissDirection.endToStart,
      background: buildDeleteBackground(
        theme.colorScheme.errorContainer,
        iconColor: theme.colorScheme.onErrorContainer,
      ),
      confirmDismiss: (DismissDirection direction) async {
        return deleteTransactionWithFeedback(
          context: context,
          ref: ref,
          transactionId: transactionId,
          strings: strings,
        );
      },
      child: RepaintBoundary(
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          surfaceTintColor: theme.colorScheme.surface.withValues(alpha: 0),
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(18)),
            onTap: () => ref
                .read(transactionSheetControllerProvider.notifier)
                .openForEdit(transaction),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isTransfer
                          ? avatarBackground
                          : (categoryStyle.backgroundGradient == null
                                ? avatarBackground
                                : null),
                      gradient: isTransfer
                          ? null
                          : categoryStyle.backgroundGradient,
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
                        TransactionTileFormatters.formatAmount(
                          formatter: moneyFormat,
                          amount: amount,
                        ),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (accountLabel != null && accountLabel.isNotEmpty)
                        Text(
                          accountLabel,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
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

  Widget _buildTitleWithTags({
    required BuildContext context,
    required String title,
    required String tagLabel,
  }) {
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
