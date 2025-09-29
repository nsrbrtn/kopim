// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProfileController)
const profileControllerProvider = ProfileControllerFamily._();

final class ProfileControllerProvider
    extends $AsyncNotifierProvider<ProfileController, Profile?> {
  const ProfileControllerProvider._({
    required ProfileControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'profileControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileControllerHash();

  @override
  String toString() {
    return r'profileControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProfileController create() => ProfileController();

  @override
  bool operator ==(Object other) {
    return other is ProfileControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileControllerHash() => r'87d3f64bf3f9ceeb3f536367722a2b4a2e57f00d';

final class ProfileControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ProfileController,
          AsyncValue<Profile?>,
          Profile?,
          FutureOr<Profile?>,
          String
        > {
  const ProfileControllerFamily._()
    : super(
        retry: null,
        name: r'profileControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProfileControllerProvider call(String uid) =>
      ProfileControllerProvider._(argument: uid, from: this);

  @override
  String toString() => r'profileControllerProvider';
}

abstract class _$ProfileController extends $AsyncNotifier<Profile?> {
  late final _$args = ref.$arg as String;
  String get uid => _$args;

  FutureOr<Profile?> build(String uid);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<Profile?>, Profile?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Profile?>, Profile?>,
              AsyncValue<Profile?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
