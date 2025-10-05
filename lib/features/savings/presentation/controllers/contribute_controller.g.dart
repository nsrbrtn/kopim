// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribute_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ContributeController)
const contributeControllerProvider = ContributeControllerFamily._();

final class ContributeControllerProvider
    extends $NotifierProvider<ContributeController, ContributeState> {
  const ContributeControllerProvider._({
    required ContributeControllerFamily super.from,
    required SavingGoal super.argument,
  }) : super(
         retry: null,
         name: r'contributeControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$contributeControllerHash();

  @override
  String toString() {
    return r'contributeControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ContributeController create() => ContributeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContributeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContributeState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ContributeControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$contributeControllerHash() =>
    r'7475dfdadea099dbeb75246f2bade04103e16ff6';

final class ContributeControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ContributeController,
          ContributeState,
          ContributeState,
          ContributeState,
          SavingGoal
        > {
  const ContributeControllerFamily._()
    : super(
        retry: null,
        name: r'contributeControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ContributeControllerProvider call(SavingGoal goal) =>
      ContributeControllerProvider._(argument: goal, from: this);

  @override
  String toString() => r'contributeControllerProvider';
}

abstract class _$ContributeController extends $Notifier<ContributeState> {
  late final _$args = ref.$arg as SavingGoal;
  SavingGoal get goal => _$args;

  ContributeState build(SavingGoal goal);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<ContributeState, ContributeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ContributeState, ContributeState>,
              ContributeState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
