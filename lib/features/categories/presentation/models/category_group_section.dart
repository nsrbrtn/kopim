import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/entities/category_group.dart';

class CategoryGroupSection {
  const CategoryGroupSection({
    required this.id,
    required this.title,
    required this.categories,
    required this.isFavorites,
    required this.isOther,
    this.group,
  });

  final String id;
  final String title;
  final List<Category> categories;
  final bool isFavorites;
  final bool isOther;
  final CategoryGroup? group;
}
