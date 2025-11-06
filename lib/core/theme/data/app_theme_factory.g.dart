// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_theme_factory.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appThemeFactory)
const appThemeFactoryProvider = AppThemeFactoryProvider._();

final class AppThemeFactoryProvider
    extends
        $FunctionalProvider<AppThemeFactory, AppThemeFactory, AppThemeFactory>
    with $Provider<AppThemeFactory> {
  const AppThemeFactoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appThemeFactoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appThemeFactoryHash();

  @$internal
  @override
  $ProviderElement<AppThemeFactory> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppThemeFactory create(Ref ref) {
    return appThemeFactory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppThemeFactory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppThemeFactory>(value),
    );
  }
}

String _$appThemeFactoryHash() => r'87ca06ef0e9463caf8fdefb430c17a7982e371cc';

@ProviderFor(appThemeTokens)
const appThemeTokensProvider = AppThemeTokensProvider._();

final class AppThemeTokensProvider
    extends
        $FunctionalProvider<
          AsyncValue<KopimThemeTokenBundle>,
          KopimThemeTokenBundle,
          FutureOr<KopimThemeTokenBundle>
        >
    with
        $FutureModifier<KopimThemeTokenBundle>,
        $FutureProvider<KopimThemeTokenBundle> {
  const AppThemeTokensProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appThemeTokensProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appThemeTokensHash();

  @$internal
  @override
  $FutureProviderElement<KopimThemeTokenBundle> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<KopimThemeTokenBundle> create(Ref ref) {
    return appThemeTokens(ref);
  }
}

String _$appThemeTokensHash() => r'91ab08012a89768f10f155078019419d7d5297bd';
