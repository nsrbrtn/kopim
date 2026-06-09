// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_transactions_filter_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AllTransactionsFilterController)
final allTransactionsFilterControllerProvider =
    AllTransactionsFilterControllerProvider._();

final class AllTransactionsFilterControllerProvider
    extends
        $NotifierProvider<
          AllTransactionsFilterController,
          AllTransactionsFilterState
        > {
  AllTransactionsFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allTransactionsFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allTransactionsFilterControllerHash();

  @$internal
  @override
  AllTransactionsFilterController create() => AllTransactionsFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AllTransactionsFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AllTransactionsFilterState>(value),
    );
  }
}

String _$allTransactionsFilterControllerHash() =>
    r'a2a6177ec02730ec5fc99b98ab2d4a82f2b969ba';

abstract class _$AllTransactionsFilterController
    extends $Notifier<AllTransactionsFilterState> {
  AllTransactionsFilterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AllTransactionsFilterState, AllTransactionsFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AllTransactionsFilterState,
                AllTransactionsFilterState
              >,
              AllTransactionsFilterState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
