// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AvatarController)
const avatarControllerProvider = AvatarControllerProvider._();

final class AvatarControllerProvider
    extends $NotifierProvider<AvatarController, AsyncValue<void>> {
  const AvatarControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'avatarControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$avatarControllerHash();

  @$internal
  @override
  AvatarController create() => AvatarController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$avatarControllerHash() => r'386d1c8b646b1bbf6fe934ee73beb8d2bce9598e';

abstract class _$AvatarController extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
