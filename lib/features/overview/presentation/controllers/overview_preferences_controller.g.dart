// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overview_preferences_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OverviewPreferencesController)
const overviewPreferencesControllerProvider =
    OverviewPreferencesControllerProvider._();

final class OverviewPreferencesControllerProvider
    extends
        $AsyncNotifierProvider<
          OverviewPreferencesController,
          OverviewPreferences
        > {
  const OverviewPreferencesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'overviewPreferencesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$overviewPreferencesControllerHash();

  @$internal
  @override
  OverviewPreferencesController create() => OverviewPreferencesController();
}

String _$overviewPreferencesControllerHash() =>
    r'bad1f64864aa8efcc588472dcef0eb4357c00ec2';

abstract class _$OverviewPreferencesController
    extends $AsyncNotifier<OverviewPreferences> {
  FutureOr<OverviewPreferences> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<OverviewPreferences>, OverviewPreferences>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<OverviewPreferences>, OverviewPreferences>,
              AsyncValue<OverviewPreferences>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
