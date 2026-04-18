import 'package:kopim/features/getting_started/domain/entities/getting_started_preferences.dart';

abstract class GettingStartedPreferencesRepository {
  Future<GettingStartedPreferences> load();

  Future<void> save(GettingStartedPreferences preferences);
}
