import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/utils/context_extensions.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DebtCard extends ConsumerWidget {
  const DebtCard({super.key, required this.debt, this.onTap});

  final DebtEntity debt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final Stream<List<AccountEntity>> accountAsync = ref
        .watch(watchAccountsUseCaseProvider)
        .call();

    return StreamBuilder<List<AccountEntity>>(
      stream: accountAsync,
      builder:
          (BuildContext context, AsyncSnapshot<List<AccountEntity>> snapshot) {
            final List<AccountEntity> accounts =
                snapshot.data ?? <AccountEntity>[];
            final AccountEntity account = accounts.firstWhere(
              (AccountEntity a) => a.id == debt.accountId,
              orElse: () => AccountEntity(
                id: '',
                name: '',
                balance: 0,
                currency: 'RUB',
                type: 'cash',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );

            final NumberFormat moneyFormat = NumberFormat.currency(
              locale: context.loc.localeName,
              symbol: getCurrencySymbol(account.currency),
              decimalDigits: 0,
            );
            final DateFormat dateFormat = DateFormat.yMMMd(
              context.loc.localeName,
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
            final Color primaryColor = accountColor ?? theme.colorScheme.primary;

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
                                  account.name.isNotEmpty
                                      ? account.name
                                      : 'Счет',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  dateFormat.format(debt.dueDate),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor:
                                accountColor?.withValues(alpha: 0.1) ??
                                theme.colorScheme.primaryContainer,
                            child: Icon(
                              accountIconData ?? Icons.payments_outlined,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        moneyFormat.format(debt.amount),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (debt.note != null && debt.note!.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 8),
                        Text(
                          debt.note!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
    );
  }
}
