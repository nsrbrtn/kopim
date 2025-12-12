// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(analyticsFilters)
const analyticsFiltersProvider = AnalyticsFiltersProvider._();

final class AnalyticsFiltersProvider
    extends
        $FunctionalProvider<AnalyticsFilter, AnalyticsFilter, AnalyticsFilter>
    with $Provider<AnalyticsFilter> {
  const AnalyticsFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsFiltersHash();

  @$internal
  @override
  $ProviderElement<AnalyticsFilter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnalyticsFilter create(Ref ref) {
    return analyticsFilters(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsFilter>(value),
    );
  }
}

String _$analyticsFiltersHash() => r'1b1542c9cc14ed5ec7b0e02f9b4f57636fa2166b';

@ProviderFor(analyticsFilteredStats)
const analyticsFilteredStatsProvider = AnalyticsFilteredStatsFamily._();

final class AnalyticsFilteredStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AnalyticsOverview>,
          AnalyticsOverview,
          Stream<AnalyticsOverview>
        >
    with
        $FutureModifier<AnalyticsOverview>,
        $StreamProvider<AnalyticsOverview> {
  const AnalyticsFilteredStatsProvider._({
    required AnalyticsFilteredStatsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'analyticsFilteredStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$analyticsFilteredStatsHash();

  @override
  String toString() {
    return r'analyticsFilteredStatsProvider'
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
    return analyticsFilteredStats(ref, topCategoriesLimit: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AnalyticsFilteredStatsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$analyticsFilteredStatsHash() =>
    r'db4114088c1539b41668d451b916797b72376d61';

final class AnalyticsFilteredStatsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<AnalyticsOverview>, int> {
  const AnalyticsFilteredStatsFamily._()
    : super(
        retry: null,
        name: r'analyticsFilteredStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AnalyticsFilteredStatsProvider call({int topCategoriesLimit = 5}) =>
      AnalyticsFilteredStatsProvider._(
        argument: topCategoriesLimit,
        from: this,
      );

  @override
  String toString() => r'analyticsFilteredStatsProvider';
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

@ProviderFor(analyticsAccounts)
const analyticsAccountsProvider = AnalyticsAccountsProvider._();

final class AnalyticsAccountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AccountEntity>>,
          List<AccountEntity>,
          Stream<List<AccountEntity>>
        >
    with
        $FutureModifier<List<AccountEntity>>,
        $StreamProvider<List<AccountEntity>> {
  const AnalyticsAccountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsAccountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsAccountsHash();

  @$internal
  @override
  $StreamProviderElement<List<AccountEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AccountEntity>> create(Ref ref) {
    return analyticsAccounts(ref);
  }
}

String _$analyticsAccountsHash() => r'd78d4d75ea71704dc5d8fd42a64919cb59824340';

@ProviderFor(monthlyBalanceData)
const monthlyBalanceDataProvider = MonthlyBalanceDataProvider._();

final class MonthlyBalanceDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MonthlyBalanceData>>,
          List<MonthlyBalanceData>,
          Stream<List<MonthlyBalanceData>>
        >
    with
        $FutureModifier<List<MonthlyBalanceData>>,
        $StreamProvider<List<MonthlyBalanceData>> {
  const MonthlyBalanceDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthlyBalanceDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthlyBalanceDataHash();

  @$internal
  @override
  $StreamProviderElement<List<MonthlyBalanceData>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MonthlyBalanceData>> create(Ref ref) {
    return monthlyBalanceData(ref);
  }
}

String _$monthlyBalanceDataHash() =>
    r'6e4f7d60fbf0c19c80e95b6727e90bd03b8dd474';
