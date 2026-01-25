import 'package:kopim/features/categories/domain/entities/category_group.dart';
import 'package:kopim/features/categories/domain/repositories/category_group_repository.dart';

class WatchCategoryGroupsUseCase {
  WatchCategoryGroupsUseCase(this._repository);

  final CategoryGroupRepository _repository;

  Stream<List<CategoryGroup>> call() {
    return _repository.watchGroups();
  }
}
