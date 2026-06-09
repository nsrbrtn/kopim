// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upcoming_notifications_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UpcomingNotificationsController)
final upcomingNotificationsControllerProvider =
    UpcomingNotificationsControllerProvider._();

final class UpcomingNotificationsControllerProvider
    extends $AsyncNotifierProvider<UpcomingNotificationsController, void> {
  UpcomingNotificationsControllerProvider._()
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
    r'1bbcddc6ec70f5e895e2bbfe2c79933cf56276b3';

abstract class _$UpcomingNotificationsController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
