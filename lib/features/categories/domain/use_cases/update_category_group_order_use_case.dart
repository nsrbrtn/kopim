import 'package:kopim/features/categories/domain/repositories/category_group_repository.dart';

class UpdateCategoryGroupOrderUseCase {
  UpdateCategoryGroupOrderUseCase(this._repository);

  final CategoryGroupRepository _repository;

  Future<void> call(List<String> orderedIds) {
    return _repository.updateGroupOrders(orderedIds);
  }
}
