// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exact_alarm_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExactAlarmController)
const exactAlarmControllerProvider = ExactAlarmControllerProvider._();

final class ExactAlarmControllerProvider
    extends $AsyncNotifierProvider<ExactAlarmController, bool> {
  const ExactAlarmControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exactAlarmControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exactAlarmControllerHash();

  @$internal
  @override
  ExactAlarmController create() => ExactAlarmController();
}

String _$exactAlarmControllerHash() =>
    r'fb89215db4989147173d4bbc3d1feafb2265bc3d';

abstract class _$ExactAlarmController extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
