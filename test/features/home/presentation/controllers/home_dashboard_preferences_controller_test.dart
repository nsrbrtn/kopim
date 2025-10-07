import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/features/home/domain/repositories/home_dashboard_preferences_repository.dart';
import 'package:kopim/features/home/presentation/controllers/home_dashboard_preferences_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _FakeRepository implements HomeDashboardPreferencesRepository {
  HomeDashboardPreferences stored = const HomeDashboardPreferences();
  HomeDashboardPreferences? lastSaved;

  @override
  Future<HomeDashboardPreferences> load() async {
    return stored;
  }

  @override
  Future<void> save(HomeDashboardPreferences preferences) async {
    lastSaved = preferences;
    stored = preferences;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeDashboardPreferencesController', () {
    late _FakeRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = _FakeRepository();
      container = ProviderContainer(
        // ignore: always_specify_types
        overrides: [
          homeDashboardPreferencesRepositoryProvider.overrideWithValue(
            repository,
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('loads preferences on first read', () async {
      repository.stored = const HomeDashboardPreferences(
        showGamificationWidget: true,
        showRecurringWidget: true,
      );

      final HomeDashboardPreferences result = await container.read(
        homeDashboardPreferencesControllerProvider.future,
      );

      expect(result.showGamificationWidget, isTrue);
      expect(result.showRecurringWidget, isTrue);
    });

    test('setShowGamification updates state and saves', () async {
      await container.read(homeDashboardPreferencesControllerProvider.future);
      await container
          .read(homeDashboardPreferencesControllerProvider.notifier)
          .setShowGamification(true);

      final HomeDashboardPreferences? state = container
          .read(homeDashboardPreferencesControllerProvider)
          .value;

      expect(state?.showGamificationWidget, isTrue);
      expect(repository.lastSaved?.showGamificationWidget, isTrue);
    });

    test('setShowRecurring updates state and saves', () async {
      await container.read(homeDashboardPreferencesControllerProvider.future);

      await container
          .read(homeDashboardPreferencesControllerProvider.notifier)
          .setShowRecurring(true);

      final HomeDashboardPreferences? state = container
          .read(homeDashboardPreferencesControllerProvider)
          .value;

      expect(state?.showRecurringWidget, isTrue);
      expect(repository.lastSaved?.showRecurringWidget, isTrue);
    });

    test(
      'setShowBudget toggles flag and clears budget when disabled',
      () async {
        repository.stored = const HomeDashboardPreferences(
          showBudgetWidget: true,
          budgetId: 'budget-1',
        );
        await container.read(homeDashboardPreferencesControllerProvider.future);

        await container
            .read(homeDashboardPreferencesControllerProvider.notifier)
            .setShowBudget(false);

        final HomeDashboardPreferences? state = container
            .read(homeDashboardPreferencesControllerProvider)
            .value;

        expect(state?.showBudgetWidget, isFalse);
        expect(state?.budgetId, isNull);
        expect(repository.lastSaved?.showBudgetWidget, isFalse);
        expect(repository.lastSaved?.budgetId, isNull);
      },
    );

    test('setBudgetId stores id without altering toggles', () async {
      await container.read(homeDashboardPreferencesControllerProvider.future);

      await container
          .read(homeDashboardPreferencesControllerProvider.notifier)
          .setBudgetId('budget-42');

      final HomeDashboardPreferences? state = container
          .read(homeDashboardPreferencesControllerProvider)
          .value;

      expect(state?.budgetId, 'budget-42');
      expect(state?.showBudgetWidget, isFalse);
      expect(repository.lastSaved?.budgetId, 'budget-42');
    });
  });
}
