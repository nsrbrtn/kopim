// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(homeAccounts)
const homeAccountsProvider = HomeAccountsProvider._();

final class HomeAccountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AccountEntity>>,
          List<AccountEntity>,
          Stream<List<AccountEntity>>
        >
    with
        $FutureModifier<List<AccountEntity>>,
        $StreamProvider<List<AccountEntity>> {
  const HomeAccountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeAccountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeAccountsHash();

  @$internal
  @override
  $StreamProviderElement<List<AccountEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AccountEntity>> create(Ref ref) {
    return homeAccounts(ref);
  }
}

String _$homeAccountsHash() => r'8945946a53312c5132885e6ec5e57e04735f22c4';

@ProviderFor(homeRecentTransactions)
const homeRecentTransactionsProvider = HomeRecentTransactionsFamily._();

final class HomeRecentTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransactionEntity>>,
          List<TransactionEntity>,
          Stream<List<TransactionEntity>>
        >
    with
        $FutureModifier<List<TransactionEntity>>,
        $StreamProvider<List<TransactionEntity>> {
  const HomeRecentTransactionsProvider._({
    required HomeRecentTransactionsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'homeRecentTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$homeRecentTransactionsHash();

  @override
  String toString() {
    return r'homeRecentTransactionsProvider'
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
    final argument = this.argument as int;
    return homeRecentTransactions(ref, limit: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HomeRecentTransactionsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$homeRecentTransactionsHash() =>
    r'cc93213ec30ee8f438b8779a486fdfec73cb7956';

final class HomeRecentTransactionsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TransactionEntity>>, int> {
  const HomeRecentTransactionsFamily._()
    : super(
        retry: null,
        name: r'homeRecentTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HomeRecentTransactionsProvider call({
    int limit = kDefaultRecentTransactionsLimit,
  }) => HomeRecentTransactionsProvider._(argument: limit, from: this);

  @override
  String toString() => r'homeRecentTransactionsProvider';
}

@ProviderFor(homeCategories)
const homeCategoriesProvider = HomeCategoriesProvider._();

final class HomeCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Category>>,
          List<Category>,
          Stream<List<Category>>
        >
    with $FutureModifier<List<Category>>, $StreamProvider<List<Category>> {
  const HomeCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeCategoriesHash();

  @$internal
  @override
  $StreamProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Category>> create(Ref ref) {
    return homeCategories(ref);
  }
}

String _$homeCategoriesHash() => r'8489f218304563096d7997f846877f8ab2a5c725';

@ProviderFor(homeTransactionById)
const homeTransactionByIdProvider = HomeTransactionByIdFamily._();

final class HomeTransactionByIdProvider
    extends
        $FunctionalProvider<
          TransactionEntity?,
          TransactionEntity?,
          TransactionEntity?
        >
    with $Provider<TransactionEntity?> {
  const HomeTransactionByIdProvider._({
    required HomeTransactionByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'homeTransactionByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$homeTransactionByIdHash();

  @override
  String toString() {
    return r'homeTransactionByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<TransactionEntity?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransactionEntity? create(Ref ref) {
    final argument = this.argument as String;
    return homeTransactionById(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionEntity? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionEntity?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HomeTransactionByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$homeTransactionByIdHash() =>
    r'9efc903a793463e1044ee4dcee3130d3c1d62ca1';

final class HomeTransactionByIdFamily extends $Family
    with $FunctionalFamilyOverride<TransactionEntity?, String> {
  const HomeTransactionByIdFamily._()
    : super(
        retry: null,
        name: r'homeTransactionByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HomeTransactionByIdProvider call(String id) =>
      HomeTransactionByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'homeTransactionByIdProvider';
}

@ProviderFor(homeAccountById)
const homeAccountByIdProvider = HomeAccountByIdFamily._();

final class HomeAccountByIdProvider
    extends $FunctionalProvider<AccountEntity?, AccountEntity?, AccountEntity?>
    with $Provider<AccountEntity?> {
  const HomeAccountByIdProvider._({
    required HomeAccountByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'homeAccountByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$homeAccountByIdHash();

  @override
  String toString() {
    return r'homeAccountByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AccountEntity?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccountEntity? create(Ref ref) {
    final argument = this.argument as String;
    return homeAccountById(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountEntity? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountEntity?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HomeAccountByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$homeAccountByIdHash() => r'66dfb92d476fa8869ebbfadfbca272c3b8d7695d';

final class HomeAccountByIdFamily extends $Family
    with $FunctionalFamilyOverride<AccountEntity?, String> {
  const HomeAccountByIdFamily._()
    : super(
        retry: null,
        name: r'homeAccountByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HomeAccountByIdProvider call(String id) =>
      HomeAccountByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'homeAccountByIdProvider';
}

@ProviderFor(homeCategoryById)
const homeCategoryByIdProvider = HomeCategoryByIdFamily._();

final class HomeCategoryByIdProvider
    extends $FunctionalProvider<Category?, Category?, Category?>
    with $Provider<Category?> {
  const HomeCategoryByIdProvider._({
    required HomeCategoryByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'homeCategoryByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$homeCategoryByIdHash();

  @override
  String toString() {
    return r'homeCategoryByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Category?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Category? create(Ref ref) {
    final argument = this.argument as String;
    return homeCategoryById(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Category? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Category?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HomeCategoryByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$homeCategoryByIdHash() => r'e6df1590b2cce5e948b66cec8bee0c9fcbdc5036';

final class HomeCategoryByIdFamily extends $Family
    with $FunctionalFamilyOverride<Category?, String> {
  const HomeCategoryByIdFamily._()
    : super(
        retry: null,
        name: r'homeCategoryByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HomeCategoryByIdProvider call(String id) =>
      HomeCategoryByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'homeCategoryByIdProvider';
}

@ProviderFor(homeSavingGoals)
const homeSavingGoalsProvider = HomeSavingGoalsProvider._();

final class HomeSavingGoalsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SavingGoal>>,
          List<SavingGoal>,
          Stream<List<SavingGoal>>
        >
    with $FutureModifier<List<SavingGoal>>, $StreamProvider<List<SavingGoal>> {
  const HomeSavingGoalsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeSavingGoalsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeSavingGoalsHash();

  @$internal
  @override
  $StreamProviderElement<List<SavingGoal>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SavingGoal>> create(Ref ref) {
    return homeSavingGoals(ref);
  }
}

String _$homeSavingGoalsHash() => r'4030a8cc0b315618bd1f7976e56dbb3820a1cbc7';

@ProviderFor(homeSavingGoalProgress)
const homeSavingGoalProgressProvider = HomeSavingGoalProgressProvider._();

final class HomeSavingGoalProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GoalProgress>>,
          AsyncValue<List<GoalProgress>>,
          AsyncValue<List<GoalProgress>>
        >
    with $Provider<AsyncValue<List<GoalProgress>>> {
  const HomeSavingGoalProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeSavingGoalProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeSavingGoalProgressHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<GoalProgress>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<GoalProgress>> create(Ref ref) {
    return homeSavingGoalProgress(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<GoalProgress>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<GoalProgress>>>(
        value,
      ),
    );
  }
}

String _$homeSavingGoalProgressHash() =>
    r'0ef1a4b8be63e03602f70f6fe70f7af1b5a76849';

@ProviderFor(homeGroupedTransactions)
const homeGroupedTransactionsProvider = HomeGroupedTransactionsProvider._();

final class HomeGroupedTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DaySection>>,
          AsyncValue<List<DaySection>>,
          AsyncValue<List<DaySection>>
        >
    with $Provider<AsyncValue<List<DaySection>>> {
  const HomeGroupedTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeGroupedTransactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeGroupedTransactionsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<DaySection>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<DaySection>> create(Ref ref) {
    return homeGroupedTransactions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<DaySection>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<DaySection>>>(value),
    );
  }
}

String _$homeGroupedTransactionsHash() =>
    r'7f246cf20b77a3442fdced6c14a81c95cf54f9b6';

@ProviderFor(homeAccountMonthlySummaries)
const homeAccountMonthlySummariesProvider =
    HomeAccountMonthlySummariesProvider._();

final class HomeAccountMonthlySummariesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, HomeAccountMonthlySummary>>,
          Map<String, HomeAccountMonthlySummary>,
          Stream<Map<String, HomeAccountMonthlySummary>>
        >
    with
        $FutureModifier<Map<String, HomeAccountMonthlySummary>>,
        $StreamProvider<Map<String, HomeAccountMonthlySummary>> {
  const HomeAccountMonthlySummariesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeAccountMonthlySummariesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeAccountMonthlySummariesHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, HomeAccountMonthlySummary>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, HomeAccountMonthlySummary>> create(Ref ref) {
    return homeAccountMonthlySummaries(ref);
  }
}

String _$homeAccountMonthlySummariesHash() =>
    r'246f0197a9ea556d55ae637f052a7b25991561da';
