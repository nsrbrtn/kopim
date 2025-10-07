// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_transactions_filter_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HomeTransactionsFilterController)
const homeTransactionsFilterControllerProvider =
    HomeTransactionsFilterControllerProvider._();

final class HomeTransactionsFilterControllerProvider
    extends
        $NotifierProvider<
          HomeTransactionsFilterController,
          HomeTransactionsFilter
        > {
  const HomeTransactionsFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeTransactionsFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeTransactionsFilterControllerHash();

  @$internal
  @override
  HomeTransactionsFilterController create() =>
      HomeTransactionsFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeTransactionsFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeTransactionsFilter>(value),
    );
  }
}

String _$homeTransactionsFilterControllerHash() =>
    r'5a674dba38409b7a953d542f44cc160791609d5b';

abstract class _$HomeTransactionsFilterController
    extends $Notifier<HomeTransactionsFilter> {
  HomeTransactionsFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<HomeTransactionsFilter, HomeTransactionsFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HomeTransactionsFilter, HomeTransactionsFilter>,
              HomeTransactionsFilter,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
