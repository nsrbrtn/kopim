import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/entities/category_group.dart';
import 'package:kopim/features/categories/domain/entities/category_group_link.dart';
import 'package:kopim/features/categories/domain/entities/category_tree_node.dart';
import 'package:kopim/features/categories/domain/exceptions/duplicate_category_group_name_exception.dart';
import 'package:kopim/features/categories/presentation/controllers/categories_list_controller.dart';
import 'package:kopim/features/categories/presentation/controllers/category_groups_controller.dart';
import 'package:kopim/features/categories/presentation/utils/category_grouping.dart';
import 'package:kopim/l10n/app_localizations.dart';

class EditCategoryGroupScreen extends ConsumerStatefulWidget {
  const EditCategoryGroupScreen({super.key, this.group});

  static const String routeName = '/categories/group';

  final CategoryGroup? group;

  static Route<void> route({CategoryGroup? group}) {
    return MaterialPageRoute<void>(
      builder: (_) => EditCategoryGroupScreen(group: group),
      settings: const RouteSettings(name: routeName),
    );
  }

  @override
  ConsumerState<EditCategoryGroupScreen> createState() =>
      _EditCategoryGroupScreenState();
}

class EditCategoryGroupScreenArgs {
  const EditCategoryGroupScreenArgs({this.group});

  final CategoryGroup? group;

  static EditCategoryGroupScreenArgs fromState(GoRouterState state) {
    final Object? extra = state.extra;
    if (extra is EditCategoryGroupScreenArgs) {
      return extra;
    }
    if (extra is CategoryGroup) {
      return EditCategoryGroupScreenArgs(group: extra);
    }
    return const EditCategoryGroupScreenArgs();
  }

  String get location => EditCategoryGroupScreen.routeName;
}

class _EditCategoryGroupScreenState
    extends ConsumerState<EditCategoryGroupScreen> {
  late final TextEditingController _nameController;
  final Set<String> _selectedCategoryIds = <String>{};
  bool _didInitSelection = false;
  bool _isSaving = false;
  bool _isDeleting = false;

  bool get _isEdit => widget.group != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _initSelection(List<CategoryGroupLink> links) {
    if (_didInitSelection || !_isEdit) {
      return;
    }
    final String groupId = widget.group!.id;
    for (final CategoryGroupLink link in links) {
      if (link.groupId == groupId && !link.isDeleted) {
        _selectedCategoryIds.add(link.categoryId);
      }
    }
    _didInitSelection = true;
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      _showSnack(strings.manageCategoryGroupNameRequired);
      return;
    }
    setState(() => _isSaving = true);
    try {
      final CategoryGroup? existingGroup = widget.group;
      final List<CategoryGroup> groups =
          ref.read(categoryGroupsProvider).asData?.value ??
          const <CategoryGroup>[];
      final bool hasManualOrder = groups.any(
        (CategoryGroup group) => group.sortOrder != 0,
      );
      final int nextOrder = groups.isEmpty
          ? 0
          : groups
                    .map((CategoryGroup group) => group.sortOrder)
                    .reduce((int a, int b) => a > b ? a : b) +
                1;
      final CategoryGroup group =
          (existingGroup ??
                  CategoryGroup(
                    id: ref.read(uuidGeneratorProvider).v4(),
                    name: name,
                    sortOrder: hasManualOrder ? nextOrder : 0,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ))
              .copyWith(
                name: name,
                sortOrder:
                    existingGroup?.sortOrder ??
                    (hasManualOrder ? nextOrder : 0),
                updatedAt: DateTime.now(),
              );

      await ref.read(saveCategoryGroupUseCaseProvider).call(group);
      await ref
          .read(setCategoryGroupCategoriesUseCaseProvider)
          .call(groupId: group.id, categoryIds: _selectedCategoryIds);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on DuplicateCategoryGroupNameException {
      _showSnack(strings.manageCategoryGroupDuplicateNameError);
    } catch (error) {
      _showSnack(strings.manageCategoryGroupSaveError(error.toString()));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteGroup() async {
    if (_isDeleting || widget.group == null) return;
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(strings.manageCategoryGroupDeleteConfirmTitle),
        content: Text(strings.manageCategoryGroupDeleteConfirmMessage),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(strings.manageCategoryGroupDeleteConfirmAction),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;

    setState(() => _isDeleting = true);
    try {
      await ref.read(deleteCategoryGroupUseCaseProvider).call(widget.group!.id);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      _showSnack(strings.manageCategoryGroupDeleteError(error.toString()));
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _toggleCategory(String id) {
    setState(() {
      if (_selectedCategoryIds.contains(id)) {
        _selectedCategoryIds.remove(id);
      } else {
        _selectedCategoryIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      manageCategoriesProvider,
    );
    final AsyncValue<List<CategoryGroupLink>> linksAsync = ref.watch(
      categoryGroupLinksProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit
              ? strings.manageCategoryGroupEditTitle
              : strings.manageCategoryGroupCreateTitle,
        ),
        actions: <Widget>[
          if (_isEdit)
            IconButton(
              tooltip: strings.manageCategoryGroupDeleteAction,
              onPressed: _isDeleting ? null : _deleteGroup,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: SafeArea(
        child: linksAsync.when(
          data: (List<CategoryGroupLink> links) {
            _initSelection(links);
            return categoriesAsync.when(
              data: (List<Category> categories) {
                final List<Category> activeCategories = categories
                    .where((Category category) => !category.isDeleted)
                    .toList(growable: false);
                final List<_CategorySelectionNode> selectionNodes =
                    _buildSelectionNodes(activeCategories);
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: <Widget>[
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: strings.manageCategoryGroupNameLabel,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      strings.manageCategoryGroupCategoriesHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    for (final _CategorySelectionNode node in selectionNodes)
                      _CategorySelectionTile(
                        node: node,
                        selectedIds: _selectedCategoryIds,
                        onToggle: _toggleCategory,
                      ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(strings.manageCategoryGroupSaveCta),
                    ),
                  ],
                );
              },
              error: (Object error, _) => Center(child: Text(error.toString())),
              loading: () => const Center(child: CircularProgressIndicator()),
            );
          },
          error: (Object error, _) => Center(child: Text(error.toString())),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  List<_CategorySelectionNode> _buildSelectionNodes(List<Category> categories) {
    final List<_CategorySelectionNode> result = <_CategorySelectionNode>[];
    final List<CategoryTreeNode> tree = buildCategoryTree(categories);

    void visit(CategoryTreeNode node, int depth) {
      result.add(_CategorySelectionNode(category: node.category, depth: depth));
      for (final CategoryTreeNode child in node.children) {
        visit(child, depth + 1);
      }
    }

    for (final CategoryTreeNode node in tree) {
      visit(node, 0);
    }
    return result;
  }
}

class _CategorySelectionNode {
  const _CategorySelectionNode({required this.category, required this.depth});

  final Category category;
  final int depth;
}

class _CategorySelectionTile extends StatelessWidget {
  const _CategorySelectionTile({
    required this.node,
    required this.selectedIds,
    required this.onToggle,
  });

  final _CategorySelectionNode node;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final Category category = node.category;
    final bool selected = selectedIds.contains(category.id);
    final double indent = 12 * node.depth.toDouble();
    return CheckboxListTile(
      contentPadding: EdgeInsets.only(left: indent, right: 16),
      value: selected,
      onChanged: (_) => onToggle(category.id),
      title: Text(category.name),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
