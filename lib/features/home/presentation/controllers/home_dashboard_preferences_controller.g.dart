// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_dashboard_preferences_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HomeDashboardPreferencesController)
const homeDashboardPreferencesControllerProvider =
    HomeDashboardPreferencesControllerProvider._();

final class HomeDashboardPreferencesControllerProvider
    extends
        $AsyncNotifierProvider<
          HomeDashboardPreferencesController,
          HomeDashboardPreferences
        > {
  const HomeDashboardPreferencesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeDashboardPreferencesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$homeDashboardPreferencesControllerHash();

  @$internal
  @override
  HomeDashboardPreferencesController create() =>
      HomeDashboardPreferencesController();
}

String _$homeDashboardPreferencesControllerHash() =>
    r'f76223c85b53a96770755a943d73913f414686f4';

abstract class _$HomeDashboardPreferencesController
    extends $AsyncNotifier<HomeDashboardPreferences> {
  FutureOr<HomeDashboardPreferences> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<HomeDashboardPreferences>,
              HomeDashboardPreferences
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<HomeDashboardPreferences>,
                HomeDashboardPreferences
              >,
              AsyncValue<HomeDashboardPreferences>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
