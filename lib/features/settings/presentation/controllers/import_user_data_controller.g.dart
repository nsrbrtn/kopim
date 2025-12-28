// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_user_data_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ImportUserDataController)
const importUserDataControllerProvider = ImportUserDataControllerProvider._();

final class ImportUserDataControllerProvider
    extends
        $NotifierProvider<
          ImportUserDataController,
          AsyncValue<ImportUserDataResult?>
        > {
  const ImportUserDataControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importUserDataControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importUserDataControllerHash();

  @$internal
  @override
  ImportUserDataController create() => ImportUserDataController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<ImportUserDataResult?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<ImportUserDataResult?>>(
        value,
      ),
    );
  }
}

String _$importUserDataControllerHash() =>
    r'4bf935186c586d8781e9588d29fbb518b373beda';

abstract class _$ImportUserDataController
    extends $Notifier<AsyncValue<ImportUserDataResult?>> {
  AsyncValue<ImportUserDataResult?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<ImportUserDataResult?>,
              AsyncValue<ImportUserDataResult?>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ImportUserDataResult?>,
                AsyncValue<ImportUserDataResult?>
              >,
              AsyncValue<ImportUserDataResult?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
