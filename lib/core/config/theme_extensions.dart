import 'package:flutter/material.dart';

class KopimSpecialSurfaces extends ThemeExtension<KopimSpecialSurfaces> {
  const KopimSpecialSurfaces({
    required this.fabGradient,
    required this.navigationBarLight,
    required this.navigationBarDark,
  });

  final LinearGradient fabGradient;
  final Color navigationBarLight;
  final Color navigationBarDark;

  @override
  KopimSpecialSurfaces copyWith({
    LinearGradient? fabGradient,
    Color? navigationBarLight,
    Color? navigationBarDark,
  }) {
    return KopimSpecialSurfaces(
      fabGradient: fabGradient ?? this.fabGradient,
      navigationBarLight: navigationBarLight ?? this.navigationBarLight,
      navigationBarDark: navigationBarDark ?? this.navigationBarDark,
    );
  }

  @override
  KopimSpecialSurfaces lerp(
    ThemeExtension<KopimSpecialSurfaces>? other,
    double t,
  ) {
    if (other is! KopimSpecialSurfaces) {
      return this;
    }
    return KopimSpecialSurfaces(
      fabGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color.lerp(
                fabGradient.colors.first,
                other.fabGradient.colors.first,
                t,
              ) ??
              fabGradient.colors.first,
          Color.lerp(
                fabGradient.colors.last,
                other.fabGradient.colors.last,
                t,
              ) ??
              fabGradient.colors.last,
        ],
      ),
      navigationBarLight:
          Color.lerp(navigationBarLight, other.navigationBarLight, t) ??
          navigationBarLight,
      navigationBarDark:
          Color.lerp(navigationBarDark, other.navigationBarDark, t) ??
          navigationBarDark,
    );
  }
}

class KopimMotion extends ThemeExtension<KopimMotion> {
  const KopimMotion({required this.durations, required this.curves});

  final KopimMotionDurationsData durations;
  final KopimMotionCurvesData curves;

  @override
  KopimMotion copyWith({
    KopimMotionDurationsData? durations,
    KopimMotionCurvesData? curves,
  }) {
    return KopimMotion(
      durations: durations ?? this.durations,
      curves: curves ?? this.curves,
    );
  }

  @override
  KopimMotion lerp(ThemeExtension<KopimMotion>? other, double t) {
    return other is KopimMotion ? other : this;
  }
}

class KopimMotionDurationsData {
  const KopimMotionDurationsData({
    required this.xxs,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  });

  final Duration xxs;
  final Duration xs;
  final Duration sm;
  final Duration md;
  final Duration lg;
  final Duration xl;
  final Duration xxl;
}

class KopimMotionCurvesData {
  const KopimMotionCurvesData({
    required this.standard,
    required this.decelerate,
    required this.accelerate,
    required this.emphasized,
  });

  final Curve standard;
  final Curve decelerate;
  final Curve accelerate;
  final Curve emphasized;
}
