import 'dart:math' as math;
import 'dart:ui' as ui show TextDirection;
import 'package:flutter/material.dart';
import 'home_account_icon_badge.dart';

class HomeAccountCardLayout {
  static double estimateHeight(BuildContext context) {
    final TextScaler textScaler = MediaQuery.textScalerOf(context);
    final ThemeData theme = Theme.of(context);
    final double label = _textHeight(
      theme.textTheme.labelSmall ?? const TextStyle(fontSize: 11, height: 1.45),
      textScaler,
    );
    final double title = _textHeight(
      (theme.textTheme.labelSmall ??
              const TextStyle(fontSize: 11, height: 1.45))
          .copyWith(fontSize: 14, height: 20 / 14),
      textScaler,
    );
    final double header = math.max(
      title + 2 + label,
      HomeAccountIconBadge.size,
    );
    final double balance = _textHeight(
      theme.textTheme.displaySmall ??
          theme.textTheme.headlineMedium ??
          const TextStyle(fontSize: 36, height: 44 / 36),
      textScaler,
    );
    final double summaryTitle = _textHeight(
      theme.textTheme.labelSmall ?? const TextStyle(fontSize: 11, height: 1.45),
      textScaler,
    );
    final double summaryValue = _textHeight(
      theme.textTheme.titleSmall ??
          theme.textTheme.bodyLarge ??
          const TextStyle(fontSize: 14),
      textScaler,
    );
    const double padding = 24 * 2;
    const double gaps = 8 + 16 + 8;
    // Карточки копилок и кредитов содержат дополнительные строки/отступы,
    // которые не укладываются в базовую оценку стандартного счета.
    const double contentSafetyBuffer = 12;

    return padding +
        header +
        balance +
        summaryTitle +
        summaryValue +
        gaps +
        contentSafetyBuffer;
  }

  static double _textHeight(TextStyle style, TextScaler textScaler) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: 'Hg', style: style),
      maxLines: 1,
      textDirection: ui.TextDirection.ltr,
      textScaler: textScaler,
    )..layout();
    return painter.height;
  }
}
