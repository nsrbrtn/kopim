import 'package:flutter/material.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/features/accounts/presentation/utils/account_card_gradients.dart';
import 'package:kopim/features/categories/presentation/utils/category_color_palette.dart';
import 'package:kopim/l10n/app_localizations.dart';

class AccountCardStyleSelection {
  const AccountCardStyleSelection({this.color, this.gradientId});

  final String? color;
  final String? gradientId;
}

Future<AccountCardStyleSelection?> showAccountColorPickerDialog({
  required BuildContext context,
  required AppLocalizations strings,
  Color? initialColor,
  String? initialGradientId,
}) {
  return showDialog<AccountCardStyleSelection?>(
    context: context,
    useRootNavigator: false,
    builder: (BuildContext dialogContext) {
      return _AccountColorPickerDialog(
        initialColor: initialColor,
        initialGradientId: initialGradientId,
        strings: strings,
      );
    },
  );
}

class AccountColorSelector extends StatelessWidget {
  const AccountColorSelector({
    super.key,
    required this.color,
    required this.gradientId,
    required this.onStyleChanged,
    required this.enabled,
  });

  final String? color;
  final String? gradientId;
  final ValueChanged<AccountCardStyleSelection> onStyleChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final Color? resolvedColor = parseHexColor(color);
    final AccountCardGradient? gradient = resolveAccountCardGradient(
      gradientId,
    );
    final String subtitle = gradient != null
        ? strings.accountColorGradient
        : (resolvedColor != null
              ? colorToHex(resolvedColor, includeAlpha: false)!
              : strings.accountColorDefault);

    Future<void> handleSelection() async {
      final AccountCardStyleSelection? picked =
          await showAccountColorPickerDialog(
            context: context,
            strings: strings,
            initialColor: resolvedColor,
            initialGradientId: gradientId,
          );
      if (picked != null) {
        onStyleChanged(picked);
      }
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: gradient != null
          ? Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: gradient.toGradient(),
                shape: BoxShape.circle,
              ),
            )
          : CircleAvatar(
              backgroundColor:
                  resolvedColor ?? theme.colorScheme.surfaceContainerHighest,
              child: resolvedColor == null
                  ? Icon(
                      Icons.palette_outlined,
                      color: theme.colorScheme.onSurface,
                    )
                  : null,
            ),
      title: Text(strings.accountColorLabel),
      subtitle: Text(subtitle),
      trailing: Wrap(
        spacing: 8,
        children: <Widget>[
          if (resolvedColor != null || gradient != null)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: strings.accountColorClear,
              onPressed: enabled
                  ? () => onStyleChanged(const AccountCardStyleSelection())
                  : null,
            ),
          IconButton(
            icon: const Icon(Icons.color_lens_outlined),
            tooltip: strings.accountColorSelect,
            onPressed: enabled ? handleSelection : null,
          ),
        ],
      ),
      onTap: enabled ? handleSelection : null,
    );
  }
}

const List<Color> _accountColorPalette = kCategoryPastelPalette;

class _AccountColorPickerDialog extends StatefulWidget {
  const _AccountColorPickerDialog({
    required this.strings,
    this.initialColor,
    this.initialGradientId,
  });

  final Color? initialColor;
  final String? initialGradientId;
  final AppLocalizations strings;

  @override
  State<_AccountColorPickerDialog> createState() =>
      _AccountColorPickerDialogState();
}

class _AccountColorPickerDialogState extends State<_AccountColorPickerDialog> {
  Color? _draftColor;
  String? _draftGradientId;

  static const double _kChipSize = 40;
  static const double _kSpacing = 12;

  @override
  void initState() {
    super.initState();
    _draftColor = widget.initialColor;
    _draftGradientId = widget.initialGradientId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.strings.accountColorPickerTitle),
      content: SizedBox(
        height: 240,
        width: 320,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.strings.accountColorGradient,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: _kSpacing,
                runSpacing: _kSpacing,
                children: <Widget>[
                  for (final AccountCardGradient gradient
                      in kAccountCardGradients)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _draftGradientId = gradient.id;
                          _draftColor = gradient.primaryColor;
                        });
                      },
                      child: Container(
                        width: _kChipSize,
                        height: _kChipSize,
                        decoration: BoxDecoration(
                          gradient: gradient.toGradient(),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: _draftGradientId == gradient.id
                                  ? 0.9
                                  : 0.4,
                            ),
                            width: _draftGradientId == gradient.id ? 3 : 1,
                          ),
                          boxShadow: _draftGradientId == gradient.id
                              ? <BoxShadow>[
                                  BoxShadow(
                                    color: gradient.sampleColor.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: _draftGradientId == gradient.id
                            ? Icon(
                                Icons.check,
                                color:
                                    brightnessForColor(gradient.sampleColor) ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                size: 18,
                              )
                            : null,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.strings.accountColorLabel,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: _kSpacing,
                runSpacing: _kSpacing,
                children: <Widget>[
                  for (final Color paletteColor in _accountColorPalette)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _draftGradientId = null;
                          _draftColor = paletteColor;
                        });
                      },
                      child: Container(
                        width: _kChipSize,
                        height: _kChipSize,
                        decoration: BoxDecoration(
                          color: paletteColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: _draftColor == paletteColor ? 0.85 : 0.4,
                            ),
                            width: _draftColor == paletteColor ? 3 : 1,
                          ),
                          boxShadow:
                              _draftColor == paletteColor &&
                                  _draftGradientId == null
                              ? <BoxShadow>[
                                  BoxShadow(
                                    color: paletteColor.withValues(alpha: 0.35),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child:
                            _draftColor == paletteColor &&
                                _draftGradientId == null
                            ? Icon(
                                Icons.check,
                                color:
                                    brightnessForColor(paletteColor) ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                size: 18,
                              )
                            : null,
                      ),
                    ),
                ],
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
          onPressed: () => Navigator.of(context).pop(
            AccountCardStyleSelection(
              color: _draftColor != null
                  ? colorToHex(_draftColor!, includeAlpha: false)
                  : null,
              gradientId: _draftGradientId,
            ),
          ),
          child: Text(widget.strings.accountColorSelect),
        ),
      ],
    );
  }

  Brightness brightnessForColor(Color color) =>
      ThemeData.estimateBrightnessForColor(color);
}
