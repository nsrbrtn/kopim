import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';

class WatchCategoriesUseCase {
  WatchCategoriesUseCase(this._repository);

  final CategoryRepository _repository;

  Stream<List<Category>> call() {
    return _repository.watchCategories();
  }
}
