// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upcoming_payment_selection_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(upcomingPaymentAccounts)
const upcomingPaymentAccountsProvider = UpcomingPaymentAccountsProvider._();

final class UpcomingPaymentAccountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AccountEntity>>,
          List<AccountEntity>,
          Stream<List<AccountEntity>>
        >
    with
        $FutureModifier<List<AccountEntity>>,
        $StreamProvider<List<AccountEntity>> {
  const UpcomingPaymentAccountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upcomingPaymentAccountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upcomingPaymentAccountsHash();

  @$internal
  @override
  $StreamProviderElement<List<AccountEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AccountEntity>> create(Ref ref) {
    return upcomingPaymentAccounts(ref);
  }
}

String _$upcomingPaymentAccountsHash() =>
    r'6a7c52dde1c65922cac8b74c8a3d3260c9786416';

@ProviderFor(upcomingPaymentCategories)
const upcomingPaymentCategoriesProvider = UpcomingPaymentCategoriesProvider._();

final class UpcomingPaymentCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Category>>,
          List<Category>,
          Stream<List<Category>>
        >
    with $FutureModifier<List<Category>>, $StreamProvider<List<Category>> {
  const UpcomingPaymentCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upcomingPaymentCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upcomingPaymentCategoriesHash();

  @$internal
  @override
  $StreamProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Category>> create(Ref ref) {
    return upcomingPaymentCategories(ref);
  }
}

String _$upcomingPaymentCategoriesHash() =>
    r'6f4feea99eece5c83dd4ece6d37968edee7c6534';
