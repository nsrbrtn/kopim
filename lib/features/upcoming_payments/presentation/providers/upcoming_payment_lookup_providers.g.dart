// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upcoming_payment_lookup_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(upcomingPaymentById)
const upcomingPaymentByIdProvider = UpcomingPaymentByIdFamily._();

final class UpcomingPaymentByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<UpcomingPayment?>,
          UpcomingPayment?,
          FutureOr<UpcomingPayment?>
        >
    with $FutureModifier<UpcomingPayment?>, $FutureProvider<UpcomingPayment?> {
  const UpcomingPaymentByIdProvider._({
    required UpcomingPaymentByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'upcomingPaymentByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$upcomingPaymentByIdHash();

  @override
  String toString() {
    return r'upcomingPaymentByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<UpcomingPayment?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UpcomingPayment?> create(Ref ref) {
    final argument = this.argument as String;
    return upcomingPaymentById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UpcomingPaymentByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$upcomingPaymentByIdHash() =>
    r'aac2ae94ab19a9678b028bb04729a6d6cdc0c76e';

final class UpcomingPaymentByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<UpcomingPayment?>, String> {
  const UpcomingPaymentByIdFamily._()
    : super(
        retry: null,
        name: r'upcomingPaymentByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UpcomingPaymentByIdProvider call(String id) =>
      UpcomingPaymentByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'upcomingPaymentByIdProvider';
}

@ProviderFor(paymentReminderById)
const paymentReminderByIdProvider = PaymentReminderByIdFamily._();

final class PaymentReminderByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaymentReminder?>,
          PaymentReminder?,
          FutureOr<PaymentReminder?>
        >
    with $FutureModifier<PaymentReminder?>, $FutureProvider<PaymentReminder?> {
  const PaymentReminderByIdProvider._({
    required PaymentReminderByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'paymentReminderByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$paymentReminderByIdHash();

  @override
  String toString() {
    return r'paymentReminderByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PaymentReminder?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PaymentReminder?> create(Ref ref) {
    final argument = this.argument as String;
    return paymentReminderById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PaymentReminderByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$paymentReminderByIdHash() =>
    r'e9fc34dc167ff193e76f109e7b110aca56a5f3bd';

final class PaymentReminderByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PaymentReminder?>, String> {
  const PaymentReminderByIdFamily._()
    : super(
        retry: null,
        name: r'paymentReminderByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PaymentReminderByIdProvider call(String id) =>
      PaymentReminderByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'paymentReminderByIdProvider';
}
