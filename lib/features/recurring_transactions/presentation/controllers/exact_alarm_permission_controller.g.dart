// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exact_alarm_permission_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExactAlarmPermissionController)
const exactAlarmPermissionControllerProvider =
    ExactAlarmPermissionControllerProvider._();

final class ExactAlarmPermissionControllerProvider
    extends $AsyncNotifierProvider<ExactAlarmPermissionController, bool> {
  const ExactAlarmPermissionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exactAlarmPermissionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exactAlarmPermissionControllerHash();

  @$internal
  @override
  ExactAlarmPermissionController create() => ExactAlarmPermissionController();
}

String _$exactAlarmPermissionControllerHash() =>
    r'432710e7fb082e83b5c407207a7ca1e72faa6779';

abstract class _$ExactAlarmPermissionController extends $AsyncNotifier<bool> {
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
