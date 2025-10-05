// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_goal_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EditGoalController)
const editGoalControllerProvider = EditGoalControllerFamily._();

final class EditGoalControllerProvider
    extends $NotifierProvider<EditGoalController, EditGoalState> {
  const EditGoalControllerProvider._({
    required EditGoalControllerFamily super.from,
    required SavingGoal? super.argument,
  }) : super(
         retry: null,
         name: r'editGoalControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$editGoalControllerHash();

  @override
  String toString() {
    return r'editGoalControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EditGoalController create() => EditGoalController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EditGoalState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EditGoalState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EditGoalControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editGoalControllerHash() =>
    r'2f9c5e5382f3b0039332c2ebe053b0129f3dd4d9';

final class EditGoalControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          EditGoalController,
          EditGoalState,
          EditGoalState,
          EditGoalState,
          SavingGoal?
        > {
  const EditGoalControllerFamily._()
    : super(
        retry: null,
        name: r'editGoalControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EditGoalControllerProvider call(SavingGoal? goal) =>
      EditGoalControllerProvider._(argument: goal, from: this);

  @override
  String toString() => r'editGoalControllerProvider';
}

abstract class _$EditGoalController extends $Notifier<EditGoalState> {
  late final _$args = ref.$arg as SavingGoal?;
  SavingGoal? get goal => _$args;

  EditGoalState build(SavingGoal? goal);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<EditGoalState, EditGoalState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EditGoalState, EditGoalState>,
              EditGoalState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
