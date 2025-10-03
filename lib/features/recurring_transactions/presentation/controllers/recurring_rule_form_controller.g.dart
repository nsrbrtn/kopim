// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_rule_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecurringRuleFormController)
const recurringRuleFormControllerProvider =
    RecurringRuleFormControllerProvider._();

final class RecurringRuleFormControllerProvider
    extends
        $NotifierProvider<RecurringRuleFormController, RecurringRuleFormState> {
  const RecurringRuleFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringRuleFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringRuleFormControllerHash();

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
}

String _$recurringRuleFormControllerHash() =>
    r'921d9cbc31c55689e68333dc0e6b550d368d35c5';

abstract class _$RecurringRuleFormController
    extends $Notifier<RecurringRuleFormState> {
  RecurringRuleFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
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
