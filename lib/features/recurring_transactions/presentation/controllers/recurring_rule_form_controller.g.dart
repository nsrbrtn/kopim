// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_rule_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecurringRuleFormController)
const recurringRuleFormControllerProvider =
    RecurringRuleFormControllerFamily._();

final class RecurringRuleFormControllerProvider
    extends
        $NotifierProvider<RecurringRuleFormController, RecurringRuleFormState> {
  const RecurringRuleFormControllerProvider._({
    required RecurringRuleFormControllerFamily super.from,
    required RecurringRule? super.argument,
  }) : super(
         retry: null,
         name: r'recurringRuleFormControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recurringRuleFormControllerHash();

  @override
  String toString() {
    return r'recurringRuleFormControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RecurringRuleFormController create() => RecurringRuleFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecurringRuleFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecurringRuleFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RecurringRuleFormControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recurringRuleFormControllerHash() =>
    r'd20942a348907659efadb858f313874fd88cdfc8';

final class RecurringRuleFormControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          RecurringRuleFormController,
          RecurringRuleFormState,
          RecurringRuleFormState,
          RecurringRuleFormState,
          RecurringRule?
        > {
  const RecurringRuleFormControllerFamily._()
    : super(
        retry: null,
        name: r'recurringRuleFormControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RecurringRuleFormControllerProvider call({RecurringRule? initialRule}) =>
      RecurringRuleFormControllerProvider._(argument: initialRule, from: this);

  @override
  String toString() => r'recurringRuleFormControllerProvider';
}

abstract class _$RecurringRuleFormController
    extends $Notifier<RecurringRuleFormState> {
  late final _$args = ref.$arg as RecurringRule?;
  RecurringRule? get initialRule => _$args;

  RecurringRuleFormState build({RecurringRule? initialRule});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(initialRule: _$args);
    final ref =
        this.ref as $Ref<RecurringRuleFormState, RecurringRuleFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RecurringRuleFormState, RecurringRuleFormState>,
              RecurringRuleFormState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
