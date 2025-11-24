import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/events/profile_domain_event.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_event_recorder.g.dart';

class ProfileEventRecorder {
  ProfileEventRecorder({
    required AnalyticsService analyticsService,
    required LoggerService loggerService,
  }) : _analytics = analyticsService,
       _logger = loggerService;

  final AnalyticsService _analytics;
  final LoggerService _logger;

  Future<void> record(Iterable<ProfileDomainEvent> events) async {
    for (final ProfileDomainEvent event in events) {
      await event.map(
        profileUpdated: (ProfileUpdatedEvent value) =>
            _handleProfileUpdated(value.profile),
        avatarUpdated: (ProfileAvatarUpdatedEvent value) =>
            _handleAvatarUpdated(value),
        avatarProcessingWarning: (ProfileAvatarProcessingWarningEvent value) =>
            _handleAvatarProcessingWarning(value.message),
        levelIncreased: (ProfileLevelIncreasedEvent value) =>
            _handleLevelIncreased(value),
        progressSyncFailed: (ProfileProgressSyncFailedEvent value) =>
            _handleProgressSyncFailed(value),
      );
    }
  }

  Future<void> _handleProfileUpdated(Profile profile) async {
    try {
      await _analytics.logEvent('profile_updated', <String, dynamic>{
        'uid': profile.uid,
        'currency': profile.currency.name,
        'locale': profile.locale,
        'has_name': profile.name.isNotEmpty,
      });
    } on Object catch (error, stackTrace) {
      _analytics.reportError(error, stackTrace);
    }
  }

  Future<void> _handleAvatarUpdated(ProfileAvatarUpdatedEvent event) async {
    try {
      _logger.logInfo(
        'Avatar updated: uid=${event.uid}, source=${event.source.name}, '
        'sizeBytes=${event.sizeBytes}, mode=${event.offlineOnly ? 'offline' : 'remote'}',
      );
      await _analytics.logEvent('avatar_updated', <String, Object?>{
        'uid': event.uid,
        'source': event.source.name,
        'size_kb': (event.sizeBytes / 1024).round(),
        'mode': event.offlineOnly ? 'offline' : 'remote',
      });
    } on Object catch (error, stackTrace) {
      _analytics.reportError(error, stackTrace);
    }
  }

  Future<void> _handleLevelIncreased(ProfileLevelIncreasedEvent event) async {
    try {
      await _analytics.logEvent('level_up', <String, Object?>{
        'old_level': event.previousLevel,
        'new_level': event.newLevel,
        'total_tx': event.totalTransactions,
      });
    } on Object catch (error, stackTrace) {
      _analytics.reportError(error, stackTrace);
    }
  }

  Future<void> _handleAvatarProcessingWarning(String message) async {
    _logger.logError(message);
  }

  Future<void> _handleProgressSyncFailed(
    ProfileProgressSyncFailedEvent event,
  ) async {
    _logger.logError('Failed to sync progress for ${event.uid}', event.error);
    _logger.logError('Progress sync stack: ${event.stackTrace}');
  }
}

@riverpod
ProfileEventRecorder profileEventRecorder(Ref ref) {
  return ProfileEventRecorder(
    analyticsService: ref.watch(analyticsServiceProvider),
    loggerService: ref.watch(loggerServiceProvider),
  );
}
