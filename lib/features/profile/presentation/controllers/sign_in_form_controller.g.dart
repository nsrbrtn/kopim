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
    r'3d4794d96129d7a5b35ce62dd8f1996818ca5bef';

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
