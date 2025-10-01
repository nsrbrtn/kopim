import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';

part 'category_tree_node.freezed.dart';

@freezed
abstract class CategoryTreeNode with _$CategoryTreeNode {
  const factory CategoryTreeNode({
    required Category category,
    @Default(<CategoryTreeNode>[]) List<CategoryTreeNode> children,
  }) = _CategoryTreeNode;
}
