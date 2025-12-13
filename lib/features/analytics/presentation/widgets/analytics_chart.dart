import 'dart:math' as math;

import 'package:flutter/material.dart';

const double _kMinShareToShowIcon = 0.02;
const double _kMinShareToShowPercent = 0.02;
const double _kIconBadgeExtent = 24;

class AnalyticsChartItem {
  const AnalyticsChartItem({
    required this.key,
    required this.title,
    required this.amount,
    required this.color,
    this.icon,
    this.children = const <AnalyticsChartItem>[],
  });

  final String key;
  final String title;
  final double amount;
  final Color color;
  final IconData? icon;
  final List<AnalyticsChartItem> children;

  double get absoluteAmount => amount.abs();

  bool get hasChildren => children.isNotEmpty;
}

class AnalyticsDonutChart extends StatelessWidget {
  const AnalyticsDonutChart({
    super.key,
    required this.items,
    required this.backgroundColor,
    this.totalAmount,
    this.selectedIndex,
    this.onSegmentSelected,
    this.animate = true,
  });

  final List<AnalyticsChartItem> items;
  final Color backgroundColor;
  final double? totalAmount;
  final int? selectedIndex;
  final ValueChanged<int>? onSegmentSelected;
  final bool animate;

  static const double _minLabelGap = 4;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Align(
        alignment: Alignment.center,
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: animate
                ? const Duration(milliseconds: 650)
                : Duration.zero,
            curve: Curves.easeOutCubic,
            builder:
                (BuildContext context, double animationProgress, Widget? _) {
                  return LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          final double size = _resolveSize(constraints);
                          final List<_DonutSegment> segments = _buildSegments();
                          if (segments.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final double strokeWidth = math.max(size * 0.12, 10);
                          final double canvasRadius = size / 2;
                          final Offset center = Offset(
                            canvasRadius,
                            canvasRadius,
                          );
                          final double ringRadius =
                              canvasRadius - strokeWidth / 2;
                          final bool hasSelection =
                              selectedIndex != null &&
                              selectedIndex! >= 0 &&
                              selectedIndex! < segments.length;
                          final int? highlightIndex = hasSelection
                              ? selectedIndex!
                              : null;
                          final List<_CombinedLabel> combinedLabels =
                              _buildCombinedLabels(
                                segments: segments,
                                center: center,
                                radius: ringRadius + strokeWidth * 1.25,
                                selectedIndex: highlightIndex,
                                minGap: _minLabelGap,
                                animationProgress: animationProgress,
                              );

                          Widget chart = SizedBox(
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
                                    selectedIndex: highlightIndex,
                                    animationProgress: animationProgress,
                                  ),
                                ),
                                for (final _CombinedLabel label
                                    in combinedLabels)
                                  Positioned(
                                    left: label.position.dx,
                                    top: label.position.dy,
                                    child: FractionalTranslation(
                                      translation: const Offset(-0.5, -0.5),
                                      child: _CategoryIconBadge(
                                        icon: label.icon,
                                        color: label.color,
                                        percentText: label.text,
                                        isSelected:
                                            highlightIndex != null &&
                                            label.index == highlightIndex,
                                        onTap: onSegmentSelected != null
                                            ? () => onSegmentSelected!(
                                                label.index,
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );

                          if (onSegmentSelected != null) {
                            chart = GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapUp: (TapUpDetails details) {
                                final Offset local = details.localPosition;
                                final int? hit = _hitTestSegment(
                                  position: local,
                                  segments: segments,
                                  canvasSize: size,
                                  ringRadius: ringRadius,
                                  strokeWidth: strokeWidth,
                                );
                                if (hit != null) {
                                  onSegmentSelected!(hit);
                                }
                              },
                              child: chart,
                            );
                          }

                          return Center(child: chart);
                        },
                  );
                },
          ),
        ),
      ),
    );
  }

  double _resolveSize(BoxConstraints constraints) {
    final double maxWidth = constraints.maxWidth.isFinite
        ? constraints.maxWidth
        : constraints.biggest.shortestSide;
    final double maxHeight = constraints.maxHeight.isFinite
        ? constraints.maxHeight
        : constraints.biggest.longestSide;
    double size = maxWidth.isFinite && maxWidth > 0 ? maxWidth : 0;
    if (maxHeight.isFinite && maxHeight > 0) {
      size = size == 0 ? maxHeight : math.min(size, maxHeight);
    }
    if (size <= 0 || !size.isFinite) {
      size = constraints.biggest.shortestSide;
    }
    if (!size.isFinite || size <= 0) {
      size = 200;
    }
    return size;
  }

  List<_DonutSegment> _buildSegments() {
    final double rawTotal = items.fold<double>(
      0,
      (double previous, AnalyticsChartItem item) =>
          previous + item.absoluteAmount,
    );
    final double total = totalAmount ?? rawTotal;
    if (total <= 0) {
      return <_DonutSegment>[];
    }
    double startAngle = -math.pi / 2;
    final List<_DonutSegment> segments = <_DonutSegment>[];
    for (final AnalyticsChartItem item in items) {
      if (item.absoluteAmount <= 0) {
        continue;
      }
      final double share = item.absoluteAmount / total;
      if (share <= 0) {
        continue;
      }
      final double sweep = share * (2 * math.pi);
      final double percentage = share * 100;
      segments.add(
        _DonutSegment(
          key: item.key,
          color: item.color,
          startAngle: startAngle,
          sweepAngle: sweep,
          percentage: percentage,
          icon: item.icon,
          canShowIcon: item.icon != null && share >= _kMinShareToShowIcon,
        ),
      );
      startAngle += sweep;
    }
    return segments;
  }
}

class AnalyticsBarChart extends StatelessWidget {
  const AnalyticsBarChart({
    super.key,
    required this.items,
    required this.backgroundColor,
    this.totalAmount,
    this.selectedIndex,
    this.onBarSelected,
    this.animate = true,
  });

  final List<AnalyticsChartItem> items;
  final Color backgroundColor;
  final double? totalAmount;
  final int? selectedIndex;
  final ValueChanged<int>? onBarSelected;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    final double computedTotal =
        totalAmount ??
        items.fold<double>(
          0,
          (double previous, AnalyticsChartItem item) =>
              previous + item.absoluteAmount,
        );
    if (computedTotal <= 0) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.center,
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double rawHeight = constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : 220;
              final double chartHeight = math.max(rawHeight, 200);
              final double maxBarHeight = math.max(chartHeight - 48, 80);

              final List<Widget> children = <Widget>[];
              final int count = items.length;
              for (int index = 0; index < count; index++) {
                final AnalyticsChartItem item = items[index];
                final double share = item.absoluteAmount <= 0
                    ? 0
                    : (item.absoluteAmount / computedTotal).clamp(0.0, 1.0);
                final bool isSelected =
                    selectedIndex != null && index == selectedIndex;
                final double barHeight = share <= 0
                    ? 4
                    : math.max(maxBarHeight * share, 4);
                final Color barColor = isSelected
                    ? item.color
                    : item.color.withValues(alpha: 0.7);
                Widget bar = AnimatedContainer(
                  duration: animate
                      ? const Duration(milliseconds: 200)
                      : Duration.zero,
                  curve: Curves.easeInOut,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? <BoxShadow>[
                            BoxShadow(
                              color: item.color.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : const <BoxShadow>[],
                  ),
                );
                if (onBarSelected != null) {
                  bar = GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onBarSelected!(index),
                    child: bar,
                  );
                }

                final bool showIcon =
                    item.icon != null && share >= _kMinShareToShowIcon;

                children.add(
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: count > 1 ? 6 : 0,
                      ),
                      child: SizedBox(
                        height: chartHeight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            SizedBox(
                              height: _kIconBadgeExtent,
                              child: Center(
                                child: showIcon
                                    ? _CategoryIconBadge(
                                        icon: item.icon!,
                                        color: item.color,
                                        percentText: '',
                                        isSelected: isSelected,
                                        onTap: onBarSelected != null
                                            ? () => onBarSelected!(index)
                                            : null,
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  widthFactor: 0.6,
                                  child: bar,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: chartHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: children,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DonutSegment {
  const _DonutSegment({
    required this.key,
    required this.color,
    required this.startAngle,
    required this.sweepAngle,
    required this.percentage,
    required this.icon,
    required this.canShowIcon,
  });

  final String key;
  final Color color;
  final double startAngle;
  final double sweepAngle;
  final double percentage;
  final IconData? icon;
  final bool canShowIcon;

  double get midAngle => startAngle + sweepAngle / 2;
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({
    required this.segments,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.animationProgress,
    this.selectedIndex,
  });

  final List<_DonutSegment> segments;
  final double strokeWidth;
  final Color backgroundColor;
  final double animationProgress;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final double progress = animationProgress.clamp(0.0, 1.0);
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide / 2 - strokeWidth / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    paint.color = backgroundColor;
    canvas.drawArc(rect, 0, 2 * math.pi, false, paint);

    for (int index = 0; index < segments.length; index++) {
      final _DonutSegment segment = segments[index];
      final bool isDimmed = selectedIndex != null && index != selectedIndex;
      paint.color = isDimmed
          ? segment.color.withValues(alpha: 0.35)
          : segment.color;
      canvas.drawArc(
        rect,
        segment.startAngle,
        segment.sweepAngle * progress,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.segments != segments ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}

class _CategoryIconBadge extends StatelessWidget {
  const _CategoryIconBadge({
    required this.icon,
    required this.color,
    required this.percentText,
    required this.isSelected,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String percentText;
  final bool isSelected;
  final VoidCallback? onTap;

  static const double extent = _kIconBadgeExtent;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color base = isSelected ? color : color.withValues(alpha: 0.5);
    final Color textColor = theme.colorScheme.surface.withValues(
      alpha: isSelected ? 0.95 : 0.8,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
          decoration: BoxDecoration(
            color: base.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: base.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: extent,
                height: extent,
                decoration: BoxDecoration(
                  color: base,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1.1,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: theme.colorScheme.surface),
              ),
              const SizedBox(width: 6),
              Text(
                percentText,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CombinedLabel {
  _CombinedLabel({
    required this.index,
    required this.position,
    required this.text,
    required this.color,
    required this.icon,
    required this.highlighted,
  });

  final int index;
  final Offset position;
  final String text;
  final Color color;
  final IconData icon;
  final bool highlighted;
}

List<_CombinedLabel> _buildCombinedLabels({
  required List<_DonutSegment> segments,
  required Offset center,
  required double radius,
  required int? selectedIndex,
  required double minGap,
  required double animationProgress,
}) {
  if (segments.isEmpty) {
    return <_CombinedLabel>[];
  }
  final List<_CombinedLabel> labels = <_CombinedLabel>[];
  final double clampedProgress = animationProgress.clamp(0.0, 1.0);
  double previousY = double.negativeInfinity;
  for (int i = 0; i < segments.length; i++) {
    final _DonutSegment segment = segments[i];
    final double percent = segment.percentage;
    final bool showPercent = percent >= _kMinShareToShowPercent * 100;
    if (!segment.canShowIcon && !showPercent) {
      continue;
    }
    if (clampedProgress < 0.2) {
      continue;
    }
    final double angle = segment.midAngle;
    final double effectiveRadius = radius * clampedProgress;
    final double dx = center.dx + math.cos(angle) * effectiveRadius;
    double dy = center.dy + math.sin(angle) * effectiveRadius;

    final double gap = (minGap * clampedProgress).clamp(2, minGap);
    if ((dy - previousY).abs() < gap) {
      dy = previousY + gap;
    }
    previousY = dy;

    final bool highlighted = selectedIndex != null && selectedIndex == i;
    final String text = showPercent && clampedProgress > 0.4
        ? (percent >= 1
              ? '${percent.round()}%'
              : '${percent.toStringAsFixed(1)}%')
        : '';

    labels.add(
      _CombinedLabel(
        index: i,
        position: Offset(dx, dy),
        text: text,
        color: segment.color,
        icon: segment.icon ?? Icons.circle,
        highlighted: highlighted,
      ),
    );
  }
  return labels;
}

int? _hitTestSegment({
  required Offset position,
  required List<_DonutSegment> segments,
  required double canvasSize,
  required double ringRadius,
  required double strokeWidth,
}) {
  if (segments.isEmpty) {
    return null;
  }
  final Offset center = Offset(canvasSize / 2, canvasSize / 2);
  final Offset vector = position - center;
  final double distance = vector.distance;
  final double innerRadius = ringRadius - strokeWidth / 2;
  final double outerRadius = ringRadius + strokeWidth / 2;
  if (distance < innerRadius || distance > outerRadius) {
    return null;
  }

  double angle = math.atan2(vector.dy, vector.dx);
  angle = _normalizeAngle(angle);

  for (int index = 0; index < segments.length; index++) {
    final _DonutSegment segment = segments[index];
    final double start = _normalizeAngle(segment.startAngle);
    final double end = start + segment.sweepAngle;
    double candidate = angle;
    if (candidate < start) {
      candidate += 2 * math.pi;
    }
    if (candidate >= start && candidate <= end) {
      return index;
    }
  }
  return null;
}

double _normalizeAngle(double angle) {
  const double twoPi = 2 * math.pi;
  while (angle < 0) {
    angle += twoPi;
  }
  while (angle >= twoPi) {
    angle -= twoPi;
  }
  return angle;
}
