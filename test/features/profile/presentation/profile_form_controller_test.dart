import 'package:kopim/core/di/injectors.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/events/profile_domain_event.dart';
import 'package:kopim/features/profile/domain/models/profile_command_result.dart';
import 'package:kopim/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:kopim/features/profile/presentation/services/profile_event_recorder.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_form_controller.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/src/framework.dart';

class _MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

class _MockProfileEventRecorder extends Mock implements ProfileEventRecorder {}

void main() {
  late ProviderContainer container;
  late _MockUpdateProfileUseCase updateUseCase;
  late _MockProfileEventRecorder eventRecorder;

  const String uid = 'user-form';
  final Profile profile = Profile(
    uid: uid,
    name: 'Initial',
    currency: ProfileCurrency.rub,
    locale: 'ru',
    updatedAt: DateTime.utc(2024, 1, 1),
  );
  final ProfileFormParams params = ProfileFormParams(
    uid: uid,
    profile: profile,
  );

  setUpAll(() {
    registerFallbackValue(
      Profile(
        uid: 'fallback',
        name: '',
        currency: ProfileCurrency.rub,
        locale: 'ru',
        updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
  });

  setUp(() {
    updateUseCase = _MockUpdateProfileUseCase();
    eventRecorder = _MockProfileEventRecorder();
    when(() => eventRecorder.record(any())).thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: <Override>[
        updateProfileUseCaseProvider.overrideWithValue(updateUseCase),
        profileEventRecorderProvider.overrideWithValue(eventRecorder),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state reflects provided profile', () {
    final ProfileFormState state = container.read(
      profileFormControllerProvider(params),
    );

    expect(state.name, equals('Initial'));
    expect(state.currency, equals(ProfileCurrency.rub));
    expect(state.locale, equals('ru'));
    expect(state.hasChanges, isFalse);
  });

  test('updates fields and clears error', () {
    final ProfileFormController notifier = container.read(
      profileFormControllerProvider(params).notifier,
    );

    notifier.updateName('Alice');
    notifier.updateCurrency(ProfileCurrency.eur);
    notifier.updateLocale('de');

    final ProfileFormState state = container.read(
      profileFormControllerProvider(params),
    );
    expect(state.name, equals('Alice'));
    expect(state.currency, equals(ProfileCurrency.eur));
    expect(state.locale, equals('de'));
    expect(state.hasChanges, isTrue);
  });

  test('submit updates profile and resets changes', () async {
    when(() => updateUseCase.call(any())).thenAnswer((
      Invocation invocation,
    ) async {
      final Profile submitted = invocation.positionalArguments.first as Profile;
      return ProfileCommandResult<Profile>(
        value: submitted,
        events: <ProfileDomainEvent>[
          ProfileDomainEvent.profileUpdated(profile: submitted),
        ],
      );
    });

    final ProfileFormController notifier = container.read(
      profileFormControllerProvider(params).notifier,
    );
    notifier.updateName('Alice');

    await notifier.submit();

    final ProfileFormState state = container.read(
      profileFormControllerProvider(params),
    );
    expect(state.isSaving, isFalse);
    expect(state.hasChanges, isFalse);
    verify(() => updateUseCase.call(any())).called(1);
    verify(() => eventRecorder.record(any())).called(1);
  });

  test('submit handles errors', () async {
    when(
      () => updateUseCase.call(any()),
    ).thenThrow(Exception('failure updating profile'));

    final ProfileFormController notifier = container.read(
      profileFormControllerProvider(params).notifier,
    );

    await notifier.submit();

    final ProfileFormState state = container.read(
      profileFormControllerProvider(params),
    );
    expect(state.isSaving, isFalse);
    expect(state.errorMessage, contains('failure updating profile'));
    verifyNever(() => eventRecorder.record(any()));
  });
}
