import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kopim/features/profile/data/cloud_activation_state_repository.dart';
import 'package:kopim/features/profile/domain/entities/cloud_activation_state.dart';

void main() {
  late SharedPreferences sharedPreferences;
  late SharedPrefsCloudActivationStateRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    sharedPreferences = await SharedPreferences.getInstance();
    repository = SharedPrefsCloudActivationStateRepository(
      preferences: Future<SharedPreferences>.value(sharedPreferences),
    );
  });

  test('persists activation state per uid', () async {
    await repository.saveEnabledState(
      uid: 'cloud-user-1',
      scenario: 'enableCloudSync',
      localFingerprint: 'local:empty',
      remoteFingerprint: 'remote:empty|uid:cloud-user-1',
    );

    final CloudActivationState? state = await repository.getStateForUid(
      'cloud-user-1',
    );

    expect(state, isNotNull);
    expect(state!.uid, 'cloud-user-1');
    expect(state.scenario, 'enableCloudSync');
    expect(state.localFingerprint, 'local:empty');
    expect(state.remoteFingerprint, 'remote:empty|uid:cloud-user-1');
    expect(state.version, 1);
  });

  test(
    'returns null for another uid even if one activation flag exists',
    () async {
      await repository.saveEnabledState(
        uid: 'cloud-user-1',
        scenario: 'enableCloudSync',
        localFingerprint: null,
        remoteFingerprint: null,
      );

      final CloudActivationState? state = await repository.getStateForUid(
        'cloud-user-2',
      );

      expect(state, isNull);
    },
  );
}
