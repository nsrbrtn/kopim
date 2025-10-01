// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(manageCategoriesList)
const manageCategoriesListProvider = ManageCategoriesListProvider._();

final class ManageCategoriesListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Category>>,
          List<Category>,
          Stream<List<Category>>
        >
    with $FutureModifier<List<Category>>, $StreamProvider<List<Category>> {
  const ManageCategoriesListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'manageCategoriesListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$manageCategoriesListHash();

  @$internal
  @override
  $StreamProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Category>> create(Ref ref) {
    return manageCategoriesList(ref);
  }
}

String _$manageCategoriesListHash() =>
    r'a8d09e950f682295edbf58b982947ba0726b16c3';
