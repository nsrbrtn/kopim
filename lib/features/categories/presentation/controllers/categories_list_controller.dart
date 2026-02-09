import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/categories/domain/entities/category_tree_node.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'categories_list_controller.g.dart';

@riverpod
Stream<List<CategoryTreeNode>> manageCategoryTree(Ref ref) {
  return ref
      .watch(watchCategoryTreeUseCaseProvider)
      .call()
      .map(_filterHiddenNodes);
}

List<CategoryTreeNode> _filterHiddenNodes(List<CategoryTreeNode> nodes) {
  final List<CategoryTreeNode> result = <CategoryTreeNode>[];
  for (final CategoryTreeNode node in nodes) {
    if (node.category.isHidden) {
      continue;
    }
    final List<CategoryTreeNode> filteredChildren = _filterHiddenNodes(
      node.children,
    );
    result.add(node.copyWith(children: filteredChildren));
  }
  return result;
}
