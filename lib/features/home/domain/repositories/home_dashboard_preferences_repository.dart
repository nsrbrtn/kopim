import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';

/// Контракт репозитория настроек домашнего экрана.
abstract class HomeDashboardPreferencesRepository {
  /// Загружает сохранённые предпочтения или возвращает значения по умолчанию.
  Future<HomeDashboardPreferences> load();

  /// Сохраняет предпочтения домашнего экрана.
  Future<void> save(HomeDashboardPreferences preferences);
}
