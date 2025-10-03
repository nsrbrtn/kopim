// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_startup_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppStartupController)
const appStartupControllerProvider = AppStartupControllerProvider._();

final class AppStartupControllerProvider
    extends $NotifierProvider<AppStartupController, AppStartupResult> {
  const AppStartupControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appStartupControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appStartupControllerHash();

  @$internal
  @override
  AppStartupController create() => AppStartupController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppStartupResult value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppStartupResult>(value),
    );
  }
}

String _$appStartupControllerHash() =>
    r'20f69e67ea97a3418f3b1bd6ef50e2b96d611891';

abstract class _$AppStartupController extends $Notifier<AppStartupResult> {
  AppStartupResult build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AppStartupResult, AppStartupResult>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppStartupResult, AppStartupResult>,
              AppStartupResult,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
