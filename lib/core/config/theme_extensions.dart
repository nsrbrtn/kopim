import 'dart:ui' show lerpDouble;

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

  static const KopimSpecialSurfaces fallback = KopimSpecialSurfaces(
    fabGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[Color(0xFF74875F), Color(0xFF474747)],
    ),
    navigationBarLight: Color(0xD4FFFFFF),
    navigationBarDark: Color(0x99D4D4D4),
  );

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

class KopimLayout extends ThemeExtension<KopimLayout> {
  const KopimLayout({
    required this.divider,
    required this.spacing,
    required this.radius,
    required this.iconSizes,
  });

  final KopimDividerTokens divider;
  final KopimSpacingScale spacing;
  final KopimRadiusScale radius;
  final KopimIconSizes iconSizes;

  static const KopimLayout fallback = KopimLayout(
    divider: KopimDividerTokens(thickness: 1),
    spacing: KopimSpacingScale(
      screen: 16,
      between: 8,
      section: 16,
      sectionLarge: 24,
    ),
    radius: KopimRadiusScale(card: 24),
    iconSizes: KopimIconSizes(xs: 16, sm: 20, md: 24, lg: 32, xl: 48),
  );

  @override
  KopimLayout copyWith({
    KopimDividerTokens? divider,
    KopimSpacingScale? spacing,
    KopimRadiusScale? radius,
    KopimIconSizes? iconSizes,
  }) {
    return KopimLayout(
      divider: divider ?? this.divider,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      iconSizes: iconSizes ?? this.iconSizes,
    );
  }

  @override
  KopimLayout lerp(ThemeExtension<KopimLayout>? other, double t) {
    if (other is! KopimLayout) {
      return this;
    }
    return KopimLayout(
      divider: KopimDividerTokens.lerp(divider, other.divider, t),
      spacing: KopimSpacingScale.lerp(spacing, other.spacing, t),
      radius: KopimRadiusScale.lerp(radius, other.radius, t),
      iconSizes: KopimIconSizes.lerp(iconSizes, other.iconSizes, t),
    );
  }
}

class KopimDividerTokens {
  const KopimDividerTokens({required this.thickness});

  final double thickness;

  KopimDividerTokens copyWith({double? thickness}) {
    return KopimDividerTokens(thickness: thickness ?? this.thickness);
  }

  static KopimDividerTokens lerp(
    KopimDividerTokens current,
    KopimDividerTokens target,
    double t,
  ) {
    return KopimDividerTokens(
      thickness:
          lerpDouble(current.thickness, target.thickness, t) ??
          current.thickness,
    );
  }
}

class KopimSpacingScale {
  const KopimSpacingScale({
    required this.screen,
    required this.between,
    required this.section,
    required this.sectionLarge,
  });

  final double screen;
  final double between;
  final double section;
  final double sectionLarge;

  KopimSpacingScale copyWith({
    double? screen,
    double? between,
    double? section,
    double? sectionLarge,
  }) {
    return KopimSpacingScale(
      screen: screen ?? this.screen,
      between: between ?? this.between,
      section: section ?? this.section,
      sectionLarge: sectionLarge ?? this.sectionLarge,
    );
  }

  static KopimSpacingScale lerp(
    KopimSpacingScale current,
    KopimSpacingScale target,
    double t,
  ) {
    return KopimSpacingScale(
      screen: lerpDouble(current.screen, target.screen, t) ?? current.screen,
      between:
          lerpDouble(current.between, target.between, t) ?? current.between,
      section:
          lerpDouble(current.section, target.section, t) ?? current.section,
      sectionLarge:
          lerpDouble(current.sectionLarge, target.sectionLarge, t) ??
          current.sectionLarge,
    );
  }
}

class KopimRadiusScale {
  const KopimRadiusScale({required this.card});

  final double card;

  KopimRadiusScale copyWith({double? card}) {
    return KopimRadiusScale(card: card ?? this.card);
  }

  static KopimRadiusScale lerp(
    KopimRadiusScale current,
    KopimRadiusScale target,
    double t,
  ) {
    return KopimRadiusScale(
      card: lerpDouble(current.card, target.card, t) ?? current.card,
    );
  }
}

class KopimIconSizes {
  const KopimIconSizes({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;

  KopimIconSizes copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
  }) {
    return KopimIconSizes(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
    );
  }

  static KopimIconSizes lerp(
    KopimIconSizes current,
    KopimIconSizes target,
    double t,
  ) {
    return KopimIconSizes(
      xs: lerpDouble(current.xs, target.xs, t) ?? current.xs,
      sm: lerpDouble(current.sm, target.sm, t) ?? current.sm,
      md: lerpDouble(current.md, target.md, t) ?? current.md,
      lg: lerpDouble(current.lg, target.lg, t) ?? current.lg,
      xl: lerpDouble(current.xl, target.xl, t) ?? current.xl,
    );
  }
}

extension KopimThemeDataX on ThemeData {
  KopimSpecialSurfaces get kopimSpecialSurfaces =>
      extension<KopimSpecialSurfaces>() ?? KopimSpecialSurfaces.fallback;

  KopimLayout get kopimLayout =>
      extension<KopimLayout>() ?? KopimLayout.fallback;
}

extension KopimThemeContextX on BuildContext {
  KopimSpecialSurfaces get kopimSpecialSurfaces =>
      Theme.of(this).kopimSpecialSurfaces;

  KopimLayout get kopimLayout => Theme.of(this).kopimLayout;
}
