// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TagFormController)
const tagFormControllerProvider = TagFormControllerFamily._();

final class TagFormControllerProvider
    extends $NotifierProvider<TagFormController, TagFormState> {
  const TagFormControllerProvider._({
    required TagFormControllerFamily super.from,
    required TagFormParams super.argument,
  }) : super(
         retry: null,
         name: r'tagFormControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tagFormControllerHash();

  @override
  String toString() {
    return r'tagFormControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TagFormController create() => TagFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TagFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TagFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TagFormControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tagFormControllerHash() => r'879c08a2c0a0f39bdb89b0cc49e45afcdd69fc7a';

final class TagFormControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          TagFormController,
          TagFormState,
          TagFormState,
          TagFormState,
          TagFormParams
        > {
  const TagFormControllerFamily._()
    : super(
        retry: null,
        name: r'tagFormControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TagFormControllerProvider call(TagFormParams params) =>
      TagFormControllerProvider._(argument: params, from: this);

  @override
  String toString() => r'tagFormControllerProvider';
}

abstract class _$TagFormController extends $Notifier<TagFormState> {
  late final _$args = ref.$arg as TagFormParams;
  TagFormParams get params => _$args;

  TagFormState build(TagFormParams params);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<TagFormState, TagFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TagFormState, TagFormState>,
              TagFormState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
