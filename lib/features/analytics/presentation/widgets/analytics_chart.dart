import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnalyticsChartItem {
  const AnalyticsChartItem({
    required this.title,
    required this.amount,
    required this.color,
  });

  final String title;
  final double amount;
  final Color color;

  double get absoluteAmount => amount.abs();
}

class AnalyticsDonutChart extends StatelessWidget {
  const AnalyticsDonutChart({
    super.key,
    required this.items,
    required this.backgroundColor,
  });

  final List<AnalyticsChartItem> items;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Size biggest = constraints.biggest;
          double size = biggest.shortestSide;
          if (!size.isFinite || size <= 0) {
            size = biggest.longestSide;
          }
          if (!size.isFinite || size <= 0) {
            size = 200;
          }
          final double strokeWidth = math.max(size * 0.18, 12);
          final List<_DonutSegment> segments = _buildSegments();
          final double radius = size / 2;
          final double labelRadius = radius + strokeWidth * 0.4;
          final double alignmentFactor = radius == 0 ? 0 : labelRadius / radius;

          return Center(
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: <Widget>[
                  CustomPaint(
                    size: Size.square(size),
                    painter: _DonutChartPainter(
                      segments: segments,
                      strokeWidth: strokeWidth,
                      backgroundColor: backgroundColor,
                    ),
                  ),
                  for (final _DonutSegment segment in segments)
                    Align(
                      alignment: Alignment(
                        math.cos(segment.midAngle) * alignmentFactor,
                        math.sin(segment.midAngle) * alignmentFactor,
                      ),
                      child: _DonutPercentageLabel(
                        percentage: segment.percentage,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<_DonutSegment> _buildSegments() {
    final double total = items.fold<double>(
      0,
      (double previous, AnalyticsChartItem item) =>
          previous + item.absoluteAmount,
    );
    if (total <= 0) {
      return <_DonutSegment>[];
    }
    double startAngle = -math.pi / 2;
    final List<_DonutSegment> segments = <_DonutSegment>[];
    for (final AnalyticsChartItem item in items) {
      if (item.absoluteAmount <= 0) {
        continue;
      }
      final double sweep = (item.absoluteAmount / total) * (2 * math.pi);
      final double percentage = item.absoluteAmount / total * 100;
      segments.add(
        _DonutSegment(
          color: item.color,
          startAngle: startAngle,
          sweepAngle: sweep,
          percentage: percentage,
        ),
      );
      startAngle += sweep;
    }
    return segments;
  }
}

class _DonutSegment {
  const _DonutSegment({
    required this.color,
    required this.startAngle,
    required this.sweepAngle,
    required this.percentage,
  });

  final Color color;
  final double startAngle;
  final double sweepAngle;
  final double percentage;

  double get midAngle => startAngle + sweepAngle / 2;
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({
    required this.segments,
    required this.strokeWidth,
    required this.backgroundColor,
  });

  final List<_DonutSegment> segments;
  final double strokeWidth;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide / 2 - strokeWidth / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = strokeWidth;

    paint.color = backgroundColor;
    canvas.drawArc(rect, 0, 2 * math.pi, false, paint);

    for (final _DonutSegment segment in segments) {
      paint.color = segment.color;
      canvas.drawArc(
        rect,
        segment.startAngle,
        segment.sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.segments != segments ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

class _DonutPercentageLabel extends StatelessWidget {
  const _DonutPercentageLabel({required this.percentage});

  final double percentage;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color textColor = theme.colorScheme.onSurface;
    final TextStyle style =
        theme.textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ) ??
        TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 12);

    final String formatted = percentage >= 1
        ? '${percentage.round()}%'
        : '${percentage.toStringAsFixed(1)}%';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(formatted, style: style),
      ),
    );
  }
}
