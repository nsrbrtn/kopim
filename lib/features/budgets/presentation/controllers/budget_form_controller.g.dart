// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BudgetFormController)
final budgetFormControllerProvider = BudgetFormControllerFamily._();

final class BudgetFormControllerProvider
    extends $NotifierProvider<BudgetFormController, BudgetFormState> {
  BudgetFormControllerProvider._({
    required BudgetFormControllerFamily super.from,
    required BudgetFormParams super.argument,
  }) : super(
         retry: null,
         name: r'budgetFormControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$budgetFormControllerHash();

  @override
  String toString() {
    return r'budgetFormControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BudgetFormController create() => BudgetFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetFormControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$budgetFormControllerHash() =>
    r'bd973ef40f3fd7439cb6f78e342e2febc7a2419b';

final class BudgetFormControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          BudgetFormController,
          BudgetFormState,
          BudgetFormState,
          BudgetFormState,
          BudgetFormParams
        > {
  BudgetFormControllerFamily._()
    : super(
        retry: null,
        name: r'budgetFormControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BudgetFormControllerProvider call({
    BudgetFormParams params = const BudgetFormParams(),
  }) => BudgetFormControllerProvider._(argument: params, from: this);

  @override
  String toString() => r'budgetFormControllerProvider';
}

abstract class _$BudgetFormController extends $Notifier<BudgetFormState> {
  late final _$args = ref.$arg as BudgetFormParams;
  BudgetFormParams get params => _$args;

  BudgetFormState build({BudgetFormParams params = const BudgetFormParams()});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BudgetFormState, BudgetFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BudgetFormState, BudgetFormState>,
              BudgetFormState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(params: _$args));
  }
}
