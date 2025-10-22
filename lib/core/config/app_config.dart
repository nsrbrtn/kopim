// lib/core/config/app_config.dart

import 'dart:math' as math;

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/di/injectors.dart';

import 'theme.dart';

import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';

const Duration _kDefaultAiRequestTimeout = Duration(seconds: 25);
const Duration _kDefaultAiThrottleInterval = Duration(seconds: 2);
const Duration _kDefaultAiRetryBaseDelay = Duration(milliseconds: 1200);
const double _kDefaultAiRetryMultiplier = 1.8;
const int _kDefaultAiMaxRetries = 2;
const String _kDefaultAiModel = 'gemini-2.5-flash';
const String _kRemoteConfigKeyName = 'ai_gemini_api_key';
const String _kRemoteConfigModelName = 'ai_gemini_model';
const String _kRemoteConfigTimeoutMs = 'ai_gemini_timeout_ms';
const String _kRemoteConfigThrottleMs = 'ai_gemini_throttle_ms';
const String _kRemoteConfigEnabledFlag = 'ai_gemini_enabled';
const String _kRemoteConfigMaxRetries = 'ai_gemini_max_retries';
const String _kRemoteConfigRetryBaseMs = 'ai_gemini_retry_base_ms';
const String _kRemoteConfigRetryMultiplier = 'ai_gemini_retry_multiplier';

/// Глобальная конфигурация приложения.
class AppConfig {
  const AppConfig({required this.generativeAi});

  final GenerativeAiConfig generativeAi;

  AppConfig copyWith({GenerativeAiConfig? generativeAi}) {
    return AppConfig(generativeAi: generativeAi ?? this.generativeAi);
  }
}

/// Конфигурация доступа к ИИ-ассистенту.
class GenerativeAiConfig {
  const GenerativeAiConfig({
    required this.model,
    required this.requestTimeout,
    required this.throttleInterval,
    required this.isEnabled,
    required this.maxRetries,
    required this.retryBaseDelay,
    required this.retryMultiplier,
    this.apiKey,
  });

  final String? apiKey;
  final String model;
  final Duration requestTimeout;
  final Duration throttleInterval;
  final bool isEnabled;
  final int maxRetries;
  final Duration retryBaseDelay;
  final double retryMultiplier;

  GenerativeAiConfig copyWith({
    String? apiKey,
    String? model,
    Duration? requestTimeout,
    Duration? throttleInterval,
    bool? isEnabled,
    int? maxRetries,
    Duration? retryBaseDelay,
    double? retryMultiplier,
  }) {
    return GenerativeAiConfig(
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      requestTimeout: requestTimeout ?? this.requestTimeout,
      throttleInterval: throttleInterval ?? this.throttleInterval,
      isEnabled: isEnabled ?? this.isEnabled,
      maxRetries: maxRetries ?? this.maxRetries,
      retryBaseDelay: retryBaseDelay ?? this.retryBaseDelay,
      retryMultiplier: retryMultiplier ?? this.retryMultiplier,
    );
  }

  Duration retryDelayForAttempt(int attemptIndex) {
    final double multiplier = math
        .pow(retryMultiplier, attemptIndex)
        .toDouble();
    final double ms = retryBaseDelay.inMilliseconds * multiplier;
    final int clampedMs = ms.isFinite
        ? ms.round().clamp(100, 60000)
        : retryBaseDelay.inMilliseconds.clamp(100, 60000);
    return Duration(milliseconds: clampedMs);
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
final FutureProvider<AppConfig> appConfigProvider = FutureProvider<AppConfig>((
  Ref ref,
) async {
  final FirebaseRemoteConfig remoteConfig = ref.watch(
    firebaseRemoteConfigProvider,
  );
  final LoggerService logger = ref.watch(loggerServiceProvider);
  final AnalyticsService analytics = ref.watch(analyticsServiceProvider);

  try {
    await remoteConfig.ensureInitialized();
    await remoteConfig.setDefaults(<String, Object?>{
      _kRemoteConfigModelName: _kDefaultAiModel,
      _kRemoteConfigTimeoutMs: _kDefaultAiRequestTimeout.inMilliseconds,
      _kRemoteConfigThrottleMs: _kDefaultAiThrottleInterval.inMilliseconds,
      _kRemoteConfigEnabledFlag: true,
      _kRemoteConfigMaxRetries: _kDefaultAiMaxRetries,
      _kRemoteConfigRetryBaseMs: _kDefaultAiRetryBaseDelay.inMilliseconds,
      _kRemoteConfigRetryMultiplier: _kDefaultAiRetryMultiplier,
    });
    await remoteConfig.fetchAndActivate();
  } catch (error, stackTrace) {
    logger.logError('Не удалось обновить Remote Config для Gemini', error);
    analytics.reportError(error, stackTrace);
  }

  final GenerativeAiConfig generativeAi = _buildGenerativeAiConfig(
    remoteConfig,
  );
  return AppConfig(generativeAi: generativeAi);
});

final FutureProvider<GenerativeAiConfig> generativeAiConfigProvider =
    FutureProvider<GenerativeAiConfig>((Ref ref) async {
      final AppConfig config = await ref.watch(appConfigProvider.future);
      return config.generativeAi;
    });

GenerativeAiConfig _buildGenerativeAiConfig(FirebaseRemoteConfig remoteConfig) {
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
  final bool enabled = remoteConfig.getBool(_kRemoteConfigEnabledFlag);
  final int maxRetries = remoteConfig.getInt(_kRemoteConfigMaxRetries);
  final int retryBaseMs = remoteConfig.getInt(_kRemoteConfigRetryBaseMs);
  final double retryMultiplier = remoteConfig.getDouble(
    _kRemoteConfigRetryMultiplier,
  );

  final Duration timeout = timeoutMs > 0
      ? Duration(milliseconds: timeoutMs)
      : _kDefaultAiRequestTimeout;
  final Duration throttle = throttleMs > 0
      ? Duration(milliseconds: throttleMs)
      : _kDefaultAiThrottleInterval;
  final Duration retryBase = retryBaseMs > 0
      ? Duration(milliseconds: retryBaseMs)
      : _kDefaultAiRetryBaseDelay;

  final double multiplier = retryMultiplier.isFinite && retryMultiplier >= 1
      ? retryMultiplier
      : _kDefaultAiRetryMultiplier;

  return GenerativeAiConfig(
    apiKey: apiKey,
    model: modelValue.isNotEmpty ? modelValue : _kDefaultAiModel,
    requestTimeout: timeout,
    throttleInterval: throttle,
    isEnabled: enabled,
    maxRetries: maxRetries >= 0 ? maxRetries : _kDefaultAiMaxRetries,
    retryBaseDelay: retryBase,
    retryMultiplier: multiplier,
  );
}
