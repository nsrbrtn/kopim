// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_transactions_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(allTransactionsStream)
const allTransactionsStreamProvider = AllTransactionsStreamProvider._();

final class AllTransactionsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransactionEntity>>,
          List<TransactionEntity>,
          Stream<List<TransactionEntity>>
        >
    with
        $FutureModifier<List<TransactionEntity>>,
        $StreamProvider<List<TransactionEntity>> {
  const AllTransactionsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allTransactionsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allTransactionsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<TransactionEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TransactionEntity>> create(Ref ref) {
    return allTransactionsStream(ref);
  }
}

String _$allTransactionsStreamHash() =>
    r'40d34963e6d37b9bcf09198a1443256a8b34a2a7';

@ProviderFor(filteredTransactions)
const filteredTransactionsProvider = FilteredTransactionsProvider._();

final class FilteredTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransactionEntity>>,
          AsyncValue<List<TransactionEntity>>,
          AsyncValue<List<TransactionEntity>>
        >
    with $Provider<AsyncValue<List<TransactionEntity>>> {
  const FilteredTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredTransactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredTransactionsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<TransactionEntity>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<TransactionEntity>> create(Ref ref) {
    return filteredTransactions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<TransactionEntity>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<TransactionEntity>>>(
        value,
      ),
    );
  }
}

String _$filteredTransactionsHash() =>
    r'5c8c432acc5112635da78e972a38da70a44cbd71';

@ProviderFor(allTransactionsAccounts)
const allTransactionsAccountsProvider = AllTransactionsAccountsProvider._();

final class AllTransactionsAccountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AccountEntity>>,
          List<AccountEntity>,
          Stream<List<AccountEntity>>
        >
    with
        $FutureModifier<List<AccountEntity>>,
        $StreamProvider<List<AccountEntity>> {
  const AllTransactionsAccountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allTransactionsAccountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allTransactionsAccountsHash();

  @$internal
  @override
  $StreamProviderElement<List<AccountEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AccountEntity>> create(Ref ref) {
    return allTransactionsAccounts(ref);
  }
}

String _$allTransactionsAccountsHash() =>
    r'8ef685e924219321d2fe549cc7c345a8cfc08579';

@ProviderFor(allTransactionsCategories)
const allTransactionsCategoriesProvider = AllTransactionsCategoriesProvider._();

final class AllTransactionsCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Category>>,
          List<Category>,
          Stream<List<Category>>
        >
    with $FutureModifier<List<Category>>, $StreamProvider<List<Category>> {
  const AllTransactionsCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allTransactionsCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allTransactionsCategoriesHash();

  @$internal
  @override
  $StreamProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Category>> create(Ref ref) {
    return allTransactionsCategories(ref);
  }
}

String _$allTransactionsCategoriesHash() =>
    r'e70776e0f387ef56b1d4067ce8a74bc7125b517e';
