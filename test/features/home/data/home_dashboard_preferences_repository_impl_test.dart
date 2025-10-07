import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/home/data/repositories/home_dashboard_preferences_repository_impl.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeDashboardPreferencesRepositoryImpl', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('returns defaults when preferences are missing', () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final HomeDashboardPreferencesRepositoryImpl repository =
          HomeDashboardPreferencesRepositoryImpl(
            preferences: Future<SharedPreferences>.value(prefs),
          );

      final HomeDashboardPreferences result = await repository.load();

      expect(result, const HomeDashboardPreferences());
    });

    test('persists and restores preferences', () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final HomeDashboardPreferencesRepositoryImpl repository =
          HomeDashboardPreferencesRepositoryImpl(
            preferences: Future<SharedPreferences>.value(prefs),
          );
      const HomeDashboardPreferences expected = HomeDashboardPreferences(
        showGamificationWidget: true,
        showBudgetWidget: true,
        budgetId: 'budget-1',
      );

      await repository.save(expected);
      final HomeDashboardPreferences loaded = await repository.load();

      expect(loaded, expected);
    });
  });
}
