import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/getting_started/data/repositories/getting_started_preferences_repository_impl.dart';
import 'package:kopim/features/getting_started/domain/entities/getting_started_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GettingStartedPreferencesRepositoryImpl', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('возвращает значения по умолчанию при отсутствии состояния', () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final GettingStartedPreferencesRepositoryImpl repository =
          GettingStartedPreferencesRepositoryImpl(
            preferences: Future<SharedPreferences>.value(prefs),
          );

      final GettingStartedPreferences loaded = await repository.load();

      expect(loaded.hasActivated, isFalse);
      expect(loaded.isHidden, isFalse);
    });

    test('сохраняет и восстанавливает локальное состояние', () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final GettingStartedPreferencesRepositoryImpl repository =
          GettingStartedPreferencesRepositoryImpl(
            preferences: Future<SharedPreferences>.value(prefs),
          );
      const GettingStartedPreferences expected = GettingStartedPreferences(
        hasActivated: true,
        isHidden: true,
      );

      await repository.save(expected);
      final GettingStartedPreferences loaded = await repository.load();

      expect(loaded.hasActivated, isTrue);
      expect(loaded.isHidden, isTrue);
    });
  });
}
