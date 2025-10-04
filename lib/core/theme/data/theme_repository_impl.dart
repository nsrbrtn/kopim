import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_theme_mode.dart';
import '../domain/repositories/theme_repository.dart';

part 'theme_repository_impl.g.dart';

const String _kThemeModeKey = 'core.theme.mode';

class ThemeRepositoryImpl implements ThemeRepository {
  ThemeRepositoryImpl({Future<SharedPreferences>? preferences})
    : _preferencesFuture = preferences ?? SharedPreferences.getInstance();

  final Future<SharedPreferences> _preferencesFuture;

  @override
  Future<AppThemeMode> loadThemeMode() async {
    final SharedPreferences prefs = await _preferencesFuture;
    final String? value = prefs.getString(_kThemeModeKey);
    if (value == null) {
      return const AppThemeMode.system();
    }
    return AppThemeMode.fromStorageKey(value);
  }

  @override
  Future<void> saveThemeMode(AppThemeMode mode) async {
    final SharedPreferences prefs = await _preferencesFuture;
    await prefs.setString(_kThemeModeKey, mode.storageKey);
  }
}

@riverpod
ThemeRepository themeRepository(Ref ref) {
  return ThemeRepositoryImpl();
}
