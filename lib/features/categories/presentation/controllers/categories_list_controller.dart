import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'categories_list_controller.g.dart';

@riverpod
Stream<List<Category>> manageCategoriesList(Ref ref) {
  return ref.watch(watchCategoriesUseCaseProvider).call();
}
