// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(creditSchedule)
const creditScheduleProvider = CreditScheduleFamily._();

final class CreditScheduleProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CreditPaymentScheduleEntity>>,
          List<CreditPaymentScheduleEntity>,
          Stream<List<CreditPaymentScheduleEntity>>
        >
    with
        $FutureModifier<List<CreditPaymentScheduleEntity>>,
        $StreamProvider<List<CreditPaymentScheduleEntity>> {
  const CreditScheduleProvider._({
    required CreditScheduleFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'creditScheduleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$creditScheduleHash();

  @override
  String toString() {
    return r'creditScheduleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<CreditPaymentScheduleEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CreditPaymentScheduleEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return creditSchedule(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CreditScheduleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$creditScheduleHash() => r'255772f2e5943fd7a0c48756fde3fe919849a5e9';

final class CreditScheduleFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<CreditPaymentScheduleEntity>>,
          String
        > {
  const CreditScheduleFamily._()
    : super(
        retry: null,
        name: r'creditScheduleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CreditScheduleProvider call(String creditId) =>
      CreditScheduleProvider._(argument: creditId, from: this);

  @override
  String toString() => r'creditScheduleProvider';
}

@ProviderFor(nextUpcomingPayment)
const nextUpcomingPaymentProvider = NextUpcomingPaymentFamily._();

final class NextUpcomingPaymentProvider
    extends
        $FunctionalProvider<
          AsyncValue<CreditPaymentScheduleEntity?>,
          CreditPaymentScheduleEntity?,
          FutureOr<CreditPaymentScheduleEntity?>
        >
    with
        $FutureModifier<CreditPaymentScheduleEntity?>,
        $FutureProvider<CreditPaymentScheduleEntity?> {
  const NextUpcomingPaymentProvider._({
    required NextUpcomingPaymentFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'nextUpcomingPaymentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nextUpcomingPaymentHash();

  @override
  String toString() {
    return r'nextUpcomingPaymentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CreditPaymentScheduleEntity?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CreditPaymentScheduleEntity?> create(Ref ref) {
    final argument = this.argument as String;
    return nextUpcomingPayment(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NextUpcomingPaymentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nextUpcomingPaymentHash() =>
    r'2eb99e3177fb461584b5045588fa17fadb133e86';

final class NextUpcomingPaymentFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<CreditPaymentScheduleEntity?>,
          String
        > {
  const NextUpcomingPaymentFamily._()
    : super(
        retry: null,
        name: r'nextUpcomingPaymentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NextUpcomingPaymentProvider call(String creditId) =>
      NextUpcomingPaymentProvider._(argument: creditId, from: this);

  @override
  String toString() => r'nextUpcomingPaymentProvider';
}
