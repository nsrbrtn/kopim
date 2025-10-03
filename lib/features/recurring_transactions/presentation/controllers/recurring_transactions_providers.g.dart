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
