import 'package:kopim/features/categories/domain/entities/category.dart';

class CategoryHierarchy {
  CategoryHierarchy(Iterable<Category> categories)
    : byId = <String, Category>{
        for (final Category category in categories) category.id: category,
      },
      childrenByParent = <String, List<String>>{} {
    for (final Category category in categories) {
      final String? parentId = category.parentId;
      if (parentId == null || parentId.isEmpty) {
        continue;
      }
      childrenByParent.putIfAbsent(parentId, () => <String>[]).add(category.id);
    }
    _rootIds = _resolveRootIds(categories);
    _descendantsById = _buildDescendantsCache();
  }

  final Map<String, Category> byId;
  final Map<String, List<String>> childrenByParent;
  late final List<String> _rootIds;
  late final Map<String, Set<String>> _descendantsById;

  List<String> get rootIds => _rootIds;

  bool contains(String id) => byId.containsKey(id);

  List<String> childrenOf(String id) =>
      childrenByParent[id] ?? const <String>[];

  Set<String> descendantsOf(String id) =>
      _descendantsById[id] ?? const <String>{};

  List<String> _resolveRootIds(Iterable<Category> categories) {
    final List<String> roots = <String>[];
    for (final Category category in categories) {
      final String? parentId = category.parentId;
      if (parentId == null || parentId.isEmpty || !byId.containsKey(parentId)) {
        roots.add(category.id);
      }
    }
    return roots;
  }

  Map<String, Set<String>> _buildDescendantsCache() {
    final Map<String, Set<String>> cache = <String, Set<String>>{};
    final Set<String> visiting = <String>{};

    Set<String> resolve(String id) {
      final Set<String>? cached = cache[id];
      if (cached != null) {
        return cached;
      }
      if (!visiting.add(id)) {
        return const <String>{};
      }
      final Set<String> result = <String>{};
      for (final String childId in childrenOf(id)) {
        result.add(childId);
        result.addAll(resolve(childId));
      }
      visiting.remove(id);
      cache[id] = result;
      return result;
    }

    for (final String id in byId.keys) {
      resolve(id);
    }
    return cache;
  }
}
