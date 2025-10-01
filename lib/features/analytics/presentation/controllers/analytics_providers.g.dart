// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(analyticsOverview)
const analyticsOverviewProvider = AnalyticsOverviewFamily._();

final class AnalyticsOverviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<AnalyticsOverview>,
          AnalyticsOverview,
          Stream<AnalyticsOverview>
        >
    with
        $FutureModifier<AnalyticsOverview>,
        $StreamProvider<AnalyticsOverview> {
  const AnalyticsOverviewProvider._({
    required AnalyticsOverviewFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'analyticsOverviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$analyticsOverviewHash();

  @override
  String toString() {
    return r'analyticsOverviewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<AnalyticsOverview> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AnalyticsOverview> create(Ref ref) {
    final argument = this.argument as int;
    return analyticsOverview(ref, topCategoriesLimit: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AnalyticsOverviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$analyticsOverviewHash() => r'f445da9ec62abe6be2b31a26a7cb5814454f40d6';

final class AnalyticsOverviewFamily extends $Family
    with $FunctionalFamilyOverride<Stream<AnalyticsOverview>, int> {
  const AnalyticsOverviewFamily._()
    : super(
        retry: null,
        name: r'analyticsOverviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AnalyticsOverviewProvider call({int topCategoriesLimit = 5}) =>
      AnalyticsOverviewProvider._(argument: topCategoriesLimit, from: this);

  @override
  String toString() => r'analyticsOverviewProvider';
}

@ProviderFor(analyticsCategories)
const analyticsCategoriesProvider = AnalyticsCategoriesProvider._();

final class AnalyticsCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Category>>,
          List<Category>,
          Stream<List<Category>>
        >
    with $FutureModifier<List<Category>>, $StreamProvider<List<Category>> {
  const AnalyticsCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsCategoriesHash();

  @$internal
  @override
  $StreamProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Category>> create(Ref ref) {
    return analyticsCategories(ref);
  }
}

String _$analyticsCategoriesHash() =>
    r'a0481679265a41e2ab35b1ae879ce50cf957fce3';
