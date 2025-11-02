// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_user_data_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExportUserDataController)
const exportUserDataControllerProvider = ExportUserDataControllerProvider._();

final class ExportUserDataControllerProvider
    extends
        $NotifierProvider<
          ExportUserDataController,
          AsyncValue<ExportFileSaveResult?>
        > {
  const ExportUserDataControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportUserDataControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportUserDataControllerHash();

  @$internal
  @override
  ExportUserDataController create() => ExportUserDataController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<ExportFileSaveResult?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<ExportFileSaveResult?>>(
        value,
      ),
    );
  }
}

String _$exportUserDataControllerHash() =>
    r'20b36ca22b2da2e95d25d01e5be85428b3cf4613';

abstract class _$ExportUserDataController
    extends $Notifier<AsyncValue<ExportFileSaveResult?>> {
  AsyncValue<ExportFileSaveResult?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<ExportFileSaveResult?>,
              AsyncValue<ExportFileSaveResult?>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ExportFileSaveResult?>,
                AsyncValue<ExportFileSaveResult?>
              >,
              AsyncValue<ExportFileSaveResult?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
