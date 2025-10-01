import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';

class SaveCategoryUseCase {
  SaveCategoryUseCase(this._repository);

  final CategoryRepository _repository;

  Future<void> call(Category category) {
    return _repository.upsert(category);
  }
}
