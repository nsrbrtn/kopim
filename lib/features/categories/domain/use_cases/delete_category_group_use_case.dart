import 'package:kopim/features/categories/domain/repositories/category_group_repository.dart';

class DeleteCategoryGroupUseCase {
  DeleteCategoryGroupUseCase(this._repository);

  final CategoryGroupRepository _repository;

  Future<void> call(String id) {
    return _repository.softDeleteGroup(id);
  }
}
