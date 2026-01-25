import 'package:kopim/features/categories/domain/entities/category_group_link.dart';
import 'package:kopim/features/categories/domain/repositories/category_group_repository.dart';

class WatchCategoryGroupLinksUseCase {
  WatchCategoryGroupLinksUseCase(this._repository);

  final CategoryGroupRepository _repository;

  Stream<List<CategoryGroupLink>> call() {
    return _repository.watchLinks();
  }
}
