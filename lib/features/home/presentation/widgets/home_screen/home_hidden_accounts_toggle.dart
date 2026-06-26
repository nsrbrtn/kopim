import 'package:flutter/material.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeHiddenAccountsToggleButton extends StatelessWidget {
  const HomeHiddenAccountsToggleButton({
    super.key,
    required this.isShowingHiddenAccounts,
    required this.strings,
    required this.onToggle,
  });

  final bool isShowingHiddenAccounts;
  final AppLocalizations strings;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final String label = isShowingHiddenAccounts
        ? strings.homeHiddenAccountsToggleHideLabel
        : strings.homeHiddenAccountsToggleShowLabel;
    final PhosphorIconData icon = isShowingHiddenAccounts
        ? PhosphorIcons.eyeSlash(PhosphorIconsStyle.regular)
        : PhosphorIcons.eye(PhosphorIconsStyle.regular);

    return Tooltip(
      message: label,
      child: IconButton(icon: Icon(icon), onPressed: onToggle),
    );
  }
}
