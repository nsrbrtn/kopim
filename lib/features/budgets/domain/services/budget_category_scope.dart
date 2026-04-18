import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_category_allocation.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/services/category_hierarchy.dart';

Set<String> expandBudgetCategoryIds({
  required Iterable<String> categoryIds,
  required Iterable<Category> categories,
}) {
  final CategoryHierarchy hierarchy = CategoryHierarchy(categories);
  final Set<String> expanded = <String>{};
  for (final String categoryId in categoryIds) {
    if (categoryId.isEmpty) {
      continue;
    }
    expanded.add(categoryId);
    if (hierarchy.contains(categoryId)) {
      expanded.addAll(hierarchy.descendantsOf(categoryId));
    }
  }
  return expanded;
}

Set<String> resolveBudgetScopedCategoryIds({
  required Budget budget,
  required Iterable<Category> categories,
}) {
  final Set<String> explicitIds = <String>{
    ...budget.categories,
    ...budget.categoryAllocations.map(
      (BudgetCategoryAllocation allocation) => allocation.categoryId,
    ),
  };
  return expandBudgetCategoryIds(
    categoryIds: explicitIds,
    categories: categories,
  );
}

Map<String, BudgetCategoryAllocation> resolveBudgetAllocationMap(
  Budget budget,
) {
  return <String, BudgetCategoryAllocation>{
    for (final BudgetCategoryAllocation allocation
        in budget.categoryAllocations)
      allocation.categoryId: allocation,
  };
}

Set<String> resolveBudgetExplicitCategoryIds(Budget budget) {
  return resolveBudgetAllocationMap(budget).keys.toSet();
}

String? resolveBudgetExplicitParentCategoryId({
  required Budget budget,
  required Iterable<Category> categories,
  required String categoryId,
}) {
  final Map<String, BudgetCategoryAllocation> allocationsById =
      resolveBudgetAllocationMap(budget);
  final Map<String, Category> categoriesById = <String, Category>{
    for (final Category category in categories) category.id: category,
  };

  String? currentParentId = categoriesById[categoryId]?.parentId;
  while (currentParentId != null && currentParentId.isNotEmpty) {
    if (allocationsById.containsKey(currentParentId)) {
      return currentParentId;
    }
    currentParentId = categoriesById[currentParentId]?.parentId;
  }
  return null;
}

List<String> resolveBudgetExplicitChildCategoryIds({
  required Budget budget,
  required Iterable<Category> categories,
  required String parentCategoryId,
}) {
  final Set<String> explicitIds = resolveBudgetExplicitCategoryIds(budget);
  final List<String> childIds = <String>[];
  for (final String categoryId in explicitIds) {
    if (categoryId == parentCategoryId) {
      continue;
    }
    final String? parentId = resolveBudgetExplicitParentCategoryId(
      budget: budget,
      categories: categories,
      categoryId: categoryId,
    );
    if (parentId == parentCategoryId) {
      childIds.add(categoryId);
    }
  }
  return childIds;
}

List<String> resolveBudgetAllocationRootIds({
  required Budget budget,
  required Iterable<Category> categories,
}) {
  final Set<String> explicitIds = resolveBudgetExplicitCategoryIds(budget);
  return explicitIds
      .where(
        (String categoryId) =>
            resolveBudgetExplicitParentCategoryId(
              budget: budget,
              categories: categories,
              categoryId: categoryId,
            ) ==
            null,
      )
      .toList(growable: false);
}

double? resolveBudgetCategoryLimit(Budget budget, String categoryId) {
  final BudgetCategoryAllocation? allocation = resolveBudgetAllocationMap(
    budget,
  )[categoryId];
  if (allocation != null) {
    return allocation.limitValue.toDouble();
  }
  if (budget.scope == BudgetScope.byCategory &&
      budget.categoryAllocations.isEmpty &&
      budget.categories.length == 1 &&
      budget.categories.first == categoryId) {
    return budget.amountValue.toDouble();
  }
  return null;
}

double? resolveBudgetCategoryDirectLimit({
  required Budget budget,
  required Iterable<Category> categories,
  required String categoryId,
}) {
  final double? explicitLimit = resolveBudgetCategoryLimit(budget, categoryId);
  if (explicitLimit == null) {
    return null;
  }

  final List<String> childAllocationIds = resolveBudgetExplicitChildCategoryIds(
    budget: budget,
    categories: categories,
    parentCategoryId: categoryId,
  );
  if (childAllocationIds.isEmpty) {
    return explicitLimit;
  }

  final double allocatedToChildren = childAllocationIds.fold<double>(
    0,
    (double sum, String childId) =>
        sum + (resolveBudgetCategoryLimit(budget, childId) ?? 0),
  );
  final double directLimit = explicitLimit - allocatedToChildren;
  return directLimit < 0 ? 0 : directLimit;
}

Set<String> resolveBudgetCategoryCoveredIds({
  required Budget budget,
  required Iterable<Category> categories,
  required String categoryId,
}) {
  final CategoryHierarchy hierarchy = CategoryHierarchy(categories);
  final Set<String> coveredIds = <String>{
    categoryId,
    ...hierarchy.descendantsOf(categoryId),
  };
  for (final String childAllocationId in resolveBudgetExplicitChildCategoryIds(
    budget: budget,
    categories: categories,
    parentCategoryId: categoryId,
  )) {
    coveredIds.remove(childAllocationId);
    coveredIds.removeAll(hierarchy.descendantsOf(childAllocationId));
  }
  return coveredIds;
}

String? resolveBudgetTransactionAllocationCategoryId({
  required Budget budget,
  required Iterable<Category> categories,
  required String categoryId,
}) {
  final Set<String> explicitIds = resolveBudgetExplicitCategoryIds(budget);
  if (explicitIds.isEmpty) {
    return categoryId;
  }

  final Map<String, Category> categoriesById = <String, Category>{
    for (final Category category in categories) category.id: category,
  };
  String? currentCategoryId = categoryId;
  while (currentCategoryId != null && currentCategoryId.isNotEmpty) {
    if (explicitIds.contains(currentCategoryId)) {
      return currentCategoryId;
    }
    currentCategoryId = categoriesById[currentCategoryId]?.parentId;
  }
  return null;
}
