import 'package:kopim/features/tags/domain/repositories/tag_repository.dart';

class ArchiveTagUseCase {
  ArchiveTagUseCase(this._repository);

  final TagRepository _repository;

  Future<void> call(String id) => _repository.softDelete(id);
}
