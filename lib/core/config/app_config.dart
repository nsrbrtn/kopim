// lib/core/config/app_config.dart

import 'dart:math' as math;

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/application/firebase_availability.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/theme/data/app_theme_factory.dart';
import 'package:kopim/core/theme/data/dto/kopim_theme_tokens.dart';

import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

const Duration _kDefaultAiRequestTimeout = Duration(seconds: 25);
const Duration _kDefaultAiThrottleInterval = Duration(seconds: 2);
const Duration _kDefaultAiRetryBaseDelay = Duration(milliseconds: 1200);
const double _kDefaultAiRetryMultiplier = 1.8;
const int _kDefaultAiMaxRetries = 2;
const String _kDefaultAiModel = '@preset/kopim';
const String _kDefaultAiBaseUrl = 'https://openrouter.ai/api/v1';
const String _kRemoteConfigKeyName = 'ai_openrouter_api_key';
const String _kRemoteConfigModelName = 'ai_openrouter_model';
const String _kRemoteConfigBaseUrl = 'ai_openrouter_base_url';
const String _kRemoteConfigReferer = 'ai_openrouter_referer';
const String _kRemoteConfigTitle = 'ai_openrouter_title';
const String _kRemoteConfigTimeoutMs = 'ai_openrouter_timeout_ms';
const String _kRemoteConfigThrottleMs = 'ai_openrouter_throttle_ms';
const String _kRemoteConfigEnabledFlag = 'ai_openrouter_enabled';
const String _kRemoteConfigMaxRetries = 'ai_openrouter_max_retries';
const String _kRemoteConfigRetryBaseMs = 'ai_openrouter_retry_base_ms';
const String _kRemoteConfigRetryMultiplier = 'ai_openrouter_retry_multiplier';

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
    required this.baseUrl,
    required this.requestTimeout,
    required this.throttleInterval,
    required this.isEnabled,
    required this.maxRetries,
    required this.retryBaseDelay,
    required this.retryMultiplier,
    this.apiKey,
    this.referer,
    this.appTitle,
  });

  final String? apiKey;
  final String model;
  final String baseUrl;
  final Duration requestTimeout;
  final Duration throttleInterval;
  final bool isEnabled;
  final int maxRetries;
  final Duration retryBaseDelay;
  final double retryMultiplier;
  final String? referer;
  final String? appTitle;

  GenerativeAiConfig copyWith({
    String? apiKey,
    String? model,
    String? baseUrl,
    Duration? requestTimeout,
    Duration? throttleInterval,
    bool? isEnabled,
    int? maxRetries,
    Duration? retryBaseDelay,
    double? retryMultiplier,
    String? referer,
    String? appTitle,
  }) {
    return GenerativeAiConfig(
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      baseUrl: baseUrl ?? this.baseUrl,
      requestTimeout: requestTimeout ?? this.requestTimeout,
      throttleInterval: throttleInterval ?? this.throttleInterval,
      isEnabled: isEnabled ?? this.isEnabled,
      maxRetries: maxRetries ?? this.maxRetries,
      retryBaseDelay: retryBaseDelay ?? this.retryBaseDelay,
      retryMultiplier: retryMultiplier ?? this.retryMultiplier,
      referer: referer ?? this.referer,
      appTitle: appTitle ?? this.appTitle,
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

// Provider для locale - читает из профиля пользователя
final Provider<Locale> appLocaleProvider = Provider<Locale>((Ref ref) {
  final Locale fallbackLocale = _resolveSystemFallbackLocale();
  // Получаем текущего пользователя
  final AsyncValue<AuthUser?> authState = ref.watch(authControllerProvider);

  // Если пользователь не авторизован, возвращаем локальный fallback
  final AuthUser? authUser = authState.asData?.value;
  if (authUser == null) {
    debugPrint(
      '🔴 [appLocaleProvider] No auth user, returning fallback ${fallbackLocale.toLanguageTag()}',
    );
    return fallbackLocale;
  }

  // Пытаемся получить профиль пользователя
  final AsyncValue<Profile?> profileState = ref.watch(
    profileControllerProvider(authUser.uid),
  );

  // Извлекаем locale из профиля
  final Profile? profile = profileState.asData?.value;
  if (profile != null) {
    final String localeString = profile.locale;
    debugPrint('🟢 [appLocaleProvider] Profile locale: $localeString');
    // Парсим locale строку (например, 'ru' или 'en')
    final List<String> parts = localeString.split('-');
    if (parts.isNotEmpty) {
      final Locale result = Locale(
        parts[0],
        parts.length > 1 ? parts[1] : null,
      );
      debugPrint(
        '🟢 [appLocaleProvider] Returning locale: ${result.toLanguageTag()}',
      );
      return result;
    }
  }

  // Если профиль не загружен или locale не установлен, возвращаем fallback
  debugPrint(
    '🟡 [appLocaleProvider] Profile not loaded or no locale, returning fallback ${fallbackLocale.toLanguageTag()}',
  );
  return fallbackLocale;
});

// Другие providers: theme, auth и т.д.
ThemeData _resolveAppTheme(Ref ref, Brightness brightness) {
  final AppThemeFactory factory = ref.watch(appThemeFactoryProvider);
  final AsyncValue<KopimThemeTokenBundle> tokensState = ref.watch(
    appThemeTokensProvider,
  );
  final KopimThemeTokenBundle tokens = tokensState.maybeWhen(
    data: (KopimThemeTokenBundle bundle) => bundle,
    orElse: () => factory.fallbackTokens,
  );

  return factory.createTheme(brightness: brightness, tokens: tokens);
}

final Provider<ThemeData> appThemeProvider = Provider<ThemeData>((Ref ref) {
  return _resolveAppTheme(ref, Brightness.light);
});

final Provider<ThemeData> appDarkThemeProvider = Provider<ThemeData>((Ref ref) {
  return _resolveAppTheme(ref, Brightness.dark);
});

Locale _resolveSystemFallbackLocale() {
  const Locale fallback = Locale('ru');
  final WidgetsBinding binding = WidgetsBinding.instance;
  final Locale platformLocale = binding.platformDispatcher.locale;
  if (platformLocale.languageCode.isEmpty) {
    return fallback;
  }
  for (final Locale supported in AppLocalizations.supportedLocales) {
    if (supported.languageCode == platformLocale.languageCode) {
      return supported;
    }
  }
  return fallback;
}

/// Провайдер, подготавливающий конфигурацию OpenRouter из Remote Config и переменных окружения.
final FutureProvider<AppConfig> appConfigProvider = FutureProvider<AppConfig>((
  Ref ref,
) async {
  final LoggerService logger = ref.watch(loggerServiceProvider);
  final AnalyticsService analytics = ref.watch(analyticsServiceProvider);
  final FirebaseAvailabilityState availability = ref.watch(
    firebaseAvailabilityProvider,
  );

  if (availability.isAvailable == false) {
    return AppConfig(generativeAi: _buildDefaultGenerativeAiConfig());
  }

  final FirebaseRemoteConfig remoteConfig = ref.watch(
    firebaseRemoteConfigProvider,
  );

  try {
    await remoteConfig.ensureInitialized();
    await remoteConfig.setDefaults(<String, Object?>{
      _kRemoteConfigModelName: _kDefaultAiModel,
      _kRemoteConfigBaseUrl: _kDefaultAiBaseUrl,
      _kRemoteConfigTimeoutMs: _kDefaultAiRequestTimeout.inMilliseconds,
      _kRemoteConfigThrottleMs: _kDefaultAiThrottleInterval.inMilliseconds,
      _kRemoteConfigEnabledFlag: true,
      _kRemoteConfigMaxRetries: _kDefaultAiMaxRetries,
      _kRemoteConfigRetryBaseMs: _kDefaultAiRetryBaseDelay.inMilliseconds,
      _kRemoteConfigRetryMultiplier: _kDefaultAiRetryMultiplier,
    });
    await remoteConfig.fetchAndActivate();
  } catch (error, stackTrace) {
    logger.logError('Не удалось обновить Remote Config для OpenRouter', error);
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
    'OPENROUTER_API_KEY',
    defaultValue: '',
  );
  final String? apiKey = remoteKey.isNotEmpty
      ? remoteKey
      : (envKey.isNotEmpty ? envKey : null);

  final String modelValue = remoteConfig.getString(_kRemoteConfigModelName);
  final String baseUrlValue = remoteConfig.getString(_kRemoteConfigBaseUrl);
  final String refererValue = remoteConfig.getString(_kRemoteConfigReferer);
  final String titleValue = remoteConfig.getString(_kRemoteConfigTitle);
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
    baseUrl: baseUrlValue.isNotEmpty ? baseUrlValue : _kDefaultAiBaseUrl,
    requestTimeout: timeout,
    throttleInterval: throttle,
    isEnabled: enabled,
    maxRetries: maxRetries >= 0 ? maxRetries : _kDefaultAiMaxRetries,
    retryBaseDelay: retryBase,
    retryMultiplier: multiplier,
    referer: refererValue.isNotEmpty ? refererValue : null,
    appTitle: titleValue.isNotEmpty ? titleValue : null,
  );
}

GenerativeAiConfig _buildDefaultGenerativeAiConfig() {
  const String envKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: '',
  );
  final String? apiKey = envKey.isNotEmpty ? envKey : null;
  return GenerativeAiConfig(
    apiKey: apiKey,
    model: _kDefaultAiModel,
    baseUrl: _kDefaultAiBaseUrl,
    requestTimeout: _kDefaultAiRequestTimeout,
    throttleInterval: _kDefaultAiThrottleInterval,
    isEnabled: true,
    maxRetries: _kDefaultAiMaxRetries,
    retryBaseDelay: _kDefaultAiRetryBaseDelay,
    retryMultiplier: _kDefaultAiRetryMultiplier,
  );
}
