// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(manageCategoryTree)
const manageCategoryTreeProvider = ManageCategoryTreeProvider._();

final class ManageCategoryTreeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CategoryTreeNode>>,
          List<CategoryTreeNode>,
          Stream<List<CategoryTreeNode>>
        >
    with
        $FutureModifier<List<CategoryTreeNode>>,
        $StreamProvider<List<CategoryTreeNode>> {
  const ManageCategoryTreeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'manageCategoryTreeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$manageCategoryTreeHash();

  @$internal
  @override
  $StreamProviderElement<List<CategoryTreeNode>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CategoryTreeNode>> create(Ref ref) {
    return manageCategoryTree(ref);
  }
}

String _$manageCategoryTreeHash() =>
    r'46303fbc95f7c7eb71bf645f96ef4596dc1a5eeb';

@ProviderFor(manageCategories)
const manageCategoriesProvider = ManageCategoriesProvider._();

final class ManageCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Category>>,
          List<Category>,
          Stream<List<Category>>
        >
    with $FutureModifier<List<Category>>, $StreamProvider<List<Category>> {
  const ManageCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'manageCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$manageCategoriesHash();

  @$internal
  @override
  $StreamProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Category>> create(Ref ref) {
    return manageCategories(ref);
  }
}

String _$manageCategoriesHash() => r'b9ebf4468cd0532629690b19646431feddbd3d1d';
