// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_mode_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DataModeController)
final dataModeControllerProvider = DataModeControllerProvider._();

final class DataModeControllerProvider
    extends $AsyncNotifierProvider<DataModeController, DataModeState> {
  DataModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataModeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataModeControllerHash();

  @$internal
  @override
  DataModeController create() => DataModeController();
}

String _$dataModeControllerHash() =>
    r'84a4a25cb8ac275098b5027b68d7a7dd66acefa4';

abstract class _$DataModeController extends $AsyncNotifier<DataModeState> {
  FutureOr<DataModeState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DataModeState>, DataModeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DataModeState>, DataModeState>,
              AsyncValue<DataModeState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
