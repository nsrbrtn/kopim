import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/animated_fab.dart';
import 'package:kopim/core/widgets/kopim_floating_action_button.dart';
import 'package:kopim/core/widgets/kopim_glass_fab.dart';
import 'package:kopim/core/widgets/kopim_segmented_control.dart';
import 'package:kopim/core/widgets/kopim_text_field.dart';
import 'package:kopim/core/widgets/phosphor_icon_picker.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/entities/category_tree_node.dart';
import 'package:kopim/features/categories/presentation/controllers/categories_list_controller.dart';
import 'package:kopim/features/categories/presentation/controllers/category_form_controller.dart';
import 'package:kopim/features/categories/presentation/utils/category_color_palette.dart';
import 'package:kopim/features/categories/presentation/utils/category_gradients.dart';
import 'package:kopim/features/tags/presentation/screens/manage_tags_tab.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ManageCategoriesScreen extends ConsumerStatefulWidget {
  const ManageCategoriesScreen({super.key});

  static const String routeName = '/categories/manage';

  @override
  ConsumerState<ManageCategoriesScreen> createState() =>
      _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends ConsumerState<ManageCategoriesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<List<CategoryTreeNode>> treeAsync = ref.watch(
      manageCategoryTreeProvider,
    );

    final List<CategoryTreeNode> tree =
        treeAsync.asData?.value ?? const <CategoryTreeNode>[];
    final List<Category> rootCategories = tree
        .map((CategoryTreeNode node) => node.category)
        .toList();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isTagsTab = _tabController.index == 1;
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.profileManageCategoriesTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(text: strings.manageCategoriesTabCategories),
            Tab(text: strings.manageCategoriesTabTags),
          ],
        ),
      ),
      floatingActionButton: AnimatedFab(
        child: KopimGlassFab(
          onPressed: isTagsTab
              ? () => showTagEditor(context, ref, strings: strings)
              : () => _showCategoryEditor(
                  context,
                  ref,
                  strings: strings,
                  parents: rootCategories,
                ),
          tooltip: isTagsTab
              ? strings.manageTagsAddAction
              : strings.manageCategoriesAddAction,
          icon: Icon(Icons.add, color: colorScheme.primary),
          foregroundColor: colorScheme.primary,
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            treeAsync.when(
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
                );
              },
              error: (Object error, StackTrace? stackTrace) => _ErrorView(
                message: strings.manageCategoriesListError(error.toString()),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
            const ManageTagsTab(),
          ],
        ),
      ),
    );
  }
}

Future<bool> _deleteCategoryFlow(
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
    return false;
  }

  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(deleteCategoryUseCaseProvider)(category.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Text(strings.manageCategoriesDeleteSuccess),
        ),
      );
    return true;
  } catch (error) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Text(strings.manageCategoriesDeleteError(error.toString())),
        ),
      );
    return false;
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
      ..showSnackBar(
        SnackBar(duration: const Duration(seconds: 3), content: Text(message)),
      );
  }
}

class _CategoryTreeList extends StatelessWidget {
  const _CategoryTreeList({
    required this.tree,
    required this.strings,
    required this.onEditCategory,
  });

  final List<CategoryTreeNode> tree;
  final AppLocalizations strings;
  final Future<void> Function(Category) onEditCategory;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final KopimLayout layout = theme.kopimLayout;
    final double bottomPadding =
        KopimFloatingActionButton.defaultSize + layout.spacing.section * 2;
    final List<_FlattenedCategoryItem> items = _flattenCategoryTree(tree);

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(12, 8, 12, bottomPadding),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final _FlattenedCategoryItem item = items[index];
        return _CategoryListTile(
          key: ValueKey<String>('category-tile:${item.category.id}'),
          item: item,
          strings: strings,
          onEdit: () => onEditCategory(item.category),
        );
      },
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 12),
    );
  }
}

class _FlattenedCategoryItem {
  const _FlattenedCategoryItem({required this.category, required this.depth});

  final Category category;
  final int depth;
}

List<_FlattenedCategoryItem> _flattenCategoryTree(List<CategoryTreeNode> tree) {
  final List<_FlattenedCategoryItem> items = <_FlattenedCategoryItem>[];
  void visit(CategoryTreeNode node, int depth) {
    items.add(_FlattenedCategoryItem(category: node.category, depth: depth));
    for (final CategoryTreeNode child in node.children) {
      visit(child, depth + 1);
    }
  }

  for (final CategoryTreeNode node in tree) {
    visit(node, 0);
  }
  return items;
}

class _CategoryListTile extends StatelessWidget {
  const _CategoryListTile({
    super.key,
    required this.item,
    required this.strings,
    required this.onEdit,
  });

  final _FlattenedCategoryItem item;
  final AppLocalizations strings;
  final Future<void> Function() onEdit;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Category category = item.category;
    final bool isSubcategory = item.depth > 0;
    final IconData? iconData = resolvePhosphorIconData(category.icon);
    final CategoryColorStyle colorStyle = resolveCategoryColorStyle(
      category.color,
    );
    final List<String> metadata = _buildMetadata(category, strings);
    final double horizontalIndent = 12 + (item.depth * 16);
    final double leftContentPadding = isSubcategory ? 8 : horizontalIndent;
    final double iconSize = isSubcategory ? 40 : 48;
    final TextStyle? titleStyle =
        (isSubcategory
                ? theme.textTheme.labelMedium
                : theme.textTheme.labelLarge)
            ?.copyWith(color: theme.colorScheme.onSurface);

    final Widget tile = Material(
      color: isSubcategory
          ? theme.colorScheme.surfaceContainerHigh
          : theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(isSubcategory ? 16 : 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(isSubcategory ? 16 : 20),
        onTap: onEdit,
        child: Padding(
          padding: EdgeInsets.fromLTRB(leftContentPadding, 8, 8, 8),
          child: Row(
            children: <Widget>[
              _CategoryIcon(
                iconData: iconData,
                backgroundColor: colorStyle.color,
                backgroundGradient: colorStyle.backgroundGradient,
                sampleColor: colorStyle.sampleColor,
                size: iconSize,
                borderRadius: BorderRadius.circular(isSubcategory ? 10 : 12),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      metadata.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (!isSubcategory) {
      return tile;
    }
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(widthFactor: 0.9, child: tile),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({
    this.iconData,
    this.backgroundColor,
    this.backgroundGradient,
    this.sampleColor,
    required this.size,
    required this.borderRadius,
  });

  final IconData? iconData;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final Color? sampleColor;
  final double size;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color avatarBackground =
        backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final Color resolvedSample =
        sampleColor ??
        backgroundColor ??
        theme.colorScheme.surfaceContainerHigh;
    final Color avatarForeground =
        (sampleColor != null || backgroundColor != null)
        ? (ThemeData.estimateBrightnessForColor(resolvedSample) ==
                  Brightness.dark
              ? Colors.white
              : Colors.black87)
        : theme.colorScheme.onSurface;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: backgroundGradient,
        color: backgroundGradient == null ? avatarBackground : null,
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      child: Icon(iconData ?? Icons.category_outlined, color: avatarForeground),
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

class _CategoryEditorSheet extends ConsumerStatefulWidget {
  const _CategoryEditorSheet({
    this.category,
    required this.parents,
    this.defaultParentId,
  });

  final Category? category;
  final List<Category> parents;
  final String? defaultParentId;

  @override
  ConsumerState<_CategoryEditorSheet> createState() =>
      _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends ConsumerState<_CategoryEditorSheet> {
  late final CategoryFormParams _params;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _params = CategoryFormParams(
      initial: widget.category,
      parents: widget.parents,
      defaultParentId: widget.defaultParentId,
    );
    final CategoryFormState initialState = ref.read(
      categoryFormControllerProvider(_params),
    );
    _nameController = TextEditingController(text: initialState.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    ref.listen<CategoryFormState>(categoryFormControllerProvider(_params), (
      CategoryFormState? previous,
      CategoryFormState next,
    ) {
      if (previous?.name != next.name && _nameController.text != next.name) {
        _nameController.value = _nameController.value.copyWith(
          text: next.name,
          selection: TextSelection.collapsed(offset: next.name.length),
        );
      }
      if (next.isSuccess && previous?.isSuccess != next.isSuccess) {
        ref
            .read(categoryFormControllerProvider(_params).notifier)
            .resetSuccess();
        Navigator.of(context).pop(true);
      } else if (next.errorMessage == duplicateCategoryNameErrorKey &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 3),
              content: Text(strings.manageCategoriesDuplicateNameError),
            ),
          );
      } else if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 3),
              content: Text(
                strings.manageCategoriesSaveError(next.errorMessage!),
              ),
            ),
          );
      }
    });

    final CategoryFormState state = ref.watch(
      categoryFormControllerProvider(_params),
    );
    final CategoryFormController controller = ref.read(
      categoryFormControllerProvider(_params).notifier,
    );

    final ThemeData theme = Theme.of(context);
    final String title = widget.category == null
        ? strings.manageCategoriesCreateTitle
        : strings.manageCategoriesEditTitle;
    final PhosphorIconData? iconData = resolvePhosphorIconData(state.icon);
    final String iconSubtitle = state.icon?.isNotEmpty == true
        ? strings.manageCategoriesIconSelected
        : strings.manageCategoriesIconNone;
    final CategoryColorStyle colorStyle = resolveCategoryColorStyle(
      state.color,
    );
    final CategoryGradient? selectedGradient = colorStyle.gradient;
    final Color? selectedColor = colorStyle.sampleColor;
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
        'groceries': strings.manageCategoriesIconGroupGroceries,
        'dining': strings.manageCategoriesIconGroupDining,
        'clothing': strings.manageCategoriesIconGroupClothing,
        'home': strings.manageCategoriesIconGroupHome,
        'utilities': strings.manageCategoriesIconGroupUtilities,
        'communication': strings.manageCategoriesIconGroupCommunication,
        'subscriptions': strings.manageCategoriesIconGroupSubscriptions,
        'publicTransport': strings.manageCategoriesIconGroupPublicTransport,
        'car': strings.manageCategoriesIconGroupCar,
        'taxi': strings.manageCategoriesIconGroupTaxi,
        'travel': strings.manageCategoriesIconGroupTravel,
        'health': strings.manageCategoriesIconGroupHealth,
        'security': strings.manageCategoriesIconGroupSecurity,
        'education': strings.manageCategoriesIconGroupEducation,
        'family': strings.manageCategoriesIconGroupFamily,
        'pets': strings.manageCategoriesIconGroupPets,
        'maintenance': strings.manageCategoriesIconGroupMaintenance,
        'entertainment': strings.manageCategoriesIconGroupEntertainment,
        'sports': strings.manageCategoriesIconGroupSports,
        'finance': strings.manageCategoriesIconGroupFinance,
        'loans': strings.manageCategoriesIconGroupLoans,
        'documents': strings.manageCategoriesIconGroupDocuments,
        'settings': strings.manageCategoriesIconGroupSettings,
        'transactionTypes': strings.manageCategoriesIconGroupTransactionTypes,
      },
    );

    final EdgeInsets viewInsets = MediaQuery.of(context).viewInsets;

    Future<void> selectColor() async {
      final String? hex = await _showCategoryColorPickerDialog(
        context: context,
        strings: strings,
        initialColor: selectedGradient == null ? selectedColor : null,
        initialGradientId: selectedGradient?.id,
      );
      if (hex != null) {
        controller.updateColor(hex);
      }
    }

    Future<void> selectIcon() async {
      final PhosphorIconDescriptor? selection = await showPhosphorIconPicker(
        context: context,
        labels: pickerLabels,
        initial: state.icon,
        allowedStyles: const <PhosphorIconStyle>{PhosphorIconStyle.fill},
      );
      if (selection != null) {
        controller.updateIcon(selection.isEmpty ? null : selection);
      }
    }

    Future<void> addSubcategory() async {
      if (state.initialCategory == null) {
        final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            content: Text(strings.manageCategoriesAddSubcategorySaveFirst),
          ),
        );
        return;
      }
      await _showCategoryEditor(
        context,
        ref,
        strings: strings,
        parents: widget.parents,
        defaultParentId: state.id,
      );
    }

    Future<void> deleteCategory() async {
      final Category? category = state.initialCategory;
      if (category == null) {
        return;
      }
      final bool didDelete = await _deleteCategoryFlow(
        context,
        ref,
        strings: strings,
        category: category,
      );
      if (didDelete && context.mounted) {
        Navigator.of(context).pop(false);
      }
    }

    final bool isFormComplete =
        state.name.trim().isNotEmpty &&
        (state.icon?.isNotEmpty ?? false) &&
        state.color.trim().isNotEmpty;
    final bool canSubmit =
        !state.isSaving && state.hasChanges && isFormComplete;

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
            Text(
              strings.manageCategoriesNameLabel,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            KopimTextField(
              controller: _nameController,
              placeholder: strings.manageCategoriesNameLabel,
              textInputAction: TextInputAction.next,
              onChanged: controller.updateName,
            ),
            if (state.nameHasError) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                strings.manageCategoriesNameRequired,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              strings.manageCategoriesTypeLabel,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            KopimSegmentedControl<String>(
              options: <KopimSegmentedOption<String>>[
                KopimSegmentedOption<String>(
                  value: 'expense',
                  label: strings.manageCategoriesTypeExpense,
                ),
                KopimSegmentedOption<String>(
                  value: 'income',
                  label: strings.manageCategoriesTypeIncome,
                ),
              ],
              selectedValue: state.type,
              onChanged: controller.updateType,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(strings.manageCategoriesIconLabel),
              subtitle: Text(iconSubtitle),
              onTap: selectIcon,
              trailing: CircleAvatar(
                backgroundColor: theme.colorScheme.surfaceContainerHigh,
                foregroundColor: theme.colorScheme.onSurface,
                child: iconData != null
                    ? Icon(iconData, color: theme.colorScheme.onSurface)
                    : const Icon(Icons.category_outlined),
              ),
            ),
            if (state.icon?.isNotEmpty == true)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => controller.updateIcon(null),
                  child: Text(strings.manageCategoriesIconClear),
                ),
              ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(strings.manageCategoriesColorLabel),
              subtitle: Text(colorSubtitle),
              onTap: selectColor,
              trailing: Container(
                key: const ValueKey<String>('category-color-preview'),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: selectedGradient?.toGradient(),
                  color: selectedGradient == null
                      ? (selectedColor ??
                            theme.colorScheme.surfaceContainerHigh)
                      : null,
                ),
                alignment: Alignment.center,
                child: selectedColor == null
                    ? const Icon(Icons.palette_outlined)
                    : null,
              ),
            ),
            if (selectedColor != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => controller.updateColor(null),
                  child: Text(strings.manageCategoriesColorClear),
                ),
              ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: state.isFavorite,
              onChanged: controller.updateFavorite,
              title: Text(strings.manageCategoriesFavoriteLabel),
              subtitle: Text(strings.manageCategoriesFavoriteSubtitle),
            ),
            const SizedBox(height: 16),
            if (!state.isNew &&
                state.initialCategory?.parentId == null) ...<Widget>[
              TextButton.icon(
                onPressed: addSubcategory,
                icon: const Icon(Icons.subdirectory_arrow_right_outlined),
                label: Text(strings.manageCategoriesAddSubcategoryAction),
              ),
              const SizedBox(height: 24),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if (!state.isNew)
                  FloatingActionButton(
                    heroTag: 'category-editor-delete-fab',
                    tooltip: strings.manageCategoriesDeleteAction,
                    onPressed: state.isSaving ? null : deleteCategory,
                    backgroundColor: theme.colorScheme.errorContainer,
                    foregroundColor: theme.colorScheme.onErrorContainer,
                    child: const Icon(Icons.delete_outline),
                  )
                else
                  const SizedBox(width: 56, height: 56),
                FloatingActionButton(
                  heroTag: 'category-editor-save-fab',
                  tooltip: strings.manageCategoriesSaveCta,
                  onPressed: canSubmit ? controller.submit : null,
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  child: state.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                ),
              ],
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
  String? initialGradientId,
}) {
  return showDialog<String>(
    context: context,
    useRootNavigator: false,
    builder: (BuildContext dialogContext) {
      return _CategoryColorPickerDialog(
        initialColor: initialColor,
        initialGradientId: initialGradientId,
        strings: strings,
      );
    },
  );
}

class _CategoryColorPickerDialog extends StatefulWidget {
  const _CategoryColorPickerDialog({
    this.initialColor,
    this.initialGradientId,
    required this.strings,
  });

  final Color? initialColor;
  final String? initialGradientId;
  final AppLocalizations strings;

  @override
  State<_CategoryColorPickerDialog> createState() =>
      _CategoryColorPickerDialogState();
}

class _CategoryColorPickerDialogState
    extends State<_CategoryColorPickerDialog> {
  Color? _draftColor;
  String? _draftGradientId;

  @override
  void initState() {
    super.initState();
    _draftColor = widget.initialColor;
    _draftGradientId = widget.initialGradientId;
    if (_draftGradientId != null && _draftColor == null) {
      final CategoryGradient? gradient = resolveCategoryGradient(
        encodeCategoryGradientId(_draftGradientId!),
      );
      _draftColor = gradient?.sampleColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AlertDialog(
      title: Text(widget.strings.manageCategoriesColorPickerTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.strings.accountColorGradient,
                style: theme.textTheme.labelSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: kCategoryGradients
                    .asMap()
                    .entries
                    .map((MapEntry<int, CategoryGradient> entry) {
                      final CategoryGradient gradient = entry.value;
                      final bool isSelected = _draftGradientId == gradient.id;
                      return InkResponse(
                        key: ValueKey<String>('category-gradient-${entry.key}'),
                        radius: 24,
                        onTap: () => setState(() {
                          _draftGradientId = gradient.id;
                          _draftColor = gradient.sampleColor;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: gradient.toGradient(),
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
              const SizedBox(height: 16),
              Text(
                widget.strings.manageCategoriesColorLabel,
                style: theme.textTheme.labelSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: kCategoryPastelPalette
                    .asMap()
                    .entries
                    .map((MapEntry<int, Color> entry) {
                      final Color color = entry.value;
                      final bool isSelected =
                          _draftGradientId == null && _draftColor == color;
                      return InkResponse(
                        key: ValueKey<String>('category-color-${entry.key}'),
                        radius: 24,
                        onTap: () => setState(() {
                          _draftColor = color;
                          _draftGradientId = null;
                        }),
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
          onPressed: _draftColor == null
              ? null
              : () => Navigator.of(context).pop(
                  _draftGradientId != null
                      ? encodeCategoryGradientId(_draftGradientId!)
                      : colorToHex(_draftColor!)!,
                ),
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
