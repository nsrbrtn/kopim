import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/utils/account_type_utils.dart';
import 'package:kopim/features/accounts/presentation/account_details_screen.dart';
import 'package:kopim/features/accounts/presentation/utils/account_card_gradients.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/presentation/screens/credit_details_screen.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/home/domain/models/home_account_monthly_summary.dart';
import 'package:kopim/features/home/presentation/controllers/home_providers.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'home_account_card_palette.dart';
import 'home_account_content.dart';
import 'home_account_hide_button.dart';

final StreamProvider<List<CreditEntity>> _homeCreditsProvider =
    StreamProvider.autoDispose<List<CreditEntity>>((Ref ref) {
      return ref.watch(watchCreditsUseCaseProvider).call();
    });

class HomeAccountCard extends ConsumerWidget {
  const HomeAccountCard({
    super.key,
    required this.account,
    required this.strings,
    required this.currencyFormat,
    required this.summary,
    required this.isHighlighted,
  });

  final AccountEntity account;
  final AppLocalizations strings;
  final NumberFormat currencyFormat;
  final HomeAccountMonthlySummary summary;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    const Color carouselContentColor = Color(
      0xFF0F131A,
    ); // theme.colorScheme.scrim в оригинале, или carouselContentColor = theme.colorScheme.scrim в home_screen.dart
    final Color? accountColor = parseHexColor(account.color);
    final AccountCardGradient? gradient = resolveAccountCardGradient(
      account.gradientId,
    );
    final PhosphorIconData? accountIcon = resolveAccountIconData(account);
    final HomeAccountCardPalette palette = HomeAccountCardPalette.fromAccount(
      colorScheme: theme.colorScheme,
      accountColor: accountColor,
      gradient: gradient,
      isHighlighted: isHighlighted,
    );
    final Color secondaryContentColor = theme.brightness == Brightness.light
        ? theme.colorScheme.onSurface
        : carouselContentColor;
    final double cardRadius = context.kopimLayout.radius.xxl;
    final BorderRadius borderRadius = BorderRadius.circular(cardRadius);
    final TextStyle labelStyle =
        (theme.textTheme.labelSmall ??
                const TextStyle(fontSize: 11, height: 1.45))
            .copyWith(
              color: carouselContentColor,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            );
    final TextStyle balanceStyle =
        (theme.textTheme.displaySmall ??
                theme.textTheme.headlineMedium ??
                const TextStyle(fontSize: 36, height: 44 / 36))
            .copyWith(
              fontWeight: FontWeight.w500,
              color: carouselContentColor,
              letterSpacing: 0.1,
            );
    final TextStyle summaryTextStyle =
        (theme.textTheme.titleSmall ??
                theme.textTheme.titleMedium ??
                const TextStyle(fontSize: 14))
            .copyWith(
              color: secondaryContentColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            );
    final TextStyle summaryHeaderStyle = labelStyle.copyWith(
      color: secondaryContentColor,
    );
    final String normalizedAccountType = normalizeAccountType(account.type);
    final SavingGoal? savingGoal = isLegacySavingsAccountType(account.type)
        ? ref
              .watch(homeSavingGoalsProvider)
              .asData
              ?.value
              .firstWhereOrNull(
                (SavingGoal item) =>
                    item.accountId == account.id && !item.isArchived,
              )
        : null;
    final Widget standardContent = HomeStandardAccountContent(
      account: account,
      strings: strings,
      currencyFormat: currencyFormat,
      summary: summary,
      savingGoal: savingGoal,
      labelStyle: labelStyle,
      balanceStyle: balanceStyle,
      summaryTextStyle: summaryTextStyle,
      summaryHeaderStyle: summaryHeaderStyle,
      accountIcon: accountIcon,
      contentColor: carouselContentColor,
      palette: palette,
    );

    Widget buildCard(VoidCallback onTap) {
      return Material(
        color: theme.colorScheme.surface.withValues(alpha: 0),
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: gradient == null ? palette.background : null,
              gradient: gradient?.toGradient(),
              borderRadius: borderRadius,
            ),
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: switch (normalizedAccountType) {
                    kAccountTypeCredit => HomeCreditCardContent(
                      account: account,
                      strings: strings,
                      currencyFormat: currencyFormat,
                      palette: palette,
                      labelStyle: labelStyle,
                      balanceStyle: balanceStyle,
                      summaryTextStyle: summaryTextStyle,
                      summaryHeaderStyle: summaryHeaderStyle,
                      accountIcon: accountIcon,
                      contentColor: carouselContentColor,
                      fallback: standardContent,
                    ),
                    kAccountTypeCreditCard => HomeCreditCardAccountContent(
                      account: account,
                      strings: strings,
                      currencyFormat: currencyFormat,
                      labelStyle: labelStyle,
                      balanceStyle: balanceStyle,
                      summaryTextStyle: summaryTextStyle,
                      summaryHeaderStyle: summaryHeaderStyle,
                      accountIcon: accountIcon,
                      contentColor: carouselContentColor,
                      palette: palette,
                      fallback: standardContent,
                    ),
                    _ => standardContent,
                  },
                ),
                Positioned(
                  right: 16,
                  top: 16,
                  child: HomeAccountHideButton(account: account),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (isCreditAccountType(account.type)) {
      final CreditEntity? credit = ref
          .watch(_homeCreditsProvider)
          .asData
          ?.value
          .firstWhereOrNull(
            (CreditEntity item) => item.accountId == account.id,
          );
      return buildCard(() {
        if (credit != null) {
          context.push(CreditDetailsScreen.routeName, extra: credit);
          return;
        }
        context.push(AccountDetailsScreenArgs(accountId: account.id).location);
      });
    }

    return buildCard(() {
      context.push(AccountDetailsScreenArgs(accountId: account.id).location);
    });
  }
}
