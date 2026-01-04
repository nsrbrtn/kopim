import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/exceptions/duplicate_category_name_exception.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';

class SaveCategoryUseCase {
  SaveCategoryUseCase(this._repository);

  final CategoryRepository _repository;

  Future<void> call(Category category) async {
    final String? parentId = category.parentId?.trim();
    if (parentId != null && parentId.isNotEmpty) {
      if (parentId == category.id) {
        throw ArgumentError('Category cannot be its own parent');
      }
      final Category? parent = await _repository.findById(parentId);
      if (parent == null) {
        throw StateError('Parent category not found');
      }
      if (parent.parentId != null && parent.parentId!.isNotEmpty) {
        throw StateError(
          'Nested subcategories deeper than one level are not supported',
        );
      }
    }
    final Category? duplicate = await _repository.findByName(category.name);
    if (duplicate != null && duplicate.id != category.id) {
      throw const DuplicateCategoryNameException();
    }
    await _repository.upsert(
      category.copyWith(parentId: parentId?.isEmpty ?? true ? null : parentId),
    );
  }
}
