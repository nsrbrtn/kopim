// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budgets_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(budgetsStream)
const budgetsStreamProvider = BudgetsStreamProvider._();

final class BudgetsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Budget>>,
          List<Budget>,
          Stream<List<Budget>>
        >
    with $FutureModifier<List<Budget>>, $StreamProvider<List<Budget>> {
  const BudgetsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Budget>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Budget>> create(Ref ref) {
    return budgetsStream(ref);
  }
}

String _$budgetsStreamHash() => r'797212de1c19f0af950b15b3bbbdc429ac1d445d';

@ProviderFor(budgetTransactionsStream)
const budgetTransactionsStreamProvider = BudgetTransactionsStreamProvider._();

final class BudgetTransactionsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransactionEntity>>,
          List<TransactionEntity>,
          Stream<List<TransactionEntity>>
        >
    with
        $FutureModifier<List<TransactionEntity>>,
        $StreamProvider<List<TransactionEntity>> {
  const BudgetTransactionsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetTransactionsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetTransactionsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<TransactionEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TransactionEntity>> create(Ref ref) {
    return budgetTransactionsStream(ref);
  }
}

String _$budgetTransactionsStreamHash() =>
    r'689adbc8b0d77aa1a6ef79d389160357a47b1ccd';

@ProviderFor(budgetAccountsStream)
const budgetAccountsStreamProvider = BudgetAccountsStreamProvider._();

final class BudgetAccountsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AccountEntity>>,
          List<AccountEntity>,
          Stream<List<AccountEntity>>
        >
    with
        $FutureModifier<List<AccountEntity>>,
        $StreamProvider<List<AccountEntity>> {
  const BudgetAccountsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetAccountsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetAccountsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<AccountEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AccountEntity>> create(Ref ref) {
    return budgetAccountsStream(ref);
  }
}

String _$budgetAccountsStreamHash() =>
    r'8884a5a979807f7ffc5021082793f15a1dced0ed';

@ProviderFor(budgetCategoriesStream)
const budgetCategoriesStreamProvider = BudgetCategoriesStreamProvider._();

final class BudgetCategoriesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Category>>,
          List<Category>,
          Stream<List<Category>>
        >
    with $FutureModifier<List<Category>>, $StreamProvider<List<Category>> {
  const BudgetCategoriesStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetCategoriesStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetCategoriesStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Category>> create(Ref ref) {
    return budgetCategoriesStream(ref);
  }
}

String _$budgetCategoriesStreamHash() =>
    r'8389a92c1fdadf6a6f7e7820229683ca037a6dfb';

@ProviderFor(budgetsWithProgress)
const budgetsWithProgressProvider = BudgetsWithProgressProvider._();

final class BudgetsWithProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BudgetProgress>>,
          AsyncValue<List<BudgetProgress>>,
          AsyncValue<List<BudgetProgress>>
        >
    with $Provider<AsyncValue<List<BudgetProgress>>> {
  const BudgetsWithProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetsWithProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetsWithProgressHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<BudgetProgress>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<BudgetProgress>> create(Ref ref) {
    return budgetsWithProgress(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<BudgetProgress>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<BudgetProgress>>>(
        value,
      ),
    );
  }
}

String _$budgetsWithProgressHash() =>
    r'89904c6d80e517389af54ec72a7aca7833697ed3';

@ProviderFor(budgetCategorySpend)
const budgetCategorySpendProvider = BudgetCategorySpendProvider._();

final class BudgetCategorySpendProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BudgetCategorySpend>>,
          AsyncValue<List<BudgetCategorySpend>>,
          AsyncValue<List<BudgetCategorySpend>>
        >
    with $Provider<AsyncValue<List<BudgetCategorySpend>>> {
  const BudgetCategorySpendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetCategorySpendProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetCategorySpendHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<BudgetCategorySpend>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<BudgetCategorySpend>> create(Ref ref) {
    return budgetCategorySpend(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<BudgetCategorySpend>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<List<BudgetCategorySpend>>>(value),
    );
  }
}

String _$budgetCategorySpendHash() =>
    r'08b3499b99f4a3af0a35014669c9cf25ac410432';

@ProviderFor(budgetProgressById)
const budgetProgressByIdProvider = BudgetProgressByIdFamily._();

final class BudgetProgressByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<BudgetProgress>,
          AsyncValue<BudgetProgress>,
          AsyncValue<BudgetProgress>
        >
    with $Provider<AsyncValue<BudgetProgress>> {
  const BudgetProgressByIdProvider._({
    required BudgetProgressByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'budgetProgressByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$budgetProgressByIdHash();

  @override
  String toString() {
    return r'budgetProgressByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<BudgetProgress>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<BudgetProgress> create(Ref ref) {
    final argument = this.argument as String;
    return budgetProgressById(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<BudgetProgress> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<BudgetProgress>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetProgressByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$budgetProgressByIdHash() =>
    r'98be397fb4e2bcc3eccd0b1156e268c66a63f52b';

final class BudgetProgressByIdFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<BudgetProgress>, String> {
  const BudgetProgressByIdFamily._()
    : super(
        retry: null,
        name: r'budgetProgressByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BudgetProgressByIdProvider call(String budgetId) =>
      BudgetProgressByIdProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'budgetProgressByIdProvider';
}

@ProviderFor(budgetTransactionsById)
const budgetTransactionsByIdProvider = BudgetTransactionsByIdFamily._();

final class BudgetTransactionsByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransactionEntity>>,
          AsyncValue<List<TransactionEntity>>,
          AsyncValue<List<TransactionEntity>>
        >
    with $Provider<AsyncValue<List<TransactionEntity>>> {
  const BudgetTransactionsByIdProvider._({
    required BudgetTransactionsByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'budgetTransactionsByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$budgetTransactionsByIdHash();

  @override
  String toString() {
    return r'budgetTransactionsByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<List<TransactionEntity>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<TransactionEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return budgetTransactionsById(ref, argument);
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

  @override
  bool operator ==(Object other) {
    return other is BudgetTransactionsByIdProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$budgetTransactionsByIdHash() =>
    r'abf328ad96ded79090fc64c79967638cd8e586ee';

final class BudgetTransactionsByIdFamily extends $Family
    with
        $FunctionalFamilyOverride<AsyncValue<List<TransactionEntity>>, String> {
  const BudgetTransactionsByIdFamily._()
    : super(
        retry: null,
        name: r'budgetTransactionsByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BudgetTransactionsByIdProvider call(String budgetId) =>
      BudgetTransactionsByIdProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'budgetTransactionsByIdProvider';
}

@ProviderFor(budgetInstancesByBudget)
const budgetInstancesByBudgetProvider = BudgetInstancesByBudgetFamily._();

final class BudgetInstancesByBudgetProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BudgetInstance>>,
          List<BudgetInstance>,
          FutureOr<List<BudgetInstance>>
        >
    with
        $FutureModifier<List<BudgetInstance>>,
        $FutureProvider<List<BudgetInstance>> {
  const BudgetInstancesByBudgetProvider._({
    required BudgetInstancesByBudgetFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'budgetInstancesByBudgetProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$budgetInstancesByBudgetHash();

  @override
  String toString() {
    return r'budgetInstancesByBudgetProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<BudgetInstance>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BudgetInstance>> create(Ref ref) {
    final argument = this.argument as String;
    return budgetInstancesByBudget(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetInstancesByBudgetProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$budgetInstancesByBudgetHash() =>
    r'34b1e34789afb10dfe76892a7a3ccd6e56915370';

final class BudgetInstancesByBudgetFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<BudgetInstance>>, String> {
  const BudgetInstancesByBudgetFamily._()
    : super(
        retry: null,
        name: r'budgetInstancesByBudgetProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BudgetInstancesByBudgetProvider call(String budgetId) =>
      BudgetInstancesByBudgetProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'budgetInstancesByBudgetProvider';
}
