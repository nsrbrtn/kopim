import 'package:kopim/features/categories/domain/entities/category.dart';

abstract class CategoryRepository {
  Stream<List<Category>> watchCategories();
  Future<List<Category>> loadCategories();
  Future<Category?> findById(String id);
  Future<void> upsert(Category category);
  Future<void> softDelete(String id);
}
