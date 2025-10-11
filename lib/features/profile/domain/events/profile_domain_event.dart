import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/usecases/update_profile_avatar_use_case.dart';

part 'profile_domain_event.freezed.dart';

@freezed
class ProfileDomainEvent with _$ProfileDomainEvent {
  const factory ProfileDomainEvent.profileUpdated({required Profile profile}) =
      ProfileUpdatedEvent;

  const factory ProfileDomainEvent.avatarUpdated({
    required String uid,
    required AvatarImageSource source,
    required int sizeBytes,
    required bool offlineOnly,
  }) = ProfileAvatarUpdatedEvent;

  const factory ProfileDomainEvent.avatarProcessingWarning({
    required String message,
  }) = ProfileAvatarProcessingWarningEvent;

  const factory ProfileDomainEvent.levelIncreased({
    required int previousLevel,
    required int newLevel,
    required int totalTransactions,
  }) = ProfileLevelIncreasedEvent;

  const factory ProfileDomainEvent.progressSyncFailed({
    required String uid,
    required Object error,
    required StackTrace stackTrace,
  }) = ProfileProgressSyncFailedEvent;
}
