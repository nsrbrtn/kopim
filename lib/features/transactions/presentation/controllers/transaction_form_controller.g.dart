// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TransactionFormController)
const transactionFormControllerProvider = TransactionFormControllerFamily._();

final class TransactionFormControllerProvider
    extends $NotifierProvider<TransactionFormController, TransactionFormState> {
  const TransactionFormControllerProvider._({
    required TransactionFormControllerFamily super.from,
    required TransactionFormArgs super.argument,
  }) : super(
         retry: null,
         name: r'transactionFormControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionFormControllerHash();

  @override
  String toString() {
    return r'transactionFormControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TransactionFormController create() => TransactionFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionFormControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionFormControllerHash() =>
    r'77a6390304d52482155f1f520bfb841db45650b3';

final class TransactionFormControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          TransactionFormController,
          TransactionFormState,
          TransactionFormState,
          TransactionFormState,
          TransactionFormArgs
        > {
  const TransactionFormControllerFamily._()
    : super(
        retry: null,
        name: r'transactionFormControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TransactionFormControllerProvider call(TransactionFormArgs args) =>
      TransactionFormControllerProvider._(argument: args, from: this);

  @override
  String toString() => r'transactionFormControllerProvider';
}

abstract class _$TransactionFormController
    extends $Notifier<TransactionFormState> {
  late final _$args = ref.$arg as TransactionFormArgs;
  TransactionFormArgs get args => _$args;

  TransactionFormState build(TransactionFormArgs args);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<TransactionFormState, TransactionFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TransactionFormState, TransactionFormState>,
              TransactionFormState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
