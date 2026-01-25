import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/categories/domain/entities/category_group.dart';
import 'package:kopim/features/categories/domain/entities/category_group_link.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_groups_controller.g.dart';

@riverpod
Stream<List<CategoryGroup>> categoryGroups(Ref ref) {
  return ref.watch(watchCategoryGroupsUseCaseProvider).call();
}

@riverpod
Stream<List<CategoryGroupLink>> categoryGroupLinks(Ref ref) {
  return ref.watch(watchCategoryGroupLinksUseCaseProvider).call();
}
