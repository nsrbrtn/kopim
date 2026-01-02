import 'package:flutter/material.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/accounts/presentation/utils/account_icon_options.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

Future<PhosphorIconDescriptor?> showAccountIconPickerDialog({
  required BuildContext context,
  required AppLocalizations strings,
  PhosphorIconDescriptor? initial,
}) {
  return showDialog<PhosphorIconDescriptor?>(
    context: context,
    useRootNavigator: false,
    builder: (BuildContext dialogContext) {
      return _AccountIconPickerDialog(initial: initial, strings: strings);
    },
  );
}

class AccountIconSelector extends StatelessWidget {
  const AccountIconSelector({
    super.key,
    required this.icon,
    required this.onIconChanged,
    required this.enabled,
  });

  final PhosphorIconDescriptor? icon;
  final ValueChanged<PhosphorIconDescriptor?> onIconChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final bool hasIcon = icon != null && icon!.isNotEmpty;
    final PhosphorIconData? iconData = resolvePhosphorIconData(icon);

    Future<void> handleSelection() async {
      final PhosphorIconDescriptor? picked = await showAccountIconPickerDialog(
        context: context,
        strings: strings,
        initial: icon,
      );
      if (picked != null) {
        onIconChanged(picked);
      }
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: iconData != null
            ? Icon(iconData, color: theme.colorScheme.onSurface)
            : Icon(
                Icons.account_balance_wallet_outlined,
                color: theme.colorScheme.onSurface,
              ),
      ),
      title: Text(strings.accountIconLabel),
      subtitle: Text(
        hasIcon ? strings.accountIconSelected : strings.accountIconNone,
      ),
      trailing: Wrap(
        spacing: 8,
        children: <Widget>[
          if (hasIcon)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: strings.accountIconClear,
              onPressed: enabled ? () => onIconChanged(null) : null,
            ),
          IconButton(
            icon: const Icon(Icons.auto_awesome_outlined),
            tooltip: strings.accountIconSelect,
            onPressed: enabled ? handleSelection : null,
          ),
        ],
      ),
      onTap: enabled ? handleSelection : null,
    );
  }
}

class _AccountIconPickerDialog extends StatefulWidget {
  const _AccountIconPickerDialog({required this.strings, this.initial});

  final AppLocalizations strings;
  final PhosphorIconDescriptor? initial;

  @override
  State<_AccountIconPickerDialog> createState() =>
      _AccountIconPickerDialogState();
}

class _AccountIconPickerDialogState extends State<_AccountIconPickerDialog> {
  PhosphorIconDescriptor? _draftIcon;

  static const double _kChipSize = 48;
  static const double _kSpacing = 12;

  @override
  void initState() {
    super.initState();
    _draftIcon = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AlertDialog(
      title: Text(widget.strings.accountIconPickerTitle),
      content: SizedBox(
        height: 220,
        width: 320,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: _kSpacing,
            runSpacing: _kSpacing,
            children: <Widget>[
              for (final PhosphorIconDescriptor icon in kAccountIconOptions)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _draftIcon = icon;
                    });
                  },
                  child: Container(
                    width: _kChipSize,
                    height: _kChipSize,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: _draftIcon?.name == icon.name ? 0.85 : 0.2,
                        ),
                        width: _draftIcon?.name == icon.name ? 2 : 1,
                      ),
                    ),
                    child: Icon(
                      resolvePhosphorIconData(icon),
                      color: theme.colorScheme.onSurface,
                      size: 22,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.strings.dialogCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_draftIcon),
          child: Text(widget.strings.accountIconSelect),
        ),
      ],
    );
  }
}
