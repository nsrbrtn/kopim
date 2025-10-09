// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transactions_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recurringRules)
const recurringRulesProvider = RecurringRulesProvider._();

final class RecurringRulesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecurringRule>>,
          List<RecurringRule>,
          Stream<List<RecurringRule>>
        >
    with
        $FutureModifier<List<RecurringRule>>,
        $StreamProvider<List<RecurringRule>> {
  const RecurringRulesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringRulesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringRulesHash();

  @$internal
  @override
  $StreamProviderElement<List<RecurringRule>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RecurringRule>> create(Ref ref) {
    return recurringRules(ref);
  }
}

String _$recurringRulesHash() => r'5fa30fa65c7e7c733773fdbf42242d31e71bb6a4';

@ProviderFor(recurringRuleById)
const recurringRuleByIdProvider = RecurringRuleByIdFamily._();

final class RecurringRuleByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<RecurringRule?>,
          AsyncValue<RecurringRule?>,
          AsyncValue<RecurringRule?>
        >
    with $Provider<AsyncValue<RecurringRule?>> {
  const RecurringRuleByIdProvider._({
    required RecurringRuleByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'recurringRuleByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recurringRuleByIdHash();

  @override
  String toString() {
    return r'recurringRuleByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<RecurringRule?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<RecurringRule?> create(Ref ref) {
    final argument = this.argument as String;
    return recurringRuleById(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<RecurringRule?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<RecurringRule?>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RecurringRuleByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recurringRuleByIdHash() => r'9455e6c7dba20726bdc854c6a78944f25e901fbe';

final class RecurringRuleByIdFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<RecurringRule?>, String> {
  const RecurringRuleByIdFamily._()
    : super(
        retry: null,
        name: r'recurringRuleByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RecurringRuleByIdProvider call(String id) =>
      RecurringRuleByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'recurringRuleByIdProvider';
}

@ProviderFor(upcomingRecurringOccurrences)
const upcomingRecurringOccurrencesProvider =
    UpcomingRecurringOccurrencesFamily._();

final class UpcomingRecurringOccurrencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecurringOccurrence>>,
          List<RecurringOccurrence>,
          Stream<List<RecurringOccurrence>>
        >
    with
        $FutureModifier<List<RecurringOccurrence>>,
        $StreamProvider<List<RecurringOccurrence>> {
  const UpcomingRecurringOccurrencesProvider._({
    required UpcomingRecurringOccurrencesFamily super.from,
    required ({DateTime? from, DateTime? to}) super.argument,
  }) : super(
         retry: null,
         name: r'upcomingRecurringOccurrencesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$upcomingRecurringOccurrencesHash();

  @override
  String toString() {
    return r'upcomingRecurringOccurrencesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<RecurringOccurrence>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RecurringOccurrence>> create(Ref ref) {
    final argument = this.argument as ({DateTime? from, DateTime? to});
    return upcomingRecurringOccurrences(
      ref,
      from: argument.from,
      to: argument.to,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UpcomingRecurringOccurrencesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$upcomingRecurringOccurrencesHash() =>
    r'564a4250158c7c3912ff10ecd00333d05cd12ecc';

final class UpcomingRecurringOccurrencesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<RecurringOccurrence>>,
          ({DateTime? from, DateTime? to})
        > {
  const UpcomingRecurringOccurrencesFamily._()
    : super(
        retry: null,
        name: r'upcomingRecurringOccurrencesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UpcomingRecurringOccurrencesProvider call({DateTime? from, DateTime? to}) =>
      UpcomingRecurringOccurrencesProvider._(
        argument: (from: from, to: to),
        from: this,
      );

  @override
  String toString() => r'upcomingRecurringOccurrencesProvider';
}
