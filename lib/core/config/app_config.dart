// lib/core/config/app_config.dart

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/di/injectors.dart';

import 'theme.dart';

import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';

const Duration _kDefaultAiRequestTimeout = Duration(seconds: 25);
const Duration _kDefaultAiThrottleInterval = Duration(seconds: 2);
const String _kDefaultAiModel = 'gemini-1.5-flash-latest';
const String _kRemoteConfigKeyName = 'ai_gemini_api_key';
const String _kRemoteConfigModelName = 'ai_gemini_model';
const String _kRemoteConfigTimeoutMs = 'ai_gemini_timeout_ms';
const String _kRemoteConfigThrottleMs = 'ai_gemini_throttle_ms';

/// Конфигурация доступа к ИИ-ассистенту.
class GenerativeAiConfig {
  const GenerativeAiConfig({
    required this.model,
    required this.requestTimeout,
    required this.throttleInterval,
    this.apiKey,
  });

  final String? apiKey;
  final String model;
  final Duration requestTimeout;
  final Duration throttleInterval;

  GenerativeAiConfig copyWith({
    String? apiKey,
    String? model,
    Duration? requestTimeout,
    Duration? throttleInterval,
  }) {
    return GenerativeAiConfig(
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      requestTimeout: requestTimeout ?? this.requestTimeout,
      throttleInterval: throttleInterval ?? this.throttleInterval,
    );
  }
}

// Provider для locale (init по умолчанию ru, или из хранилища)
final Provider<Locale> appLocaleProvider = Provider<Locale>((Ref ref) {
  // Здесь можно читать из SharedPreferences или Drift для persistent locale
  return const Locale('ru'); // По умолчанию русский, как в стиле проекта
});

// Другие providers: theme, auth и т.д.
final Provider<ThemeData> appThemeProvider = Provider<ThemeData>((Ref ref) {
  return buildAppTheme(brightness: Brightness.light);
});

final Provider<ThemeData> appDarkThemeProvider = Provider<ThemeData>((Ref ref) {
  return buildAppTheme(brightness: Brightness.dark);
});

/// Провайдер, подготавливающий конфигурацию Gemini из Remote Config и переменных окружения.
final FutureProvider<GenerativeAiConfig> generativeAiConfigProvider =
    FutureProvider<GenerativeAiConfig>((Ref ref) async {
      final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
      final LoggerService logger = ref.watch(loggerServiceProvider);
      final AnalyticsService analytics = ref.watch(analyticsServiceProvider);

      try {
        await remoteConfig.ensureInitialized();
        await remoteConfig.setDefaults(<String, Object?>{
          _kRemoteConfigModelName: _kDefaultAiModel,
          _kRemoteConfigTimeoutMs: _kDefaultAiRequestTimeout.inMilliseconds,
          _kRemoteConfigThrottleMs: _kDefaultAiThrottleInterval.inMilliseconds,
        });
        await remoteConfig.fetchAndActivate();
      } catch (error, stackTrace) {
        logger.logError('Не удалось обновить Remote Config для Gemini', error);
        analytics.reportError(error, stackTrace);
      }

      final String remoteKey = remoteConfig.getString(_kRemoteConfigKeyName);
      const String envKey = String.fromEnvironment(
        'AI_ASSISTANT_API_KEY',
        defaultValue: '',
      );
      final String? apiKey = remoteKey.isNotEmpty
          ? remoteKey
          : (envKey.isNotEmpty ? envKey : null);

      final String modelValue = remoteConfig.getString(_kRemoteConfigModelName);
      final int timeoutMs = remoteConfig.getInt(_kRemoteConfigTimeoutMs);
      final int throttleMs = remoteConfig.getInt(_kRemoteConfigThrottleMs);

      final Duration timeout = timeoutMs > 0
          ? Duration(milliseconds: timeoutMs)
          : _kDefaultAiRequestTimeout;
      final Duration throttle = throttleMs > 0
          ? Duration(milliseconds: throttleMs)
          : _kDefaultAiThrottleInterval;

      return GenerativeAiConfig(
        apiKey: apiKey,
        model: modelValue.isNotEmpty ? modelValue : _kDefaultAiModel,
        requestTimeout: timeout,
        throttleInterval: throttle,
      );
    });
