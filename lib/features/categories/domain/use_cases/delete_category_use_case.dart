import 'package:kopim/features/categories/domain/repositories/category_repository.dart';

/// Use case responsible for deleting a category and all of its descendants.
class DeleteCategoryUseCase {
  const DeleteCategoryUseCase(this._repository);

  final CategoryRepository _repository;

  /// Marks the category and its descendants as deleted.
  Future<void> call(String id) {
    return _repository.softDelete(id);
  }
}
