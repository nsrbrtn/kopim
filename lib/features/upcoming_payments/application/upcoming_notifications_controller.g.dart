// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upcoming_notifications_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UpcomingNotificationsController)
const upcomingNotificationsControllerProvider =
    UpcomingNotificationsControllerProvider._();

final class UpcomingNotificationsControllerProvider
    extends $AsyncNotifierProvider<UpcomingNotificationsController, void> {
  const UpcomingNotificationsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upcomingNotificationsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upcomingNotificationsControllerHash();

  @$internal
  @override
  UpcomingNotificationsController create() => UpcomingNotificationsController();
}

String _$upcomingNotificationsControllerHash() =>
    r'3335bc3a7c74aa68a9caefb40cab1af1054ba7f0';

abstract class _$UpcomingNotificationsController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
