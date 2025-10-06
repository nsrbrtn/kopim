// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_account_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddAccountFormController)
const addAccountFormControllerProvider = AddAccountFormControllerProvider._();

final class AddAccountFormControllerProvider
    extends $NotifierProvider<AddAccountFormController, AddAccountFormState> {
  const AddAccountFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addAccountFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addAccountFormControllerHash();

  @$internal
  @override
  AddAccountFormController create() => AddAccountFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddAccountFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddAccountFormState>(value),
    );
  }
}

String _$addAccountFormControllerHash() =>
    r'9d118da8b06291d4266231824ccefc868d47598d';

abstract class _$AddAccountFormController
    extends $Notifier<AddAccountFormState> {
  AddAccountFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AddAccountFormState, AddAccountFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddAccountFormState, AddAccountFormState>,
              AddAccountFormState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
