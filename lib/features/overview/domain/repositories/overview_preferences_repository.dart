import 'package:kopim/features/overview/domain/entities/overview_preferences.dart';

abstract class OverviewPreferencesRepository {
  Future<OverviewPreferences> load();
  Future<void> save(OverviewPreferences preferences);
}
