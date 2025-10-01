import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/phosphor_icon_picker.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/entities/category_tree_node.dart';
import 'package:kopim/features/categories/presentation/controllers/categories_list_controller.dart';
import 'package:kopim/features/categories/presentation/controllers/category_form_controller.dart';
import 'package:kopim/features/categories/presentation/utils/category_color_palette.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  static const String routeName = '/categories/manage';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<List<CategoryTreeNode>> treeAsync = ref.watch(
      manageCategoryTreeProvider,
    );

    final List<CategoryTreeNode> tree =
        treeAsync.asData?.value ?? const <CategoryTreeNode>[];
    final List<Category> rootCategories = tree
        .map((CategoryTreeNode node) => node.category)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(strings.profileManageCategoriesTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryEditor(
          context,
          ref,
          strings: strings,
          parents: rootCategories,
        ),
        tooltip: strings.manageCategoriesAddAction,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: treeAsync.when(
          data: (List<CategoryTreeNode> nodes) {
            if (nodes.isEmpty) {
              return _EmptyCategoriesView(
                message: strings.manageCategoriesEmpty,
              );
            }
            return _CategoryTreeList(
              tree: nodes,
              strings: strings,
              onEditCategory: (Category category) => _showCategoryEditor(
                context,
                ref,
                strings: strings,
                parents: rootCategories,
                category: category,
              ),
              onAddSubcategory: (Category parent) => _showCategoryEditor(
                context,
                ref,
                strings: strings,
                parents: rootCategories,
                defaultParentId: parent.id,
              ),
              onDeleteCategory: (Category category) => _confirmDeleteCategory(
                context,
                ref,
                strings: strings,
                category: category,
              ),
            );
          },
          error: (Object error, StackTrace? stackTrace) => _ErrorView(
            message: strings.manageCategoriesListError(error.toString()),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

Future<void> _showCategoryEditor(
  BuildContext context,
  WidgetRef ref, {
  required AppLocalizations strings,
  required List<Category> parents,
  Category? category,
  String? defaultParentId,
}) async {
  final bool? didSave = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext context) {
      return _CategoryEditorSheet(
        category: category,
        parents: parents,
        defaultParentId: defaultParentId,
      );
    },
  );

  if (didSave == true && context.mounted) {
    final String message = category == null
        ? strings.manageCategoriesSuccessCreate
        : strings.manageCategoriesSuccessUpdate;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

Future<void> _confirmDeleteCategory(
  BuildContext context,
  WidgetRef ref, {
  required AppLocalizations strings,
  required Category category,
}) async {
  final bool? shouldDelete = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(strings.manageCategoriesDeleteConfirmTitle),
        content: Text(
          strings.manageCategoriesDeleteConfirmMessage(category.name),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(strings.manageCategoriesDeleteAction),
          ),
        ],
      );
    },
  );

  if (shouldDelete != true || !context.mounted) {
    return;
  }

  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(deleteCategoryUseCaseProvider)(category.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(strings.manageCategoriesDeleteSuccess)),
      );
  } catch (error) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(strings.manageCategoriesDeleteError(error.toString())),
        ),
      );
  }
}

class _CategoryTreeList extends StatelessWidget {
  const _CategoryTreeList({
    required this.tree,
    required this.strings,
    required this.onEditCategory,
    required this.onAddSubcategory,
    required this.onDeleteCategory,
  });

  final List<CategoryTreeNode> tree;
  final AppLocalizations strings;
  final ValueChanged<Category> onEditCategory;
  final ValueChanged<Category> onAddSubcategory;
  final ValueChanged<Category> onDeleteCategory;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: tree.length,
      itemBuilder: (BuildContext context, int index) {
        final CategoryTreeNode node = tree[index];
        return _CategoryNodeCard(
          node: node,
          strings: strings,
          onEditCategory: onEditCategory,
          onAddSubcategory: onAddSubcategory,
          onDeleteCategory: onDeleteCategory,
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
    );
  }
}

class _CategoryNodeCard extends StatelessWidget {
  const _CategoryNodeCard({
    required this.node,
    required this.strings,
    required this.onEditCategory,
    required this.onAddSubcategory,
    required this.onDeleteCategory,
  });

  final CategoryTreeNode node;
  final AppLocalizations strings;
  final ValueChanged<Category> onEditCategory;
  final ValueChanged<Category> onAddSubcategory;
  final ValueChanged<Category> onDeleteCategory;

  @override
  Widget build(BuildContext context) {
    final Category category = node.category;
    final Color? color = parseHexColor(category.color);
    final IconData? iconData = resolvePhosphorIconData(category.icon);
    final List<String> metadata = _buildMetadata(category, strings);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide.none,
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide.none,
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: _CategoryIcon(iconData: iconData, backgroundColor: color),
        title: Text(category.name),
        subtitle: Text(metadata.join(' · ')),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        trailing: Wrap(
          spacing: 4,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: strings.manageCategoriesCreateSubAction,
              onPressed: () => onAddSubcategory(category),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: strings.manageCategoriesEditAction,
              onPressed: () => onEditCategory(category),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: strings.manageCategoriesDeleteAction,
              onPressed: () => onDeleteCategory(category),
            ),
          ],
        ),
        children: node.children.isEmpty
            ? <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    strings.manageCategoriesNoSubcategories,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 8),
              ]
            : node.children
                  .map(
                    (CategoryTreeNode child) => _SubcategoryTile(
                      node: child,
                      strings: strings,
                      onEdit: onEditCategory,
                      onDelete: onDeleteCategory,
                    ),
                  )
                  .toList(growable: false),
      ),
    );
  }
}

class _SubcategoryTile extends StatelessWidget {
  const _SubcategoryTile({
    required this.node,
    required this.strings,
    required this.onEdit,
    required this.onDelete,
  });

  final CategoryTreeNode node;
  final AppLocalizations strings;
  final ValueChanged<Category> onEdit;
  final ValueChanged<Category> onDelete;

  @override
  Widget build(BuildContext context) {
    final Category category = node.category;
    final IconData? iconData = resolvePhosphorIconData(category.icon);
    final Color? color = parseHexColor(category.color);
    final List<String> metadata = _buildMetadata(category, strings);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: _CategoryIcon(iconData: iconData, backgroundColor: color),
      title: Text(category.name),
      subtitle: Text(metadata.join(' · ')),
      trailing: Wrap(
        spacing: 4,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: strings.manageCategoriesEditAction,
            onPressed: () => onEdit(category),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: strings.manageCategoriesDeleteAction,
            onPressed: () => onDelete(category),
          ),
        ],
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({this.iconData, this.backgroundColor});

  final IconData? iconData;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color avatarBackground =
        backgroundColor ?? theme.colorScheme.surfaceVariant;
    final Color avatarForeground = backgroundColor != null
        ? (ThemeData.estimateBrightnessForColor(avatarBackground) ==
                  Brightness.dark
              ? Colors.white
              : Colors.black87)
        : theme.colorScheme.onSurfaceVariant;

    return CircleAvatar(
      backgroundColor: avatarBackground,
      foregroundColor: avatarForeground,
      child: iconData != null
          ? Icon(iconData)
          : const Icon(Icons.category_outlined),
    );
  }
}

class _EmptyCategoriesView extends StatelessWidget {
  const _EmptyCategoriesView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _CategoryEditorSheet extends ConsumerWidget {
  const _CategoryEditorSheet({
    this.category,
    required this.parents,
    this.defaultParentId,
  });

  final Category? category;
  final List<Category> parents;
  final String? defaultParentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final CategoryFormParams params = CategoryFormParams(
      initial: category,
      parents: parents,
      defaultParentId: defaultParentId,
    );
    ref.listen<CategoryFormState>(categoryFormControllerProvider(params), (
      CategoryFormState? previous,
      CategoryFormState next,
    ) {
      if (next.isSuccess && previous?.isSuccess != next.isSuccess) {
        ref
            .read(categoryFormControllerProvider(params).notifier)
            .resetSuccess();
        Navigator.of(context).pop(true);
      } else if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                strings.manageCategoriesSaveError(next.errorMessage!),
              ),
            ),
          );
      }
    });

    final CategoryFormState state = ref.watch(
      categoryFormControllerProvider(params),
    );
    final CategoryFormController controller = ref.read(
      categoryFormControllerProvider(params).notifier,
    );

    final ThemeData theme = Theme.of(context);
    final String title = category == null
        ? strings.manageCategoriesCreateTitle
        : strings.manageCategoriesEditTitle;
    final PhosphorIconData? iconData = resolvePhosphorIconData(state.icon);
    final String iconSubtitle = state.icon?.isNotEmpty == true
        ? strings.manageCategoriesIconSelected
        : strings.manageCategoriesIconNone;
    final Color? selectedColor = parseHexColor(state.color);
    final String colorSubtitle = selectedColor != null
        ? strings.manageCategoriesColorSelected
        : strings.manageCategoriesColorNone;

    final PhosphorIconPickerLabels pickerLabels = PhosphorIconPickerLabels(
      title: strings.manageCategoriesIconPickerTitle,
      emptyStateLabel: strings.manageCategoriesIconEmpty,
      styleLabels: <PhosphorIconStyle, String>{
        PhosphorIconStyle.thin: strings.manageCategoriesIconStyleThin,
        PhosphorIconStyle.light: strings.manageCategoriesIconStyleLight,
        PhosphorIconStyle.regular: strings.manageCategoriesIconStyleRegular,
        PhosphorIconStyle.bold: strings.manageCategoriesIconStyleBold,
        PhosphorIconStyle.fill: strings.manageCategoriesIconStyleFill,
      },
      groupLabels: <String, String>{
        'finance': strings.manageCategoriesIconGroupFinance,
        'shopping': strings.manageCategoriesIconGroupShopping,
        'food': strings.manageCategoriesIconGroupFood,
        'transport': strings.manageCategoriesIconGroupTransport,
        'home': strings.manageCategoriesIconGroupHome,
        'leisure': strings.manageCategoriesIconGroupLeisure,
      },
    );

    final EdgeInsets viewInsets = MediaQuery.of(context).viewInsets;

    Future<void> selectColor() async {
      final String? hex = await _showCategoryColorPickerDialog(
        context: context,
        strings: strings,
        initialColor: selectedColor,
      );
      if (hex != null) {
        controller.updateColor(hex);
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              key: ValueKey<String>(
                'category-name-${state.id}-${state.updatedAt.millisecondsSinceEpoch}',
              ),
              initialValue: state.name,
              decoration: InputDecoration(
                labelText: strings.manageCategoriesNameLabel,
                errorText: state.nameHasError
                    ? strings.manageCategoriesNameRequired
                    : null,
              ),
              textInputAction: TextInputAction.next,
              onChanged: controller.updateName,
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: InputDecoration(
                labelText: strings.manageCategoriesTypeLabel,
              ),
              child: SegmentedButton<String>(
                segments: <ButtonSegment<String>>[
                  ButtonSegment<String>(
                    value: 'expense',
                    label: Text(strings.manageCategoriesTypeExpense),
                  ),
                  ButtonSegment<String>(
                    value: 'income',
                    label: Text(strings.manageCategoriesTypeIncome),
                  ),
                ],
                selected: <String>{state.type},
                onSelectionChanged: (Set<String> values) {
                  if (values.isEmpty) return;
                  controller.updateType(values.first);
                },
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.surfaceVariant,
                child: iconData != null
                    ? Icon(iconData)
                    : const Icon(Icons.category_outlined),
              ),
              title: Text(strings.manageCategoriesIconLabel),
              subtitle: Text(iconSubtitle),
              trailing: Wrap(
                spacing: 8,
                children: <Widget>[
                  if (state.icon?.isNotEmpty == true)
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: strings.manageCategoriesIconClear,
                      onPressed: () => controller.updateIcon(null),
                    ),
                  IconButton(
                    icon: const Icon(Icons.grid_view),
                    tooltip: strings.manageCategoriesIconSelect,
                    onPressed: () async {
                      final PhosphorIconDescriptor? selection =
                          await showPhosphorIconPicker(
                            context: context,
                            labels: pickerLabels,
                            initial: state.icon,
                          );
                      if (selection != null) {
                        controller.updateIcon(
                          selection.isEmpty ? null : selection,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                key: const ValueKey<String>('category-color-preview'),
                backgroundColor:
                    selectedColor ?? theme.colorScheme.surfaceVariant,
                child: selectedColor == null
                    ? Icon(
                        Icons.palette_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
              title: Text(strings.manageCategoriesColorLabel),
              subtitle: Text(colorSubtitle),
              onTap: selectColor,
              trailing: Wrap(
                spacing: 8,
                children: <Widget>[
                  if (selectedColor != null)
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: strings.manageCategoriesColorClear,
                      onPressed: () => controller.updateColor(null),
                    ),
                  IconButton(
                    icon: const Icon(Icons.color_lens_outlined),
                    tooltip: strings.manageCategoriesColorSelect,
                    onPressed: selectColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: state.isSaving || !state.hasChanges
                  ? null
                  : () => controller.submit(),
              icon: state.isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(strings.manageCategoriesSaveCta),
            ),
            if (state.errorMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                strings.manageCategoriesSaveError(state.errorMessage!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<String?> _showCategoryColorPickerDialog({
  required BuildContext context,
  required AppLocalizations strings,
  Color? initialColor,
}) {
  return showDialog<String>(
    context: context,
    useRootNavigator: false,
    builder: (BuildContext dialogContext) {
      return _CategoryColorPickerDialog(
        initialColor: initialColor,
        strings: strings,
      );
    },
  );
}

class _CategoryColorPickerDialog extends StatefulWidget {
  const _CategoryColorPickerDialog({this.initialColor, required this.strings});

  final Color? initialColor;
  final AppLocalizations strings;

  @override
  State<_CategoryColorPickerDialog> createState() =>
      _CategoryColorPickerDialogState();
}

class _CategoryColorPickerDialogState
    extends State<_CategoryColorPickerDialog> {
  Color? _draftColor;

  @override
  void initState() {
    super.initState();
    _draftColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AlertDialog(
      title: Text(widget.strings.manageCategoriesColorPickerTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: kCategoryPastelPalette
                .asMap()
                .entries
                .map((MapEntry<int, Color> entry) {
                  final Color color = entry.value;
                  final bool isSelected = _draftColor?.value == color.value;
                  return InkResponse(
                    key: ValueKey<String>('category-color-${entry.key}'),
                    radius: 24,
                    onTap: () => setState(() => _draftColor = color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                })
                .toList(growable: false),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.strings.dialogCancel),
        ),
        FilledButton(
          onPressed: _draftColor == null
              ? null
              : () => Navigator.of(context).pop(colorToHex(_draftColor!)!),
          child: Text(widget.strings.dialogConfirm),
        ),
      ],
    );
  }
}

List<String> _buildMetadata(Category category, AppLocalizations strings) {
  final List<String> metadata = <String>[];
  final String typeLabel = category.type.toLowerCase() == 'income'
      ? strings.manageCategoriesTypeIncome
      : strings.manageCategoriesTypeExpense;
  metadata.add(typeLabel);
  return metadata;
}
