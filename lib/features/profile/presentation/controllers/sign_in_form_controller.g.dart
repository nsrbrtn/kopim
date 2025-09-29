// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_in_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SignInFormController)
const signInFormControllerProvider = SignInFormControllerProvider._();

final class SignInFormControllerProvider
    extends $NotifierProvider<SignInFormController, SignInFormState> {
  const SignInFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInFormControllerHash();

  @$internal
  @override
  SignInFormController create() => SignInFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignInFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignInFormState>(value),
    );
  }
}

String _$signInFormControllerHash() =>
    r'19cc02ea6a001ae21a579bd224d2db1860f868d8';

abstract class _$SignInFormController extends $Notifier<SignInFormState> {
  SignInFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SignInFormState, SignInFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SignInFormState, SignInFormState>,
              SignInFormState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
