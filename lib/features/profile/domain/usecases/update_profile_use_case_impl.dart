import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/repositories/profile_repository.dart';
import 'package:kopim/features/profile/domain/usecases/update_profile_use_case.dart';

/// Use case that persists profile updates locally and forwards analytics events.
class UpdateProfileUseCaseImpl implements UpdateProfileUseCase {
  UpdateProfileUseCaseImpl({
    required ProfileRepository repository,
    required AnalyticsService analyticsService,
  }) : _repository = repository,
       _analyticsService = analyticsService;

  final ProfileRepository _repository;
  final AnalyticsService _analyticsService;

  @override
  Future<Profile> call(Profile profile) async {
    final Profile updated = await _repository.updateProfile(profile);
    await _logAnalytics(updated);
    return updated;
  }

  Future<void> _logAnalytics(Profile profile) async {
    try {
      await _analyticsService.logEvent('profile_updated', <String, dynamic>{
        'uid': profile.uid,
        'currency': profile.currency.name,
        'locale': profile.locale,
        'has_name': profile.name.isNotEmpty,
      });
    } on Object catch (error, stackTrace) {
      _analyticsService.reportError(error, stackTrace);
    }
  }
}
