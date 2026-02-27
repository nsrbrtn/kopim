import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kOnlineSyncEnabledKey = 'core.online_sync.enabled';

final AsyncNotifierProvider<OnlineSyncPreferencesController, bool>
onlineSyncPreferencesControllerProvider =
    AsyncNotifierProvider<OnlineSyncPreferencesController, bool>(
      OnlineSyncPreferencesController.new,
    );

class OnlineSyncPreferencesController extends AsyncNotifier<bool> {
  late Future<SharedPreferences> _preferencesFuture;

  @override
  Future<bool> build() async {
    _preferencesFuture = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _preferencesFuture;
    return prefs.getBool(_kOnlineSyncEnabledKey) ?? true;
  }

  Future<void> setEnabled(bool value) async {
    final bool previous = state.maybeWhen(
      data: (bool current) => current,
      orElse: () => true,
    );
    state = AsyncValue<bool>.data(value);
    try {
      final SharedPreferences prefs = await _preferencesFuture;
      await prefs.setBool(_kOnlineSyncEnabledKey, value);
    } catch (error, stackTrace) {
      state = AsyncValue<bool>.data(previous);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> toggle() async {
    final bool current = state.maybeWhen(
      data: (bool value) => value,
      orElse: () => true,
    );
    await setEnabled(!current);
  }
}
