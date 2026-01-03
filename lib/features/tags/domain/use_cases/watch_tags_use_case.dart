import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/repositories/tag_repository.dart';

class WatchTagsUseCase {
  WatchTagsUseCase(this._repository);

  final TagRepository _repository;

  Stream<List<TagEntity>> call({bool includeArchived = false}) {
    return _repository.watchTags(includeArchived: includeArchived);
  }
}
