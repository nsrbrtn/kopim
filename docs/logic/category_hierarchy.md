# CategoryHierarchy

## Назначение
`CategoryHierarchy` строит и кеширует дерево категорий в памяти, чтобы быстро получать:
- корневые категории;
- прямых потомков;
- полный список потомков любой глубины.

## Параметры
- `Iterable<Category> categories` — список активных категорий (без `isDeleted`).

## Пример использования
```dart
final CategoryHierarchy hierarchy = CategoryHierarchy(categories);
final Set<String> descendants = hierarchy.descendantsOf(parentId);
final List<String> children = hierarchy.childrenOf(parentId);
```

## Ссылки на код
- `lib/features/categories/domain/services/category_hierarchy.dart`
