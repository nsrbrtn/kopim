import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/events/profile_domain_event.dart';
import 'package:kopim/features/profile/domain/models/profile_command_result.dart';
import 'package:kopim/features/profile/domain/repositories/profile_repository.dart';
import 'package:kopim/features/profile/domain/usecases/update_profile_use_case_impl.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late _MockProfileRepository repository;
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
        locale: 'ru',
        updatedAt: DateTime.utc(2024, 1, 1),
      ),
    );
  });

  setUp(() {
    repository = _MockProfileRepository();
    useCase = UpdateProfileUseCaseImpl(repository: repository);
  });

  test('persists profile and emits profile updated event', () async {
    when(
      () => repository.updateProfile(any()),
    ).thenAnswer((_) async => sampleProfile);

    final ProfileCommandResult<Profile> result = await useCase(sampleProfile);

    expect(result.value, equals(sampleProfile));
    verify(() => repository.updateProfile(sampleProfile)).called(1);
    final List<ProfileDomainEvent> events = result.events;
    expect(events, hasLength(1));
    final ProfileDomainEvent event = events.first;
    expect(event, isA<ProfileUpdatedEvent>());
    event.map(
      profileUpdated: (ProfileUpdatedEvent value) {
        expect(value.profile, equals(sampleProfile));
      },
      avatarUpdated: (_) => fail('Unexpected avatar event'),
      avatarProcessingWarning: (_) => fail('Unexpected warning event'),
      levelIncreased: (_) => fail('Unexpected level event'),
      progressSyncFailed: (_) => fail('Unexpected sync failure'),
    );
  });
}
