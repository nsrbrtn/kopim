import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/entities/category_group.dart';
import 'package:kopim/features/categories/domain/entities/category_group_link.dart';
import 'package:kopim/features/categories/domain/entities/category_tree_node.dart';
import 'package:kopim/features/categories/domain/services/category_hierarchy.dart';
import 'package:kopim/features/categories/presentation/models/category_group_section.dart';

const String kFavoritesCategoryGroupId = '_favorites';
const String kOtherCategoryGroupId = '_other';

List<CategoryGroupSection> buildCategoryGroupSections({
  required List<Category> categories,
  required List<CategoryGroup> groups,
  required List<CategoryGroupLink> links,
  required String favoritesTitle,
  required String otherTitle,
}) {
  if (categories.isEmpty) {
    return const <CategoryGroupSection>[];
  }

  final Map<String, Category> categoriesById = <String, Category>{
    for (final Category category in categories) category.id: category,
  };
  final CategoryHierarchy hierarchy = CategoryHierarchy(categories);
  final Map<String, Set<String>> assignedByGroup = <String, Set<String>>{};
  for (final CategoryGroupLink link in links) {
    assignedByGroup
        .putIfAbsent(link.groupId, () => <String>{})
        .add(link.categoryId);
  }

  final List<CategoryGroup> activeGroups = groups
      .where((CategoryGroup group) => !group.isDeleted)
      .toList(growable: false);
  final bool hasManualOrder = activeGroups.any(
    (CategoryGroup group) => group.sortOrder != 0,
  );
  final List<CategoryGroup> orderedGroups =
      List<CategoryGroup>.from(activeGroups)
        ..sort((CategoryGroup a, CategoryGroup b) {
          if (hasManualOrder) {
            final int order = a.sortOrder.compareTo(b.sortOrder);
            if (order != 0) return order;
          }
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });

  final List<CategoryGroupSection> sections = <CategoryGroupSection>[];

  final List<Category> favorites =
      categories
          .where((Category category) => category.isFavorite)
          .toList(growable: false)
        ..sort(
          (Category a, Category b) =>
              a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
  if (favorites.isNotEmpty) {
    sections.add(
      CategoryGroupSection(
        id: kFavoritesCategoryGroupId,
        title: favoritesTitle,
        categories: favorites,
        isFavorites: true,
        isOther: false,
      ),
    );
  }

  final Set<String> allGroupedIds = <String>{};

  for (final CategoryGroup group in orderedGroups) {
    final Set<String> assigned = assignedByGroup[group.id] ?? <String>{};
    if (assigned.isEmpty) {
      sections.add(
        CategoryGroupSection(
          id: group.id,
          title: group.name,
          categories: const <Category>[],
          isFavorites: false,
          isOther: false,
          group: group,
        ),
      );
      continue;
    }
    final Set<String> expandedIds = <String>{};
    for (final String id in assigned) {
      expandedIds.add(id);
      expandedIds.addAll(hierarchy.descendantsOf(id));
    }
    allGroupedIds.addAll(expandedIds);
    final List<Category> groupCategories =
        expandedIds
            .map((String id) => categoriesById[id])
            .whereType<Category>()
            .toList(growable: false)
          ..sort(
            (Category a, Category b) =>
                a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
    sections.add(
      CategoryGroupSection(
        id: group.id,
        title: group.name,
        categories: groupCategories,
        isFavorites: false,
        isOther: false,
        group: group,
      ),
    );
  }

  final List<Category> otherCategories =
      categories
          .where((Category category) => !allGroupedIds.contains(category.id))
          .toList(growable: false)
        ..sort(
          (Category a, Category b) =>
              a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
  if (otherCategories.isNotEmpty) {
    sections.add(
      CategoryGroupSection(
        id: kOtherCategoryGroupId,
        title: otherTitle,
        categories: otherCategories,
        isFavorites: false,
        isOther: true,
      ),
    );
  }

  return sections;
}

List<CategoryTreeNode> buildCategoryTree(List<Category> categories) {
  if (categories.isEmpty) {
    return const <CategoryTreeNode>[];
  }
  final List<Category> sorted = List<Category>.from(categories)
    ..sort(
      (Category a, Category b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
  final Map<String, List<Category>> childrenByParent =
      <String, List<Category>>{};
  final Map<String, Category> byId = <String, Category>{
    for (final Category category in sorted) category.id: category,
  };

  for (final Category category in sorted) {
    final String? parentId = category.parentId;
    if (parentId == null || parentId.isEmpty) {
      continue;
    }
    childrenByParent.putIfAbsent(parentId, () => <Category>[]).add(category);
  }

  final List<CategoryTreeNode> result = <CategoryTreeNode>[];
  final Set<String> visited = <String>{};

  CategoryTreeNode buildNode(Category category) {
    if (!visited.add(category.id)) {
      return CategoryTreeNode(category: category);
    }
    final List<Category> children =
        List<Category>.from(childrenByParent[category.id] ?? const <Category>[])
          ..sort(
            (Category a, Category b) =>
                a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
    return CategoryTreeNode(
      category: category,
      children: children.map(buildNode).toList(growable: false),
    );
  }

  for (final Category category in sorted) {
    if (category.parentId == null || category.parentId!.isEmpty) {
      result.add(buildNode(category));
    }
  }

  for (final Category category in sorted) {
    if (visited.contains(category.id)) {
      continue;
    }
    final String? parentId = category.parentId;
    if (parentId != null &&
        parentId.isNotEmpty &&
        !byId.containsKey(parentId)) {
      result.add(buildNode(category));
    }
  }

  return result;
}
