// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProfileFormController)
const profileFormControllerProvider = ProfileFormControllerFamily._();

final class ProfileFormControllerProvider
    extends $NotifierProvider<ProfileFormController, ProfileFormState> {
  const ProfileFormControllerProvider._({
    required ProfileFormControllerFamily super.from,
    required ProfileFormParams super.argument,
  }) : super(
         retry: null,
         name: r'profileFormControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileFormControllerHash();

  @override
  String toString() {
    return r'profileFormControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProfileFormController create() => ProfileFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileFormControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileFormControllerHash() =>
    r'e7e127b71af2e63875190af1065bbd34241acf69';

final class ProfileFormControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ProfileFormController,
          ProfileFormState,
          ProfileFormState,
          ProfileFormState,
          ProfileFormParams
        > {
  const ProfileFormControllerFamily._()
    : super(
        retry: null,
        name: r'profileFormControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProfileFormControllerProvider call(ProfileFormParams params) =>
      ProfileFormControllerProvider._(argument: params, from: this);

  @override
  String toString() => r'profileFormControllerProvider';
}

abstract class _$ProfileFormController extends $Notifier<ProfileFormState> {
  late final _$args = ref.$arg as ProfileFormParams;
  ProfileFormParams get params => _$args;

  ProfileFormState build(ProfileFormParams params);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<ProfileFormState, ProfileFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProfileFormState, ProfileFormState>,
              ProfileFormState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
