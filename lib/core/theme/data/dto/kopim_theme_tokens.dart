import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'kopim_theme_tokens.freezed.dart';
part 'kopim_theme_tokens.g.dart';

@freezed
abstract class KopimThemeTokenBundle with _$KopimThemeTokenBundle {
  const factory KopimThemeTokenBundle({
    required KopimSystemColorTokens lightColors,
    required KopimSystemColorTokens darkColors,
    required KopimTypographyTokens typography,
    required KopimShapeTokens shape,
    required KopimSpacingTokens spacing,
    required KopimSizeTokens sizes,
    required KopimMotionTokens motion,
  }) = _KopimThemeTokenBundle;

  factory KopimThemeTokenBundle.fromJson(Map<String, dynamic> json) =>
      _$KopimThemeTokenBundleFromJson(json);
}

@freezed
abstract class KopimSystemColorTokens with _$KopimSystemColorTokens {
  const factory KopimSystemColorTokens({
    @ColorConverter() required Color primary,
    @ColorConverter() required Color onPrimary,
    @ColorConverter() required Color primaryContainer,
    @ColorConverter() required Color onPrimaryContainer,
    @ColorConverter() required Color primaryFixed,
    @ColorConverter() required Color primaryFixedDim,
    @ColorConverter() required Color onPrimaryFixed,
    @ColorConverter() required Color onPrimaryFixedVariant,
    @ColorConverter() required Color secondary,
    @ColorConverter() required Color onSecondary,
    @ColorConverter() required Color secondaryContainer,
    @ColorConverter() required Color onSecondaryContainer,
    @ColorConverter() required Color secondaryFixed,
    @ColorConverter() required Color secondaryFixedDim,
    @ColorConverter() required Color onSecondaryFixed,
    @ColorConverter() required Color onSecondaryFixedVariant,
    @ColorConverter() required Color tertiary,
    @ColorConverter() required Color onTertiary,
    @ColorConverter() required Color tertiaryContainer,
    @ColorConverter() required Color onTertiaryContainer,
    @ColorConverter() required Color tertiaryFixed,
    @ColorConverter() required Color tertiaryFixedDim,
    @ColorConverter() required Color onTertiaryFixed,
    @ColorConverter() required Color onTertiaryFixedVariant,
    @ColorConverter() required Color error,
    @ColorConverter() required Color onError,
    @ColorConverter() required Color errorContainer,
    @ColorConverter() required Color onErrorContainer,
    @ColorConverter() required Color surface,
    @ColorConverter() required Color onSurface,
    @ColorConverter() required Color surfaceDim,
    @ColorConverter() required Color surfaceBright,
    @ColorConverter() required Color surfaceContainerLowest,
    @ColorConverter() required Color surfaceContainerLow,
    @ColorConverter() required Color surfaceContainer,
    @ColorConverter() required Color surfaceContainerHigh,
    @ColorConverter() required Color surfaceContainerHighest,
    @ColorConverter() required Color onSurfaceVariant,
    @ColorConverter() required Color outline,
    @ColorConverter() required Color outlineVariant,
    @ColorConverter() required Color shadow,
    @ColorConverter() required Color scrim,
    @ColorConverter() required Color inverseSurface,
    @ColorConverter() required Color inverseOnSurface,
    @ColorConverter() required Color inversePrimary,
    @ColorConverter() required Color surfaceTint,
    @ColorConverter() required Color background,
    @ColorConverter() required Color onBackground,
    @ColorConverter() required Color surfaceVariant,
  }) = _KopimSystemColorTokens;

  factory KopimSystemColorTokens.fromJson(Map<String, dynamic> json) =>
      _$KopimSystemColorTokensFromJson(json);
}

@freezed
abstract class KopimTypographyTokens with _$KopimTypographyTokens {
  const factory KopimTypographyTokens({
    required KopimTextStyleTokens displayLarge,
    required KopimTextStyleTokens displayMedium,
    required KopimTextStyleTokens displaySmall,
    required KopimTextStyleTokens headlineLarge,
    required KopimTextStyleTokens headlineMedium,
    required KopimTextStyleTokens headlineSmall,
    required KopimTextStyleTokens titleLarge,
    required KopimTextStyleTokens titleMedium,
    required KopimTextStyleTokens titleSmall,
    required KopimTextStyleTokens bodyLarge,
    required KopimTextStyleTokens bodyMedium,
    required KopimTextStyleTokens bodySmall,
    required KopimTextStyleTokens labelLarge,
    required KopimTextStyleTokens labelMedium,
    required KopimTextStyleTokens labelSmall,
  }) = _KopimTypographyTokens;

  factory KopimTypographyTokens.fromJson(Map<String, dynamic> json) =>
      _$KopimTypographyTokensFromJson(json);
}

@freezed
abstract class KopimTextStyleTokens with _$KopimTextStyleTokens {
  const factory KopimTextStyleTokens({
    required String fontFamily,
    @FontWeightConverter() required FontWeight fontWeight,
    required double fontSize,
    required double lineHeight,
    required double letterSpacing,
  }) = _KopimTextStyleTokens;

  factory KopimTextStyleTokens.fromJson(Map<String, dynamic> json) =>
      _$KopimTextStyleTokensFromJson(json);
}

@freezed
abstract class KopimShapeTokens with _$KopimShapeTokens {
  const factory KopimShapeTokens({
    required Map<String, double> radius,
    required Map<String, double> borderWidth,
  }) = _KopimShapeTokens;

  factory KopimShapeTokens.fromJson(Map<String, dynamic> json) =>
      _$KopimShapeTokensFromJson(json);
}

@freezed
abstract class KopimSpacingTokens with _$KopimSpacingTokens {
  const factory KopimSpacingTokens({required Map<String, double> values}) =
      _KopimSpacingTokens;

  factory KopimSpacingTokens.fromJson(Map<String, dynamic> json) =>
      _$KopimSpacingTokensFromJson(json);
}

@freezed
abstract class KopimSizeTokens with _$KopimSizeTokens {
  const factory KopimSizeTokens({
    required Map<String, double> touch,
    required Map<String, double> icon,
    required Map<String, double> avatar,
  }) = _KopimSizeTokens;

  factory KopimSizeTokens.fromJson(Map<String, dynamic> json) =>
      _$KopimSizeTokensFromJson(json);
}

@freezed
abstract class KopimMotionTokens with _$KopimMotionTokens {
  const factory KopimMotionTokens({
    required KopimMotionDurations durations,
    required KopimMotionEasing easing,
  }) = _KopimMotionTokens;

  factory KopimMotionTokens.fromJson(Map<String, dynamic> json) =>
      _$KopimMotionTokensFromJson(json);
}

@freezed
abstract class KopimMotionDurations with _$KopimMotionDurations {
  const factory KopimMotionDurations({
    @DurationMsConverter() required Duration xxs,
    @DurationMsConverter() required Duration xs,
    @DurationMsConverter() required Duration sm,
    @DurationMsConverter() required Duration md,
    @DurationMsConverter() required Duration lg,
    @DurationMsConverter() required Duration xl,
    @DurationMsConverter() required Duration xxl,
  }) = _KopimMotionDurations;

  factory KopimMotionDurations.fromJson(Map<String, dynamic> json) =>
      _$KopimMotionDurationsFromJson(json);
}

@freezed
abstract class KopimMotionEasing with _$KopimMotionEasing {
  const factory KopimMotionEasing({
    @CubicConverter() required Cubic standard,
    @CubicConverter() required Cubic decelerate,
    @CubicConverter() required Cubic accelerate,
    @CubicConverter() required Cubic emphasized,
  }) = _KopimMotionEasing;

  factory KopimMotionEasing.fromJson(Map<String, dynamic> json) =>
      _$KopimMotionEasingFromJson(json);
}

class ColorConverter implements JsonConverter<Color, String> {
  const ColorConverter();

  @override
  Color fromJson(String json) {
    final String value = json.trim();
    if (value.isEmpty) {
      throw const FormatException('Color value cannot be empty');
    }
    final String hex = value.startsWith('#') ? value.substring(1) : value;
    if (hex.length != 6 && hex.length != 8) {
      throw FormatException('Unexpected color format: $value');
    }
    final String normalized = hex.length == 6
        ? 'FF${hex.toUpperCase()}'
        : '${hex.substring(6).toUpperCase()}${hex.substring(0, 6).toUpperCase()}';
    return Color(int.parse(normalized, radix: 16));
  }

  @override
  String toJson(Color object) =>
      '#${object.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
}

class FontWeightConverter implements JsonConverter<FontWeight, String> {
  const FontWeightConverter();

  static const Map<String, FontWeight> _mapping = <String, FontWeight>{
    'Thin': FontWeight.w100,
    'ExtraLight': FontWeight.w200,
    'Light': FontWeight.w300,
    'Regular': FontWeight.w400,
    'Medium': FontWeight.w500,
    'SemiBold': FontWeight.w600,
    'Bold': FontWeight.w700,
    'ExtraBold': FontWeight.w800,
    'Black': FontWeight.w900,
  };

  @override
  FontWeight fromJson(String json) {
    final FontWeight? weight = _mapping[json];
    if (weight == null) {
      throw FormatException('Unsupported font weight: $json');
    }
    return weight;
  }

  @override
  String toJson(FontWeight object) {
    return _mapping.entries
        .firstWhere(
          (MapEntry<String, FontWeight> entry) => entry.value == object,
          orElse: () =>
              const MapEntry<String, FontWeight>('Regular', FontWeight.w400),
        )
        .key;
  }
}

class DurationMsConverter implements JsonConverter<Duration, int> {
  const DurationMsConverter();

  @override
  Duration fromJson(int json) => Duration(milliseconds: json);

  @override
  int toJson(Duration object) => object.inMilliseconds;
}

class CubicConverter implements JsonConverter<Cubic, List<double>> {
  const CubicConverter();

  @override
  Cubic fromJson(List<double> json) {
    if (json.length != 4) {
      throw FormatException('Cubic expects 4 values, received: $json');
    }
    return Cubic(json[0], json[1], json[2], json[3]);
  }

  @override
  List<double> toJson(Cubic object) => <double>[
    object.a,
    object.b,
    object.c,
    object.d,
  ];
}
