// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_actions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TransactionActionsController)
const transactionActionsControllerProvider =
    TransactionActionsControllerProvider._();

final class TransactionActionsControllerProvider
    extends $NotifierProvider<TransactionActionsController, AsyncValue<void>> {
  const TransactionActionsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionActionsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionActionsControllerHash();

  @$internal
  @override
  TransactionActionsController create() => TransactionActionsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$transactionActionsControllerHash() =>
    r'5a669804b0a7c14a0157665ee4f1315f97c7690a';

abstract class _$TransactionActionsController
    extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
