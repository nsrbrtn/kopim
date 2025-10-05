// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saving_goals_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(goalsStream)
const goalsStreamProvider = GoalsStreamProvider._();

final class GoalsStreamProvider
    extends
        $FunctionalProvider<
          List<SavingGoal>,
          List<SavingGoal>,
          List<SavingGoal>
        >
    with $Provider<List<SavingGoal>> {
  const GoalsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalsStreamHash();

  @$internal
  @override
  $ProviderElement<List<SavingGoal>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<SavingGoal> create(Ref ref) {
    return goalsStream(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SavingGoal> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SavingGoal>>(value),
    );
  }
}

String _$goalsStreamHash() => r'829d8f06c7af6efeebd04e0fbb5c8c6f2071748a';
