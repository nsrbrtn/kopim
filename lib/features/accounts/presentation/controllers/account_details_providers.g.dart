// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_details_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(accountDetails)
const accountDetailsProvider = AccountDetailsFamily._();

final class AccountDetailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AccountEntity?>,
          AccountEntity?,
          Stream<AccountEntity?>
        >
    with $FutureModifier<AccountEntity?>, $StreamProvider<AccountEntity?> {
  const AccountDetailsProvider._({
    required AccountDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountDetailsHash();

  @override
  String toString() {
    return r'accountDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<AccountEntity?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AccountEntity?> create(Ref ref) {
    final argument = this.argument as String;
    return accountDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountDetailsHash() => r'0c0bb8c45ca729a38f98b36f7d63b3197a9b253e';

final class AccountDetailsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<AccountEntity?>, String> {
  const AccountDetailsFamily._()
    : super(
        retry: null,
        name: r'accountDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountDetailsProvider call(String accountId) =>
      AccountDetailsProvider._(argument: accountId, from: this);

  @override
  String toString() => r'accountDetailsProvider';
}

@ProviderFor(accountTransactions)
const accountTransactionsProvider = AccountTransactionsFamily._();

final class AccountTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransactionEntity>>,
          List<TransactionEntity>,
          Stream<List<TransactionEntity>>
        >
    with
        $FutureModifier<List<TransactionEntity>>,
        $StreamProvider<List<TransactionEntity>> {
  const AccountTransactionsProvider._({
    required AccountTransactionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountTransactionsHash();

  @override
  String toString() {
    return r'accountTransactionsProvider'
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
    return accountTransactions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountTransactionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountTransactionsHash() =>
    r'ef93cea78d14040a94a1b91687be7f5def70b257';

final class AccountTransactionsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TransactionEntity>>, String> {
  const AccountTransactionsFamily._()
    : super(
        retry: null,
        name: r'accountTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountTransactionsProvider call(String accountId) =>
      AccountTransactionsProvider._(argument: accountId, from: this);

  @override
  String toString() => r'accountTransactionsProvider';
}

@ProviderFor(AccountTransactionsVisibleMonthsController)
const accountTransactionsVisibleMonthsControllerProvider =
    AccountTransactionsVisibleMonthsControllerFamily._();

final class AccountTransactionsVisibleMonthsControllerProvider
    extends $NotifierProvider<AccountTransactionsVisibleMonthsController, int> {
  const AccountTransactionsVisibleMonthsControllerProvider._({
    required AccountTransactionsVisibleMonthsControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountTransactionsVisibleMonthsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$accountTransactionsVisibleMonthsControllerHash();

  @override
  String toString() {
    return r'accountTransactionsVisibleMonthsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AccountTransactionsVisibleMonthsController create() =>
      AccountTransactionsVisibleMonthsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AccountTransactionsVisibleMonthsControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountTransactionsVisibleMonthsControllerHash() =>
    r'0b904eeafc40d62d6d95a080866da0a02e40773b';

final class AccountTransactionsVisibleMonthsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          AccountTransactionsVisibleMonthsController,
          int,
          int,
          int,
          String
        > {
  const AccountTransactionsVisibleMonthsControllerFamily._()
    : super(
        retry: null,
        name: r'accountTransactionsVisibleMonthsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountTransactionsVisibleMonthsControllerProvider call(String accountId) =>
      AccountTransactionsVisibleMonthsControllerProvider._(
        argument: accountId,
        from: this,
      );

  @override
  String toString() => r'accountTransactionsVisibleMonthsControllerProvider';
}

abstract class _$AccountTransactionsVisibleMonthsController
    extends $Notifier<int> {
  late final _$args = ref.$arg as String;
  String get accountId => _$args;

  int build(String accountId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(AccountDetailsPeriodController)
const accountDetailsPeriodControllerProvider =
    AccountDetailsPeriodControllerFamily._();

final class AccountDetailsPeriodControllerProvider
    extends
        $NotifierProvider<
          AccountDetailsPeriodController,
          AccountDetailsPeriod
        > {
  const AccountDetailsPeriodControllerProvider._({
    required AccountDetailsPeriodControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountDetailsPeriodControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountDetailsPeriodControllerHash();

  @override
  String toString() {
    return r'accountDetailsPeriodControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AccountDetailsPeriodController create() => AccountDetailsPeriodController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountDetailsPeriod value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountDetailsPeriod>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AccountDetailsPeriodControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountDetailsPeriodControllerHash() =>
    r'ad79a33604e5565cc0a6a869571c7435f713b9ab';

final class AccountDetailsPeriodControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          AccountDetailsPeriodController,
          AccountDetailsPeriod,
          AccountDetailsPeriod,
          AccountDetailsPeriod,
          String
        > {
  const AccountDetailsPeriodControllerFamily._()
    : super(
        retry: null,
        name: r'accountDetailsPeriodControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountDetailsPeriodControllerProvider call(String accountId) =>
      AccountDetailsPeriodControllerProvider._(argument: accountId, from: this);

  @override
  String toString() => r'accountDetailsPeriodControllerProvider';
}

abstract class _$AccountDetailsPeriodController
    extends $Notifier<AccountDetailsPeriod> {
  late final _$args = ref.$arg as String;
  String get accountId => _$args;

  AccountDetailsPeriod build(String accountId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AccountDetailsPeriod, AccountDetailsPeriod>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AccountDetailsPeriod, AccountDetailsPeriod>,
              AccountDetailsPeriod,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(accountDetailsPeriodRange)
const accountDetailsPeriodRangeProvider = AccountDetailsPeriodRangeFamily._();

final class AccountDetailsPeriodRangeProvider
    extends
        $FunctionalProvider<
          DateTimeRange<DateTime>,
          DateTimeRange<DateTime>,
          DateTimeRange<DateTime>
        >
    with $Provider<DateTimeRange<DateTime>> {
  const AccountDetailsPeriodRangeProvider._({
    required AccountDetailsPeriodRangeFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountDetailsPeriodRangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountDetailsPeriodRangeHash();

  @override
  String toString() {
    return r'accountDetailsPeriodRangeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<DateTimeRange<DateTime>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DateTimeRange<DateTime> create(Ref ref) {
    final argument = this.argument as String;
    return accountDetailsPeriodRange(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTimeRange<DateTime> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTimeRange<DateTime>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AccountDetailsPeriodRangeProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountDetailsPeriodRangeHash() =>
    r'038ff480a11c1282b2aeed6a2469995435d31819';

final class AccountDetailsPeriodRangeFamily extends $Family
    with $FunctionalFamilyOverride<DateTimeRange<DateTime>, String> {
  const AccountDetailsPeriodRangeFamily._()
    : super(
        retry: null,
        name: r'accountDetailsPeriodRangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountDetailsPeriodRangeProvider call(String accountId) =>
      AccountDetailsPeriodRangeProvider._(argument: accountId, from: this);

  @override
  String toString() => r'accountDetailsPeriodRangeProvider';
}

@ProviderFor(accountTransactionsVisibleRange)
const accountTransactionsVisibleRangeProvider =
    AccountTransactionsVisibleRangeFamily._();

final class AccountTransactionsVisibleRangeProvider
    extends
        $FunctionalProvider<
          DateTimeRange<DateTime>,
          DateTimeRange<DateTime>,
          DateTimeRange<DateTime>
        >
    with $Provider<DateTimeRange<DateTime>> {
  const AccountTransactionsVisibleRangeProvider._({
    required AccountTransactionsVisibleRangeFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountTransactionsVisibleRangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountTransactionsVisibleRangeHash();

  @override
  String toString() {
    return r'accountTransactionsVisibleRangeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<DateTimeRange<DateTime>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DateTimeRange<DateTime> create(Ref ref) {
    final argument = this.argument as String;
    return accountTransactionsVisibleRange(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTimeRange<DateTime> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTimeRange<DateTime>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AccountTransactionsVisibleRangeProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountTransactionsVisibleRangeHash() =>
    r'24d68245b551edd490c39b7f1d7f5704d47d1507';

final class AccountTransactionsVisibleRangeFamily extends $Family
    with $FunctionalFamilyOverride<DateTimeRange<DateTime>, String> {
  const AccountTransactionsVisibleRangeFamily._()
    : super(
        retry: null,
        name: r'accountTransactionsVisibleRangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountTransactionsVisibleRangeProvider call(String accountId) =>
      AccountTransactionsVisibleRangeProvider._(
        argument: accountId,
        from: this,
      );

  @override
  String toString() => r'accountTransactionsVisibleRangeProvider';
}

@ProviderFor(accountTopCategoryTotals)
const accountTopCategoryTotalsProvider = AccountTopCategoryTotalsFamily._();

final class AccountTopCategoryTotalsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransactionCategoryTotals>>,
          List<TransactionCategoryTotals>,
          Stream<List<TransactionCategoryTotals>>
        >
    with
        $FutureModifier<List<TransactionCategoryTotals>>,
        $StreamProvider<List<TransactionCategoryTotals>> {
  const AccountTopCategoryTotalsProvider._({
    required AccountTopCategoryTotalsFamily super.from,
    required ({String accountId, DateTime start, DateTime end}) super.argument,
  }) : super(
         retry: null,
         name: r'accountTopCategoryTotalsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountTopCategoryTotalsHash();

  @override
  String toString() {
    return r'accountTopCategoryTotalsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<TransactionCategoryTotals>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TransactionCategoryTotals>> create(Ref ref) {
    final argument =
        this.argument as ({String accountId, DateTime start, DateTime end});
    return accountTopCategoryTotals(
      ref,
      accountId: argument.accountId,
      start: argument.start,
      end: argument.end,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AccountTopCategoryTotalsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountTopCategoryTotalsHash() =>
    r'f74f5333ac0ca1b9a11af3b84503e2331e0f9291';

final class AccountTopCategoryTotalsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<TransactionCategoryTotals>>,
          ({String accountId, DateTime start, DateTime end})
        > {
  const AccountTopCategoryTotalsFamily._()
    : super(
        retry: null,
        name: r'accountTopCategoryTotalsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountTopCategoryTotalsProvider call({
    required String accountId,
    required DateTime start,
    required DateTime end,
  }) => AccountTopCategoryTotalsProvider._(
    argument: (accountId: accountId, start: start, end: end),
    from: this,
  );

  @override
  String toString() => r'accountTopCategoryTotalsProvider';
}

@ProviderFor(accountCategories)
const accountCategoriesProvider = AccountCategoriesProvider._();

final class AccountCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Category>>,
          List<Category>,
          Stream<List<Category>>
        >
    with $FutureModifier<List<Category>>, $StreamProvider<List<Category>> {
  const AccountCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountCategoriesHash();

  @$internal
  @override
  $StreamProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Category>> create(Ref ref) {
    return accountCategories(ref);
  }
}

String _$accountCategoriesHash() => r'a2ff64337d4c3c1bd82315c851a4059ff4edb2b0';

@ProviderFor(accountTransactionSummary)
const accountTransactionSummaryProvider = AccountTransactionSummaryFamily._();

final class AccountTransactionSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<AccountTransactionSummary>,
          AsyncValue<AccountTransactionSummary>,
          AsyncValue<AccountTransactionSummary>
        >
    with $Provider<AsyncValue<AccountTransactionSummary>> {
  const AccountTransactionSummaryProvider._({
    required AccountTransactionSummaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountTransactionSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountTransactionSummaryHash();

  @override
  String toString() {
    return r'accountTransactionSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<AccountTransactionSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<AccountTransactionSummary> create(Ref ref) {
    final argument = this.argument as String;
    return accountTransactionSummary(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<AccountTransactionSummary> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<AccountTransactionSummary>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AccountTransactionSummaryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountTransactionSummaryHash() =>
    r'40fff73db0920fb613d0fec21fe63367db1e6f62';

final class AccountTransactionSummaryFamily extends $Family
    with
        $FunctionalFamilyOverride<
          AsyncValue<AccountTransactionSummary>,
          String
        > {
  const AccountTransactionSummaryFamily._()
    : super(
        retry: null,
        name: r'accountTransactionSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountTransactionSummaryProvider call(String accountId) =>
      AccountTransactionSummaryProvider._(argument: accountId, from: this);

  @override
  String toString() => r'accountTransactionSummaryProvider';
}

@ProviderFor(canShowMoreAccountTransactions)
const canShowMoreAccountTransactionsProvider =
    CanShowMoreAccountTransactionsFamily._();

final class CanShowMoreAccountTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<bool>,
          AsyncValue<bool>,
          AsyncValue<bool>
        >
    with $Provider<AsyncValue<bool>> {
  const CanShowMoreAccountTransactionsProvider._({
    required CanShowMoreAccountTransactionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'canShowMoreAccountTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$canShowMoreAccountTransactionsHash();

  @override
  String toString() {
    return r'canShowMoreAccountTransactionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<bool>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AsyncValue<bool> create(Ref ref) {
    final argument = this.argument as String;
    return canShowMoreAccountTransactions(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<bool> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<bool>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CanShowMoreAccountTransactionsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$canShowMoreAccountTransactionsHash() =>
    r'b76cf05e0848cf65ffc75c547b41cbe74a568e16';

final class CanShowMoreAccountTransactionsFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<bool>, String> {
  const CanShowMoreAccountTransactionsFamily._()
    : super(
        retry: null,
        name: r'canShowMoreAccountTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CanShowMoreAccountTransactionsProvider call(String accountId) =>
      CanShowMoreAccountTransactionsProvider._(argument: accountId, from: this);

  @override
  String toString() => r'canShowMoreAccountTransactionsProvider';
}

@ProviderFor(AccountTransactionsFilterController)
const accountTransactionsFilterControllerProvider =
    AccountTransactionsFilterControllerFamily._();

final class AccountTransactionsFilterControllerProvider
    extends
        $NotifierProvider<
          AccountTransactionsFilterController,
          AccountTransactionsFilter
        > {
  const AccountTransactionsFilterControllerProvider._({
    required AccountTransactionsFilterControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountTransactionsFilterControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$accountTransactionsFilterControllerHash();

  @override
  String toString() {
    return r'accountTransactionsFilterControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AccountTransactionsFilterController create() =>
      AccountTransactionsFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountTransactionsFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountTransactionsFilter>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AccountTransactionsFilterControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountTransactionsFilterControllerHash() =>
    r'700b422f13247983dd284fd1072e7567f4c931cf';

final class AccountTransactionsFilterControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          AccountTransactionsFilterController,
          AccountTransactionsFilter,
          AccountTransactionsFilter,
          AccountTransactionsFilter,
          String
        > {
  const AccountTransactionsFilterControllerFamily._()
    : super(
        retry: null,
        name: r'accountTransactionsFilterControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountTransactionsFilterControllerProvider call(String accountId) =>
      AccountTransactionsFilterControllerProvider._(
        argument: accountId,
        from: this,
      );

  @override
  String toString() => r'accountTransactionsFilterControllerProvider';
}

abstract class _$AccountTransactionsFilterController
    extends $Notifier<AccountTransactionsFilter> {
  late final _$args = ref.$arg as String;
  String get accountId => _$args;

  AccountTransactionsFilter build(String accountId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<AccountTransactionsFilter, AccountTransactionsFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AccountTransactionsFilter, AccountTransactionsFilter>,
              AccountTransactionsFilter,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(filteredAccountTransactions)
const filteredAccountTransactionsProvider =
    FilteredAccountTransactionsFamily._();

final class FilteredAccountTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransactionEntity>>,
          AsyncValue<List<TransactionEntity>>,
          AsyncValue<List<TransactionEntity>>
        >
    with $Provider<AsyncValue<List<TransactionEntity>>> {
  const FilteredAccountTransactionsProvider._({
    required FilteredAccountTransactionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'filteredAccountTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredAccountTransactionsHash();

  @override
  String toString() {
    return r'filteredAccountTransactionsProvider'
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
    return filteredAccountTransactions(ref, argument);
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
    return other is FilteredAccountTransactionsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredAccountTransactionsHash() =>
    r'5e344f3e67ebb95232963ae37f4f94d219179ba3';

final class FilteredAccountTransactionsFamily extends $Family
    with
        $FunctionalFamilyOverride<AsyncValue<List<TransactionEntity>>, String> {
  const FilteredAccountTransactionsFamily._()
    : super(
        retry: null,
        name: r'filteredAccountTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FilteredAccountTransactionsProvider call(String accountId) =>
      FilteredAccountTransactionsProvider._(argument: accountId, from: this);

  @override
  String toString() => r'filteredAccountTransactionsProvider';
}

@ProviderFor(accountTransactionsMatchingFilters)
const accountTransactionsMatchingFiltersProvider =
    AccountTransactionsMatchingFiltersFamily._();

final class AccountTransactionsMatchingFiltersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransactionEntity>>,
          AsyncValue<List<TransactionEntity>>,
          AsyncValue<List<TransactionEntity>>
        >
    with $Provider<AsyncValue<List<TransactionEntity>>> {
  const AccountTransactionsMatchingFiltersProvider._({
    required AccountTransactionsMatchingFiltersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountTransactionsMatchingFiltersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$accountTransactionsMatchingFiltersHash();

  @override
  String toString() {
    return r'accountTransactionsMatchingFiltersProvider'
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
    return accountTransactionsMatchingFilters(ref, argument);
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
    return other is AccountTransactionsMatchingFiltersProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountTransactionsMatchingFiltersHash() =>
    r'578fcd7c4d369fa0bfa641dc04c4b376991e6b7f';

final class AccountTransactionsMatchingFiltersFamily extends $Family
    with
        $FunctionalFamilyOverride<AsyncValue<List<TransactionEntity>>, String> {
  const AccountTransactionsMatchingFiltersFamily._()
    : super(
        retry: null,
        name: r'accountTransactionsMatchingFiltersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountTransactionsMatchingFiltersProvider call(String accountId) =>
      AccountTransactionsMatchingFiltersProvider._(
        argument: accountId,
        from: this,
      );

  @override
  String toString() => r'accountTransactionsMatchingFiltersProvider';
}
