import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/repositories/tag_repository.dart';

class SaveTagUseCase {
  SaveTagUseCase(this._repository);

  final TagRepository _repository;

  Future<void> call(TagEntity tag) async {
    final String trimmedName = tag.name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Tag name cannot be empty');
    }
    final String normalizedColor = tag.color.trim();
    if (normalizedColor.isEmpty) {
      throw ArgumentError('Tag color cannot be empty');
    }
    await _repository.upsert(
      tag.copyWith(name: trimmedName, color: normalizedColor),
    );
  }
}
