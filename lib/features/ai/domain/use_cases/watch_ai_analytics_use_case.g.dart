// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_ai_analytics_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Провайдер use-case для внедрения зависимостей через Riverpod.

@ProviderFor(watchAiAnalyticsUseCase)
const watchAiAnalyticsUseCaseProvider = WatchAiAnalyticsUseCaseProvider._();

/// Провайдер use-case для внедрения зависимостей через Riverpod.

final class WatchAiAnalyticsUseCaseProvider
    extends
        $FunctionalProvider<
          WatchAiAnalyticsUseCase,
          WatchAiAnalyticsUseCase,
          WatchAiAnalyticsUseCase
        >
    with $Provider<WatchAiAnalyticsUseCase> {
  /// Провайдер use-case для внедрения зависимостей через Riverpod.
  const WatchAiAnalyticsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchAiAnalyticsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchAiAnalyticsUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchAiAnalyticsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchAiAnalyticsUseCase create(Ref ref) {
    return watchAiAnalyticsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchAiAnalyticsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchAiAnalyticsUseCase>(value),
    );
  }
}

String _$watchAiAnalyticsUseCaseHash() =>
    r'aaa925ef829a91e3a3041cbb86b63a5ede9d3a70';
