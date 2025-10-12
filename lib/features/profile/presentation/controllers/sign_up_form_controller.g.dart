// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_up_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SignUpFormController)
const signUpFormControllerProvider = SignUpFormControllerProvider._();

final class SignUpFormControllerProvider
    extends $NotifierProvider<SignUpFormController, SignUpFormState> {
  const SignUpFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signUpFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signUpFormControllerHash();

  @$internal
  @override
  SignUpFormController create() => SignUpFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignUpFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignUpFormState>(value),
    );
  }
}

String _$signUpFormControllerHash() =>
    r'375c296821f7608529c02e28c899932e839e3b24';

abstract class _$SignUpFormController extends $Notifier<SignUpFormState> {
  SignUpFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SignUpFormState, SignUpFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SignUpFormState, SignUpFormState>,
              SignUpFormState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
