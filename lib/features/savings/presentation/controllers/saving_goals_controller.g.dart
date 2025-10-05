// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saving_goals_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SavingGoalsController)
const savingGoalsControllerProvider = SavingGoalsControllerProvider._();

final class SavingGoalsControllerProvider
    extends $NotifierProvider<SavingGoalsController, SavingGoalsState> {
  const SavingGoalsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savingGoalsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savingGoalsControllerHash();

  @$internal
  @override
  SavingGoalsController create() => SavingGoalsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavingGoalsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavingGoalsState>(value),
    );
  }
}

String _$savingGoalsControllerHash() =>
    r'4eb7b877971f9576458cebb9efcea4673502c608';

abstract class _$SavingGoalsController extends $Notifier<SavingGoalsState> {
  SavingGoalsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SavingGoalsState, SavingGoalsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SavingGoalsState, SavingGoalsState>,
              SavingGoalsState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
