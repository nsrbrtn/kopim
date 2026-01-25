import 'package:kopim/features/categories/domain/entities/category_group_link.dart';
import 'package:kopim/features/categories/domain/repositories/category_group_repository.dart';

class SetCategoryGroupCategoriesUseCase {
  SetCategoryGroupCategoriesUseCase(this._repository);

  final CategoryGroupRepository _repository;

  Future<void> call({
    required String groupId,
    required Set<String> categoryIds,
  }) async {
    final DateTime now = DateTime.now();
    final List<CategoryGroupLink> existing = await _repository
        .loadLinksForGroup(groupId);
    final Map<String, CategoryGroupLink> byCategory =
        <String, CategoryGroupLink>{
          for (final CategoryGroupLink link in existing) link.categoryId: link,
        };

    final List<CategoryGroupLink> toUpsert = <CategoryGroupLink>[];
    for (final String categoryId in categoryIds) {
      final CategoryGroupLink? link = byCategory[categoryId];
      if (link == null) {
        toUpsert.add(
          CategoryGroupLink(
            groupId: groupId,
            categoryId: categoryId,
            createdAt: now,
            updatedAt: now,
          ),
        );
        continue;
      }
      if (link.isDeleted) {
        toUpsert.add(link.copyWith(isDeleted: false, updatedAt: now));
      }
    }

    if (toUpsert.isNotEmpty) {
      await _repository.upsertLinks(toUpsert);
    }

    for (final CategoryGroupLink link in existing) {
      if (link.isDeleted) {
        continue;
      }
      if (!categoryIds.contains(link.categoryId)) {
        await _repository.markLinkDeleted(
          groupId: link.groupId,
          categoryId: link.categoryId,
          updatedAt: now,
        );
      }
    }
  }
}
