// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_event_recorder.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profileEventRecorder)
const profileEventRecorderProvider = ProfileEventRecorderProvider._();

final class ProfileEventRecorderProvider
    extends
        $FunctionalProvider<
          ProfileEventRecorder,
          ProfileEventRecorder,
          ProfileEventRecorder
        >
    with $Provider<ProfileEventRecorder> {
  const ProfileEventRecorderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileEventRecorderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileEventRecorderHash();

  @$internal
  @override
  $ProviderElement<ProfileEventRecorder> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileEventRecorder create(Ref ref) {
    return profileEventRecorder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileEventRecorder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileEventRecorder>(value),
    );
  }
}

String _$profileEventRecorderHash() =>
    r'c28fb35688268fdc54ec5630c46ecc70422a7670';
