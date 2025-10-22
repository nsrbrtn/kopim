// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_financial_data_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(aiAnalyticsDao)
const aiAnalyticsDaoProvider = AiAnalyticsDaoProvider._();

final class AiAnalyticsDaoProvider
    extends $FunctionalProvider<AiAnalyticsDao, AiAnalyticsDao, AiAnalyticsDao>
    with $Provider<AiAnalyticsDao> {
  const AiAnalyticsDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiAnalyticsDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiAnalyticsDaoHash();

  @$internal
  @override
  $ProviderElement<AiAnalyticsDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AiAnalyticsDao create(Ref ref) {
    return aiAnalyticsDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiAnalyticsDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiAnalyticsDao>(value),
    );
  }
}

String _$aiAnalyticsDaoHash() => r'76e0811404f4588734352984d8b5c3de180357ee';

@ProviderFor(aiFinancialDataRepository)
const aiFinancialDataRepositoryProvider = AiFinancialDataRepositoryProvider._();

final class AiFinancialDataRepositoryProvider
    extends
        $FunctionalProvider<
          AiFinancialDataRepository,
          AiFinancialDataRepository,
          AiFinancialDataRepository
        >
    with $Provider<AiFinancialDataRepository> {
  const AiFinancialDataRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiFinancialDataRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiFinancialDataRepositoryHash();

  @$internal
  @override
  $ProviderElement<AiFinancialDataRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AiFinancialDataRepository create(Ref ref) {
    return aiFinancialDataRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiFinancialDataRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiFinancialDataRepository>(value),
    );
  }
}

String _$aiFinancialDataRepositoryHash() =>
    r'6ef7a46ae1ca3222e856dc8c4512c638c2f543be';
