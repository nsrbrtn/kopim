import '../app_theme_mode.dart';

/// Контракт репозитория настроек темы.
abstract class ThemeRepository {
  Future<AppThemeMode> loadThemeMode();

  Future<void> saveThemeMode(AppThemeMode mode);
}
