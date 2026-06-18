// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saving_goal_details_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(savingGoalById)
final savingGoalByIdProvider = SavingGoalByIdFamily._();

final class SavingGoalByIdProvider
    extends $FunctionalProvider<SavingGoal?, SavingGoal?, SavingGoal?>
    with $Provider<SavingGoal?> {
  SavingGoalByIdProvider._({
    required SavingGoalByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'savingGoalByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$savingGoalByIdHash();

  @override
  String toString() {
    return r'savingGoalByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<SavingGoal?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SavingGoal? create(Ref ref) {
    final argument = this.argument as String;
    return savingGoalById(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavingGoal? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavingGoal?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SavingGoalByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$savingGoalByIdHash() => r'fec465f46ffa66c0862b125b34f4c97eb4536c6f';

final class SavingGoalByIdFamily extends $Family
    with $FunctionalFamilyOverride<SavingGoal?, String> {
  SavingGoalByIdFamily._()
    : super(
        retry: null,
        name: r'savingGoalByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SavingGoalByIdProvider call(String goalId) =>
      SavingGoalByIdProvider._(argument: goalId, from: this);

  @override
  String toString() => r'savingGoalByIdProvider';
}

@ProviderFor(savingGoalAnalytics)
final savingGoalAnalyticsProvider = SavingGoalAnalyticsFamily._();

final class SavingGoalAnalyticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SavingGoalAnalytics>,
          SavingGoalAnalytics,
          Stream<SavingGoalAnalytics>
        >
    with
        $FutureModifier<SavingGoalAnalytics>,
        $StreamProvider<SavingGoalAnalytics> {
  SavingGoalAnalyticsProvider._({
    required SavingGoalAnalyticsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'savingGoalAnalyticsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$savingGoalAnalyticsHash();

  @override
  String toString() {
    return r'savingGoalAnalyticsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<SavingGoalAnalytics> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SavingGoalAnalytics> create(Ref ref) {
    final argument = this.argument as String;
    return savingGoalAnalytics(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SavingGoalAnalyticsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$savingGoalAnalyticsHash() =>
    r'3a9c169d3245f1e91a189e721dc71f41eea80052';

final class SavingGoalAnalyticsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<SavingGoalAnalytics>, String> {
  SavingGoalAnalyticsFamily._()
    : super(
        retry: null,
        name: r'savingGoalAnalyticsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SavingGoalAnalyticsProvider call(String goalId) =>
      SavingGoalAnalyticsProvider._(argument: goalId, from: this);

  @override
  String toString() => r'savingGoalAnalyticsProvider';
}

@ProviderFor(savingGoalCategories)
final savingGoalCategoriesProvider = SavingGoalCategoriesProvider._();

final class SavingGoalCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Category>>,
          List<Category>,
          Stream<List<Category>>
        >
    with $FutureModifier<List<Category>>, $StreamProvider<List<Category>> {
  SavingGoalCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savingGoalCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savingGoalCategoriesHash();

  @$internal
  @override
  $StreamProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Category>> create(Ref ref) {
    return savingGoalCategories(ref);
  }
}

String _$savingGoalCategoriesHash() =>
    r'34a6b5c9392d000986342e7a5171c6821a04daf5';

@ProviderFor(savingGoalTransactions)
final savingGoalTransactionsProvider = SavingGoalTransactionsFamily._();

final class SavingGoalTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransactionEntity>>,
          List<TransactionEntity>,
          Stream<List<TransactionEntity>>
        >
    with
        $FutureModifier<List<TransactionEntity>>,
        $StreamProvider<List<TransactionEntity>> {
  SavingGoalTransactionsProvider._({
    required SavingGoalTransactionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'savingGoalTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$savingGoalTransactionsHash();

  @override
  String toString() {
    return r'savingGoalTransactionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TransactionEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TransactionEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return savingGoalTransactions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SavingGoalTransactionsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$savingGoalTransactionsHash() =>
    r'107d34d3d305c0c04b39f32eeccb85a38204dd10';

final class SavingGoalTransactionsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TransactionEntity>>, String> {
  SavingGoalTransactionsFamily._()
    : super(
        retry: null,
        name: r'savingGoalTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SavingGoalTransactionsProvider call(String goalId) =>
      SavingGoalTransactionsProvider._(argument: goalId, from: this);

  @override
  String toString() => r'savingGoalTransactionsProvider';
}

@ProviderFor(savingGoalForecast)
final savingGoalForecastProvider = SavingGoalForecastFamily._();

final class SavingGoalForecastProvider
    extends
        $FunctionalProvider<
          SavingGoalForecast?,
          SavingGoalForecast?,
          SavingGoalForecast?
        >
    with $Provider<SavingGoalForecast?> {
  SavingGoalForecastProvider._({
    required SavingGoalForecastFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'savingGoalForecastProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$savingGoalForecastHash();

  @override
  String toString() {
    return r'savingGoalForecastProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<SavingGoalForecast?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SavingGoalForecast? create(Ref ref) {
    final argument = this.argument as String;
    return savingGoalForecast(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavingGoalForecast? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavingGoalForecast?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SavingGoalForecastProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$savingGoalForecastHash() =>
    r'b49c1a331ca109f8f6139157e6c338a042b0f5dc';

final class SavingGoalForecastFamily extends $Family
    with $FunctionalFamilyOverride<SavingGoalForecast?, String> {
  SavingGoalForecastFamily._()
    : super(
        retry: null,
        name: r'savingGoalForecastProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SavingGoalForecastProvider call(String goalId) =>
      SavingGoalForecastProvider._(argument: goalId, from: this);

  @override
  String toString() => r'savingGoalForecastProvider';
}

@ProviderFor(savingGoalAccounts)
final savingGoalAccountsProvider = SavingGoalAccountsFamily._();

final class SavingGoalAccountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AccountEntity>>,
          List<AccountEntity>,
          Stream<List<AccountEntity>>
        >
    with
        $FutureModifier<List<AccountEntity>>,
        $StreamProvider<List<AccountEntity>> {
  SavingGoalAccountsProvider._({
    required SavingGoalAccountsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'savingGoalAccountsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$savingGoalAccountsHash();

  @override
  String toString() {
    return r'savingGoalAccountsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<AccountEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AccountEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return savingGoalAccounts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SavingGoalAccountsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$savingGoalAccountsHash() =>
    r'a6ef51718476091af81ae8fe6a15e65a32f66b7f';

final class SavingGoalAccountsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<AccountEntity>>, String> {
  SavingGoalAccountsFamily._()
    : super(
        retry: null,
        name: r'savingGoalAccountsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SavingGoalAccountsProvider call(String goalId) =>
      SavingGoalAccountsProvider._(argument: goalId, from: this);

  @override
  String toString() => r'savingGoalAccountsProvider';
}
