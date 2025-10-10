// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upcoming_payments_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(watchUpcomingPayments)
const watchUpcomingPaymentsProvider = WatchUpcomingPaymentsProvider._();

final class WatchUpcomingPaymentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UpcomingPayment>>,
          List<UpcomingPayment>,
          Stream<List<UpcomingPayment>>
        >
    with
        $FutureModifier<List<UpcomingPayment>>,
        $StreamProvider<List<UpcomingPayment>> {
  const WatchUpcomingPaymentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchUpcomingPaymentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchUpcomingPaymentsHash();

  @$internal
  @override
  $StreamProviderElement<List<UpcomingPayment>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<UpcomingPayment>> create(Ref ref) {
    return watchUpcomingPayments(ref);
  }
}

String _$watchUpcomingPaymentsHash() =>
    r'ec49b4ce2ece0991efbce87267b9d550867e666d';

@ProviderFor(watchPaymentReminders)
const watchPaymentRemindersProvider = WatchPaymentRemindersFamily._();

final class WatchPaymentRemindersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PaymentReminder>>,
          List<PaymentReminder>,
          Stream<List<PaymentReminder>>
        >
    with
        $FutureModifier<List<PaymentReminder>>,
        $StreamProvider<List<PaymentReminder>> {
  const WatchPaymentRemindersProvider._({
    required WatchPaymentRemindersFamily super.from,
    required int? super.argument,
  }) : super(
         retry: null,
         name: r'watchPaymentRemindersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchPaymentRemindersHash();

  @override
  String toString() {
    return r'watchPaymentRemindersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PaymentReminder>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PaymentReminder>> create(Ref ref) {
    final argument = this.argument as int?;
    return watchPaymentReminders(ref, limit: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchPaymentRemindersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchPaymentRemindersHash() =>
    r'8612f35e218a7f45e8fc6c876038deaa0d62051e';

final class WatchPaymentRemindersFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PaymentReminder>>, int?> {
  const WatchPaymentRemindersFamily._()
    : super(
        retry: null,
        name: r'watchPaymentRemindersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchPaymentRemindersProvider call({int? limit}) =>
      WatchPaymentRemindersProvider._(argument: limit, from: this);

  @override
  String toString() => r'watchPaymentRemindersProvider';
}
