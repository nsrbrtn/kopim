import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/core/utils/context_extensions.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';

class CreditCard extends ConsumerWidget {
  const CreditCard({super.key, required this.credit, this.onTap});

  final CreditEntity credit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final Stream<List<AccountEntity>> accountAsync = ref
        .watch(watchAccountsUseCaseProvider)
        .call();
    final Stream<List<Category>> categoryAsync = ref
        .watch(watchCategoriesUseCaseProvider)
        .call();

    return StreamBuilder<List<AccountEntity>>(
      stream: accountAsync,
      builder: (BuildContext context, AsyncSnapshot<List<AccountEntity>> snapshot) {
        final List<AccountEntity> accounts = snapshot.data ?? <AccountEntity>[];
        final AccountEntity account = accounts.firstWhere(
          (AccountEntity a) => a.id == credit.accountId,
          orElse: () => AccountEntity(
            id: '',
            name: '',
            balanceMinor: BigInt.zero,
            openingBalanceMinor: BigInt.zero,
            currency: 'RUB',
            currencyScale: 2,
            type: 'credit',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        final MoneyAmount remainingDebt = account.balanceAmount.abs();
        final MoneyAmount totalDebt = credit.totalAmountValue.abs();
        final double remainingDebtValue = remainingDebt.toDouble();
        final double totalDebtValue = totalDebt.toDouble();
        final double repaidAmount = (totalDebtValue - remainingDebtValue).clamp(
          0.0,
          totalDebtValue,
        );
        final double progress = totalDebtValue > 0
            ? (repaidAmount / totalDebtValue)
            : 0.0;

        final int decimalDigits =
            credit.totalAmountScale ?? account.currencyScale ?? 2;
        final NumberFormat moneyFormat = NumberFormat.currency(
          locale: context.loc.localeName,
          symbol: getCurrencySymbol(account.currency),
          decimalDigits: decimalDigits,
        );

        final Color? accountColor = parseHexColor(account.color);
        final PhosphorIconData? accountIconData = account.iconName != null
            ? resolvePhosphorIconData(
                PhosphorIconDescriptor(
                  name: account.iconName!,
                  style: PhosphorIconStyle.values.firstWhere(
                    (PhosphorIconStyle s) =>
                        s.name == (account.iconStyle ?? 'fill'),
                    orElse: () => PhosphorIconStyle.fill,
                  ),
                ),
              )
            : null;
        final bool hasAccount = account.id.isNotEmpty;
        final Color primaryColor = hasAccount
            ? (accountColor ?? theme.colorScheme.primary)
            : theme.colorScheme.onSurfaceVariant;

        return StreamBuilder<List<Category>>(
          stream: categoryAsync,
          builder:
              (
                BuildContext context,
                AsyncSnapshot<List<Category>> catSnapshot,
              ) {
                final List<Category> categories =
                    catSnapshot.data ?? <Category>[];
                final Category? category = categories.firstWhereOrNull(
                  (Category c) => c.id == credit.categoryId,
                );

                final PhosphorIconData? categoryIconData =
                    category?.icon != null
                    ? resolvePhosphorIconData(category!.icon!)
                    : null;

                final PhosphorIconData? iconToShow =
                    categoryIconData ?? accountIconData;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      account.name,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      '${credit.interestRate}% • ${credit.termMonths} мес.',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              CircleAvatar(
                                backgroundColor:
                                    accountColor?.withValues(alpha: 0.1) ??
                                    theme.colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  iconToShow ?? Icons.account_balance_outlined,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    context.loc.creditsRemainingAmount,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    moneyFormat.format(remainingDebtValue),
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                  ),
                                ],
                              ),
                              Text(
                                context.loc.creditsTotalAmount(
                                  moneyFormat.format(totalDebtValue),
                                ),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
        );
      },
    );
  }
}
