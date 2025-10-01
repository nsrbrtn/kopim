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

String _$homeAccountsHash() => r'228b4bfff4cac42f565e3c58e564e9c447125e77';

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
    with
        $FutureModifier<List<Category>>,
        $StreamProvider<List<Category>> {
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

String _$homeCategoriesHash() => r'3f6a0b9d9276cb448f1d5bf4ed9b589e08e9f8f0';

@ProviderFor(homeTotalBalance)
const homeTotalBalanceProvider = HomeTotalBalanceProvider._();

final class HomeTotalBalanceProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  const HomeTotalBalanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeTotalBalanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeTotalBalanceHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return homeTotalBalance(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$homeTotalBalanceHash() => r'8c73907b65d1cfbc591a7aa884386c33a149bb90';
