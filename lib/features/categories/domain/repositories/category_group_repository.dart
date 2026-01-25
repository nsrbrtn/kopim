import 'package:kopim/features/categories/domain/entities/category_group.dart';
import 'package:kopim/features/categories/domain/entities/category_group_link.dart';

abstract class CategoryGroupRepository {
  Stream<List<CategoryGroup>> watchGroups();
  Future<List<CategoryGroup>> loadGroups();
  Future<CategoryGroup?> findById(String id);
  Future<CategoryGroup?> findByName(String name);
  Future<void> upsertGroup(CategoryGroup group);
  Future<void> softDeleteGroup(String id);
  Future<void> updateGroupOrders(List<String> orderedIds);

  Stream<List<CategoryGroupLink>> watchLinks();
  Future<List<CategoryGroupLink>> loadLinks();
  Future<List<CategoryGroupLink>> loadLinksForGroup(String groupId);
  Future<void> upsertLink(CategoryGroupLink link);
  Future<void> upsertLinks(List<CategoryGroupLink> links);
  Future<void> markLinkDeleted({
    required String groupId,
    required String categoryId,
    required DateTime updatedAt,
  });
}
