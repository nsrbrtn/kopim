// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_groups_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(categoryGroups)
const categoryGroupsProvider = CategoryGroupsProvider._();

final class CategoryGroupsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CategoryGroup>>,
          List<CategoryGroup>,
          Stream<List<CategoryGroup>>
        >
    with
        $FutureModifier<List<CategoryGroup>>,
        $StreamProvider<List<CategoryGroup>> {
  const CategoryGroupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryGroupsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryGroupsHash();

  @$internal
  @override
  $StreamProviderElement<List<CategoryGroup>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CategoryGroup>> create(Ref ref) {
    return categoryGroups(ref);
  }
}

String _$categoryGroupsHash() => r'f4eeffd49a80b8928f6c5a3d58c562e4d0be2ea8';

@ProviderFor(categoryGroupLinks)
const categoryGroupLinksProvider = CategoryGroupLinksProvider._();

final class CategoryGroupLinksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CategoryGroupLink>>,
          List<CategoryGroupLink>,
          Stream<List<CategoryGroupLink>>
        >
    with
        $FutureModifier<List<CategoryGroupLink>>,
        $StreamProvider<List<CategoryGroupLink>> {
  const CategoryGroupLinksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryGroupLinksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryGroupLinksHash();

  @$internal
  @override
  $StreamProviderElement<List<CategoryGroupLink>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CategoryGroupLink>> create(Ref ref) {
    return categoryGroupLinks(ref);
  }
}

String _$categoryGroupLinksHash() =>
    r'108164c96e019aa65912b9d2034792837439a7a1';
