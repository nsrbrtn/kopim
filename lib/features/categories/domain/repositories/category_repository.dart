import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/entities/category_tree_node.dart';

abstract class CategoryRepository {
  Stream<List<Category>> watchCategories();
  Stream<List<CategoryTreeNode>> watchCategoryTree();
  Future<List<Category>> loadCategories();
  Future<List<CategoryTreeNode>> loadCategoryTree();
  Future<Category?> findById(String id);
  Future<void> upsert(Category category);
  Future<void> softDelete(String id);
}
