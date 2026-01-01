// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_filter_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AnalyticsFilterController)
const analyticsFilterControllerProvider = AnalyticsFilterControllerProvider._();

final class AnalyticsFilterControllerProvider
    extends $NotifierProvider<AnalyticsFilterController, AnalyticsFilterState> {
  const AnalyticsFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsFilterControllerHash();

  @$internal
  @override
  AnalyticsFilterController create() => AnalyticsFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsFilterState>(value),
    );
  }
}

String _$analyticsFilterControllerHash() =>
    r'e645a06bedbc278b6f3fa4f1efcdb37fcd43a6c1';

abstract class _$AnalyticsFilterController
    extends $Notifier<AnalyticsFilterState> {
  AnalyticsFilterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AnalyticsFilterState, AnalyticsFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AnalyticsFilterState, AnalyticsFilterState>,
              AnalyticsFilterState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
