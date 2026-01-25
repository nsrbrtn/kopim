import 'package:kopim/features/categories/domain/entities/category_group.dart';
import 'package:kopim/features/categories/domain/exceptions/duplicate_category_group_name_exception.dart';
import 'package:kopim/features/categories/domain/repositories/category_group_repository.dart';

class SaveCategoryGroupUseCase {
  SaveCategoryGroupUseCase(this._repository);

  final CategoryGroupRepository _repository;

  Future<void> call(CategoryGroup group) async {
    final CategoryGroup? duplicate = await _repository.findByName(group.name);
    if (duplicate != null && duplicate.id != group.id) {
      throw DuplicateCategoryGroupNameException();
    }
    await _repository.upsertGroup(group);
  }
}
