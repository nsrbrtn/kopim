// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_account_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EditAccountFormController)
const editAccountFormControllerProvider = EditAccountFormControllerFamily._();

final class EditAccountFormControllerProvider
    extends $NotifierProvider<EditAccountFormController, EditAccountFormState> {
  const EditAccountFormControllerProvider._({
    required EditAccountFormControllerFamily super.from,
    required AccountEntity super.argument,
  }) : super(
         retry: null,
         name: r'editAccountFormControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$editAccountFormControllerHash();

  @override
  String toString() {
    return r'editAccountFormControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EditAccountFormController create() => EditAccountFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EditAccountFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EditAccountFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EditAccountFormControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editAccountFormControllerHash() =>
    r'46bf9b112fc6ca3d5cb2783cc9231879b69ddc37';

final class EditAccountFormControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          EditAccountFormController,
          EditAccountFormState,
          EditAccountFormState,
          EditAccountFormState,
          AccountEntity
        > {
  const EditAccountFormControllerFamily._()
    : super(
        retry: null,
        name: r'editAccountFormControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EditAccountFormControllerProvider call(AccountEntity account) =>
      EditAccountFormControllerProvider._(argument: account, from: this);

  @override
  String toString() => r'editAccountFormControllerProvider';
}

abstract class _$EditAccountFormController
    extends $Notifier<EditAccountFormState> {
  late final _$args = ref.$arg as AccountEntity;
  AccountEntity get account => _$args;

  EditAccountFormState build(AccountEntity account);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<EditAccountFormState, EditAccountFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EditAccountFormState, EditAccountFormState>,
              EditAccountFormState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
