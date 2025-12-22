import 'package:flutter/material.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/features/categories/presentation/utils/category_color_palette.dart';
import 'package:kopim/l10n/app_localizations.dart';

Future<Color?> showAccountColorPickerDialog({
  required BuildContext context,
  required AppLocalizations strings,
  Color? initialColor,
}) {
  return showDialog<Color?>(
    context: context,
    useRootNavigator: false,
    builder: (BuildContext dialogContext) {
      return _AccountColorPickerDialog(
        initialColor: initialColor,
        strings: strings,
      );
    },
  );
}

class AccountColorSelector extends StatelessWidget {
  const AccountColorSelector({
    super.key,
    required this.color,
    required this.onColorChanged,
    required this.enabled,
  });

  final String? color;
  final ValueChanged<String?> onColorChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final Color? resolvedColor = parseHexColor(color);
    final String subtitle = resolvedColor != null
        ? colorToHex(resolvedColor, includeAlpha: false)!
        : strings.accountColorDefault;

    Future<void> handleSelection() async {
      final Color? picked = await showAccountColorPickerDialog(
        context: context,
        strings: strings,
        initialColor: resolvedColor,
      );
      if (picked != null) {
        onColorChanged(colorToHex(picked, includeAlpha: false));
      }
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor:
            resolvedColor ?? theme.colorScheme.surfaceContainerHighest,
        child: resolvedColor == null
            ? Icon(Icons.palette_outlined, color: theme.colorScheme.onSurface)
            : null,
      ),
      title: Text(strings.accountColorLabel),
      subtitle: Text(subtitle),
      trailing: Wrap(
        spacing: 8,
        children: <Widget>[
          if (resolvedColor != null)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: strings.accountColorClear,
              onPressed: enabled ? () => onColorChanged(null) : null,
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
  const _AccountColorPickerDialog({this.initialColor, required this.strings});

  final Color? initialColor;
  final AppLocalizations strings;

  @override
  State<_AccountColorPickerDialog> createState() =>
      _AccountColorPickerDialogState();
}

class _AccountColorPickerDialogState extends State<_AccountColorPickerDialog> {
  Color? _draftColor;

  static const double _kChipSize = 40;
  static const double _kSpacing = 12;

  @override
  void initState() {
    super.initState();
    _draftColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.strings.accountColorPickerTitle),
      content: SizedBox(
        height: 240,
        width: 320,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: _kSpacing,
            runSpacing: _kSpacing,
            children: <Widget>[
              for (final Color paletteColor in _accountColorPalette)
                GestureDetector(
                  onTap: () {
                    setState(() {
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
                      boxShadow: _draftColor == paletteColor
                          ? <BoxShadow>[
                              BoxShadow(
                                color: paletteColor.withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: _draftColor == paletteColor
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
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.strings.dialogCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_draftColor),
          child: Text(widget.strings.accountColorSelect),
        ),
      ],
    );
  }

  Brightness brightnessForColor(Color color) =>
      ThemeData.estimateBrightnessForColor(color);
}
