import 'package:flutter/material.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PhosphorIconPickerLabels {
  const PhosphorIconPickerLabels({
    required this.title,
    required this.searchPlaceholder,
    required this.clearButtonLabel,
    required this.emptyStateLabel,
    required this.styleLabels,
  });

  final String title;
  final String searchPlaceholder;
  final String clearButtonLabel;
  final String emptyStateLabel;
  final Map<PhosphorIconStyle, String> styleLabels;
}

Future<PhosphorIconDescriptor?> showPhosphorIconPicker({
  required BuildContext context,
  required PhosphorIconPickerLabels labels,
  PhosphorIconDescriptor? initial,
}) {
  return showModalBottomSheet<PhosphorIconDescriptor?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext context) {
      return _PhosphorIconPickerSheet(labels: labels, initial: initial);
    },
  );
}

class _PhosphorIconPickerSheet extends StatefulWidget {
  const _PhosphorIconPickerSheet({required this.labels, this.initial});

  final PhosphorIconPickerLabels labels;
  final PhosphorIconDescriptor? initial;

  @override
  State<_PhosphorIconPickerSheet> createState() =>
      _PhosphorIconPickerSheetState();
}

class _PhosphorIconPickerSheetState extends State<_PhosphorIconPickerSheet> {
  late PhosphorIconStyle _selectedStyle;
  late final TextEditingController _controller;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selectedStyle = widget.initial?.style ?? PhosphorIconStyle.regular;
    _controller = TextEditingController();
    _controller.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onQueryChanged)
      ..dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    setState(() {
      _query = _controller.text;
    });
  }

  void _selectStyle(PhosphorIconStyle style) {
    if (style == _selectedStyle) {
      return;
    }
    setState(() {
      _selectedStyle = style;
    });
  }

  void _selectIcon(String name) {
    final PhosphorIconDescriptor descriptor = PhosphorIconDescriptor(
      name: name,
      style: _selectedStyle,
    );
    Navigator.of(context).pop(descriptor);
  }

  void _clearSelection() {
    Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<String> results = filterPhosphorIconNames(_query);
    final EdgeInsets viewInsets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.labels.title,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _clearSelection,
                      icon: const Icon(Icons.block),
                      label: Text(widget.labels.clearButtonLabel),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    labelText: widget.labels.searchPlaceholder,
                  ),
                ),
                const SizedBox(height: 16),
                _StyleSelector(
                  selected: _selectedStyle,
                  labels: widget.labels.styleLabels,
                  onSelected: _selectStyle,
                ),
                const SizedBox(height: 16),
                if (results.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.labels.emptyStateLabel,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                            final double maxWidth = constraints.maxWidth;
                            final int crossAxisCount = maxWidth < 480
                                ? 4
                                : (maxWidth ~/ 72).clamp(4, 10);
                            return GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.8,
                                  ),
                              itemCount: results.length,
                              itemBuilder: (BuildContext context, int index) {
                                final String name = results[index];
                                final PhosphorIconDescriptor descriptor =
                                    PhosphorIconDescriptor(
                                      name: name,
                                      style: _selectedStyle,
                                    );
                                final PhosphorIconData? iconData =
                                    resolvePhosphorIconData(descriptor);
                                final bool isCurrent =
                                    widget.initial != null &&
                                    widget.initial!.name == name &&
                                    widget.initial!.style == _selectedStyle;
                                return _IconGridTile(
                                  iconData: iconData,
                                  name: name,
                                  isSelected: isCurrent,
                                  onTap: () => _selectIcon(name),
                                );
                              },
                            );
                          },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StyleSelector extends StatelessWidget {
  const _StyleSelector({
    required this.selected,
    required this.labels,
    required this.onSelected,
  });

  final PhosphorIconStyle selected;
  final Map<PhosphorIconStyle, String> labels;
  final ValueChanged<PhosphorIconStyle> onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PhosphorIconStyle.values
          .map((PhosphorIconStyle style) {
            final bool isSelected = style == selected;
            final String label = labels[style] ?? style.name;
            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onSelected(style),
              selectedColor: theme.colorScheme.primary.withOpacity(0.12),
            );
          })
          .toList(growable: false),
    );
  }
}

class _IconGridTile extends StatelessWidget {
  const _IconGridTile({
    required this.iconData,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  final PhosphorIconData? iconData;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.dividerColor.withOpacity(0.2);
    final Color background = isSelected
        ? theme.colorScheme.primary.withOpacity(0.08)
        : theme.colorScheme.surface;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: iconData != null
                    ? Icon(iconData, size: 32)
                    : const Icon(Icons.category_outlined, size: 32),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatPhosphorIconName(name),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
