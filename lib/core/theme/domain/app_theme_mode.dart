import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_theme_mode.freezed.dart';

/// Доменное представление режима темы приложения.
@freezed
class AppThemeMode with _$AppThemeMode {
  const AppThemeMode._();

  const factory AppThemeMode.system() = _System;

  const factory AppThemeMode.light() = _Light;

  const factory AppThemeMode.dark() = _Dark;

  /// Ключ для сохранения в локальном хранилище.
  String get storageKey =>
      when(system: () => 'system', light: () => 'light', dark: () => 'dark');

  /// Восстанавливает режим темы из сохранённого ключа.
  static AppThemeMode fromStorageKey(String key) {
    switch (key) {
      case 'light':
        return const AppThemeMode.light();
      case 'dark':
        return const AppThemeMode.dark();
      case 'system':
      default:
        return const AppThemeMode.system();
    }
  }
}
