// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CategoryFormController)
const categoryFormControllerProvider = CategoryFormControllerFamily._();

final class CategoryFormControllerProvider
    extends $NotifierProvider<CategoryFormController, CategoryFormState> {
  const CategoryFormControllerProvider._({
    required CategoryFormControllerFamily super.from,
    required CategoryFormParams super.argument,
  }) : super(
         retry: null,
         name: r'categoryFormControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryFormControllerHash();

  @override
  String toString() {
    return r'categoryFormControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CategoryFormController create() => CategoryFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryFormControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryFormControllerHash() =>
    r'45a9550b029731b8770e5c8426540c7295ebc289';

final class CategoryFormControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CategoryFormController,
          CategoryFormState,
          CategoryFormState,
          CategoryFormState,
          CategoryFormParams
        > {
  const CategoryFormControllerFamily._()
    : super(
        retry: null,
        name: r'categoryFormControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoryFormControllerProvider call(CategoryFormParams params) =>
      CategoryFormControllerProvider._(argument: params, from: this);

  @override
  String toString() => r'categoryFormControllerProvider';
}

abstract class _$CategoryFormController extends $Notifier<CategoryFormState> {
  late final _$args = ref.$arg as CategoryFormParams;
  CategoryFormParams get params => _$args;

  CategoryFormState build(CategoryFormParams params);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<CategoryFormState, CategoryFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CategoryFormState, CategoryFormState>,
              CategoryFormState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
