import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/theme_extensions.dart';

/// Адаптированный текстовый ввод, повторяющий визуальный стиль из макета Kopim.
class KopimTextField extends StatefulWidget {
  const KopimTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.supportingText,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.enabled = true,
    this.obscureText = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.minLines,
    this.textStyle,
    this.fillColor,
    this.placeholderColor,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final String? supportingText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final bool enabled;
  final bool obscureText;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final TextCapitalization textCapitalization;
  final int? maxLines;
  final int? minLines;
  final TextStyle? textStyle;
  final Color? fillColor;
  final Color? placeholderColor;

  @override
  State<KopimTextField> createState() => _KopimTextFieldState();
}

class _KopimTextFieldState extends State<KopimTextField> {
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();
    _assignFocusNode(widget.focusNode);
  }

  @override
  void didUpdateWidget(covariant KopimTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      if (_ownsFocusNode) {
        _focusNode.dispose();
      }
      _assignFocusNode(widget.focusNode);
    }
  }

  @override
  void dispose() {
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _assignFocusNode(FocusNode? node) {
    _focusNode = node ?? FocusNode();
    _ownsFocusNode = node == null;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final KopimLayout layout = context.kopimLayout;
    final double borderRadius = layout.radius.card;
    final EdgeInsetsGeometry padding = EdgeInsets.symmetric(
      horizontal: layout.spacing.section,
      vertical: layout.spacing.between,
    );

    final Color placeholderColor =
        widget.placeholderColor ?? colors.surfaceContainerHighest;
    final TextStyle effectiveTextStyle =
        widget.textStyle ??
        theme.textTheme.bodyLarge?.copyWith(color: colors.onSurface) ??
        TextStyle(color: colors.onSurface);
    final TextStyle hintStyle = effectiveTextStyle.copyWith(
      color: placeholderColor,
    );

    final OutlineInputBorder baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide.none,
    );
    final OutlineInputBorder focusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(color: colors.surfaceContainerHighest, width: 2),
    );

    final bool hasSupportingText =
        widget.supportingText != null && widget.supportingText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          textCapitalization: widget.textCapitalization,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          cursorColor: colors.primary,
          style: effectiveTextStyle,
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.fillColor ?? colors.surfaceContainerLowest,
            hintText: widget.placeholder,
            hintStyle: hintStyle,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            contentPadding: padding,
            border: baseBorder,
            enabledBorder: baseBorder,
            focusedBorder: focusBorder,
            disabledBorder: baseBorder,
          ),
        ),
        if (hasSupportingText) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            widget.supportingText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
