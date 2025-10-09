// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saving_goal_details_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(savingGoalById)
const savingGoalByIdProvider = SavingGoalByIdFamily._();

final class SavingGoalByIdProvider
    extends $FunctionalProvider<SavingGoal?, SavingGoal?, SavingGoal?>
    with $Provider<SavingGoal?> {
  const SavingGoalByIdProvider._({
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
  const SavingGoalByIdFamily._()
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
const savingGoalAnalyticsProvider = SavingGoalAnalyticsFamily._();

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
  const SavingGoalAnalyticsProvider._({
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
  const SavingGoalAnalyticsFamily._()
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
const savingGoalCategoriesProvider = SavingGoalCategoriesProvider._();

final class SavingGoalCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Category>>,
          List<Category>,
          Stream<List<Category>>
        >
    with $FutureModifier<List<Category>>, $StreamProvider<List<Category>> {
  const SavingGoalCategoriesProvider._()
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
