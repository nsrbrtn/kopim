import 'package:kopim/features/tags/domain/entities/tag.dart';

abstract class TagRepository {
  Stream<List<TagEntity>> watchTags({bool includeArchived = false});
  Future<List<TagEntity>> loadTags({bool includeArchived = false});
  Future<TagEntity?> findById(String id);
  Future<TagEntity?> findByName(String name);
  Future<void> upsert(TagEntity tag);
  Future<void> softDelete(String id);
}
