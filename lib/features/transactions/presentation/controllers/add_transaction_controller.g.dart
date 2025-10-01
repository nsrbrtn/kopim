// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_transaction_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddTransactionController)
const addTransactionControllerProvider = AddTransactionControllerProvider._();

final class AddTransactionControllerProvider
    extends $NotifierProvider<AddTransactionController, AddTransactionState> {
  const AddTransactionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addTransactionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addTransactionControllerHash();

  @$internal
  @override
  AddTransactionController create() => AddTransactionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddTransactionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddTransactionState>(value),
    );
  }
}

String _$addTransactionControllerHash() =>
    r'dda03eacdaac9361f003785d721beeeec7ed9dec';

abstract class _$AddTransactionController
    extends $Notifier<AddTransactionState> {
  AddTransactionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AddTransactionState, AddTransactionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddTransactionState, AddTransactionState>,
              AddTransactionState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
