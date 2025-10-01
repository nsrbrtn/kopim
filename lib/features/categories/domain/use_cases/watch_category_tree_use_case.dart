import 'package:kopim/features/categories/domain/entities/category_tree_node.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';

class WatchCategoryTreeUseCase {
  WatchCategoryTreeUseCase(this._repository);

  final CategoryRepository _repository;

  Stream<List<CategoryTreeNode>> call() {
    return _repository.watchCategoryTree();
  }
}
