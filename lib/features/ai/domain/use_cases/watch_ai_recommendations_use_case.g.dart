// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_ai_recommendations_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod-провайдер use-case с внедрением репозитория.

@ProviderFor(watchAiRecommendationsUseCase)
const watchAiRecommendationsUseCaseProvider =
    WatchAiRecommendationsUseCaseProvider._();

/// Riverpod-провайдер use-case с внедрением репозитория.

final class WatchAiRecommendationsUseCaseProvider
    extends
        $FunctionalProvider<
          WatchAiRecommendationsUseCase,
          WatchAiRecommendationsUseCase,
          WatchAiRecommendationsUseCase
        >
    with $Provider<WatchAiRecommendationsUseCase> {
  /// Riverpod-провайдер use-case с внедрением репозитория.
  const WatchAiRecommendationsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchAiRecommendationsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchAiRecommendationsUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchAiRecommendationsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchAiRecommendationsUseCase create(Ref ref) {
    return watchAiRecommendationsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchAiRecommendationsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchAiRecommendationsUseCase>(
        value,
      ),
    );
  }
}

String _$watchAiRecommendationsUseCaseHash() =>
    r'3d3672658a9de1192374ffeef071fda0ad5592d8';
