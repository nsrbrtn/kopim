import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/use_cases/add_account_use_case.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'home_account_icon_badge.dart';

class HomeAccountHideButton extends ConsumerWidget {
  const HomeAccountHideButton({super.key, required this.account});

  final AccountEntity account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isHidden = account.isHidden;
    final ThemeData theme = Theme.of(context);
    final Color iconColor = theme.brightness == Brightness.light
        ? theme.colorScheme.onSurface
        : theme.colorScheme.surfaceContainerHighest;
    return Material(
      type: MaterialType.transparency,
      child: InkResponse(
        onTap: () async {
          final DateTime now = DateTime.now().toUtc();
          final AddAccountUseCase addAccountUseCase = ref.read(
            addAccountUseCaseProvider,
          );
          await addAccountUseCase(
            account.copyWith(isHidden: !isHidden, updatedAt: now),
          );
        },
        radius: 20,
        containedInkWell: true,
        child: SizedBox(
          width: HomeAccountIconBadge.size,
          height: HomeAccountIconBadge.size,
          child: Icon(
            isHidden
                ? PhosphorIcons.eye(PhosphorIconsStyle.regular)
                : PhosphorIcons.eyeSlash(PhosphorIconsStyle.regular),
            size: 16,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
