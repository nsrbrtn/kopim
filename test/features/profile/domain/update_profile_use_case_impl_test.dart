import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/repositories/profile_repository.dart';
import 'package:kopim/features/profile/domain/usecases/update_profile_use_case_impl.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late _MockProfileRepository repository;
  late _MockAnalyticsService analytics;
  late UpdateProfileUseCaseImpl useCase;

  final Profile sampleProfile = Profile(
    uid: 'user-1',
    name: 'Alice',
    currency: ProfileCurrency.eur,
    locale: 'de',
    updatedAt: DateTime.utc(2024, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(
      Profile(
        uid: 'fallback',
        name: '',
        currency: ProfileCurrency.rub,
        locale: 'en',
        updatedAt: DateTime.utc(2024, 1, 1),
      ),
    );
    registerFallbackValue(StackTrace.empty);
  });

  setUp(() {
    repository = _MockProfileRepository();
    analytics = _MockAnalyticsService();
    useCase = UpdateProfileUseCaseImpl(
      repository: repository,
      analyticsService: analytics,
    );
  });

  test('persists profile and logs analytics event', () async {
    when(
      () => repository.updateProfile(any()),
    ).thenAnswer((_) async => sampleProfile);
    when(() => analytics.logEvent(any(), any())).thenAnswer((_) async {});

    final Profile result = await useCase(sampleProfile);

    expect(result, equals(sampleProfile));
    verify(() => repository.updateProfile(sampleProfile)).called(1);
    verify(
      () => analytics.logEvent('profile_updated', <String, dynamic>{
        'uid': sampleProfile.uid,
        'currency': sampleProfile.currency.name,
        'locale': sampleProfile.locale,
        'has_name': sampleProfile.name.isNotEmpty,
      }),
    ).called(1);
    verifyNever(() => analytics.reportError(any(), any()));
  });

  test('reports analytics failures without throwing', () async {
    final Exception failure = Exception('analytics down');
    when(
      () => repository.updateProfile(any()),
    ).thenAnswer((_) async => sampleProfile);
    when(() => analytics.logEvent(any(), any())).thenThrow(failure);
    when(() => analytics.reportError(any(), any())).thenAnswer((_) {});

    final Profile result = await useCase(sampleProfile);

    expect(result, equals(sampleProfile));
    verify(() => analytics.logEvent('profile_updated', any())).called(1);
    verify(() => analytics.reportError(failure, any())).called(1);
  });
}
