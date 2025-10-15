import 'dart:math' as math;

import 'package:flutter/material.dart';

const double _kMinShareToShowIcon = 0.05;
const double _kIconBadgeExtent = 32;

class AnalyticsChartItem {
  const AnalyticsChartItem({
    required this.key,
    required this.title,
    required this.amount,
    required this.color,
    this.icon,
  });

  final String key;
  final String title;
  final double amount;
  final Color color;
  final IconData? icon;

  double get absoluteAmount => amount.abs();
}

class AnalyticsDonutChart extends StatelessWidget {
  const AnalyticsDonutChart({
    super.key,
    required this.items,
    required this.backgroundColor,
    this.totalAmount,
    this.selectedIndex,
    this.onSegmentSelected,
  });

  final List<AnalyticsChartItem> items;
  final Color backgroundColor;
  final double? totalAmount;
  final int? selectedIndex;
  final ValueChanged<int>? onSegmentSelected;

  static const double _minLabelGap = 4;
  static const double _labelSidePadding = 12;

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
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double size = _resolveSize(constraints);
              final List<_DonutSegment> segments = _buildSegments();
              if (segments.isEmpty) {
                return const SizedBox.shrink();
              }

              final double strokeWidth = math.max(size * 0.18, 12);
              final double canvasRadius = size / 2;
              final double ringRadius = canvasRadius - strokeWidth / 2;
              final double labelRadius = ringRadius + strokeWidth * 0.65;
              final bool baseShowOnlySelected = constraints.maxWidth < 320;
              final bool hasSelection =
                  selectedIndex != null &&
                  selectedIndex! >= 0 &&
                  selectedIndex! < segments.length;
              final bool showOnlySelected =
                  baseShowOnlySelected && hasSelection;
              final int fallbackSelected = hasSelection ? selectedIndex! : 0;

              final int? highlightIndex = hasSelection
                  ? (showOnlySelected ? fallbackSelected : selectedIndex!)
                  : null;
              final List<_IconPlacement> placements = _buildIconPlacements(
                segments: segments,
                size: size,
                labelRadius: labelRadius,
                showOnlySelected: showOnlySelected && highlightIndex != null,
                selectedIndex: highlightIndex ?? 0,
                minGap: _minLabelGap,
                badgeExtent: _kIconBadgeExtent,
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
                      ),
                    ),
                    for (final _IconPlacement placement in placements)
                      Positioned(
                        top: placement.top,
                        left: placement.isRight
                            ? canvasRadius +
                                  ringRadius +
                                  strokeWidth / 2 +
                                  _labelSidePadding
                            : null,
                        right: placement.isRight
                            ? null
                            : canvasRadius +
                                  ringRadius +
                                  strokeWidth / 2 +
                                  _labelSidePadding,
                        child: _CategoryIconBadge(
                          icon: segments[placement.segmentIndex].icon!,
                          isSelected:
                              highlightIndex != null &&
                              placement.segmentIndex == highlightIndex,
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
  });

  final List<AnalyticsChartItem> items;
  final Color backgroundColor;
  final double? totalAmount;
  final int? selectedIndex;
  final ValueChanged<int>? onBarSelected;

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
                  duration: const Duration(milliseconds: 200),
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
                                        isSelected: isSelected,
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
    required this.color,
    required this.startAngle,
    required this.sweepAngle,
    required this.percentage,
    required this.icon,
    required this.canShowIcon,
  });

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
    this.selectedIndex,
  });

  final List<_DonutSegment> segments;
  final double strokeWidth;
  final Color backgroundColor;
  final int? selectedIndex;

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

    for (int index = 0; index < segments.length; index++) {
      final _DonutSegment segment = segments[index];
      final bool isDimmed = selectedIndex != null && index != selectedIndex;
      paint.color = isDimmed
          ? segment.color.withValues(alpha: 0.35)
          : segment.color;
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
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}

class _IconPlacement {
  _IconPlacement({
    required this.segmentIndex,
    required this.isRight,
    required this.baseTop,
  });

  final int segmentIndex;
  final bool isRight;
  final double baseTop;
  double top = 0;
}

List<_IconPlacement> _buildIconPlacements({
  required List<_DonutSegment> segments,
  required double size,
  required double labelRadius,
  required bool showOnlySelected,
  required int selectedIndex,
  required double minGap,
  required double badgeExtent,
}) {
  if (segments.isEmpty) {
    return <_IconPlacement>[];
  }

  final double center = size / 2;
  final List<_IconPlacement> right = <_IconPlacement>[];
  final List<_IconPlacement> left = <_IconPlacement>[];

  for (int index = 0; index < segments.length; index++) {
    final _DonutSegment segment = segments[index];
    if (!segment.canShowIcon || segment.icon == null) {
      continue;
    }
    if (showOnlySelected && index != selectedIndex) {
      continue;
    }
    final double angle = segment.midAngle;
    final bool isRight = math.cos(angle) >= 0;
    final double y = center + math.sin(angle) * labelRadius;
    final _IconPlacement placement = _IconPlacement(
      segmentIndex: index,
      isRight: isRight,
      baseTop: y - badgeExtent / 2,
    );
    (isRight ? right : left).add(placement);
  }

  _resolveIconPositions(right, size, minGap, badgeExtent);
  _resolveIconPositions(left, size, minGap, badgeExtent);

  return <_IconPlacement>[...right, ...left];
}

void _resolveIconPositions(
  List<_IconPlacement> placements,
  double size,
  double minGap,
  double badgeExtent,
) {
  if (placements.isEmpty) {
    return;
  }
  placements.sort(
    (_IconPlacement a, _IconPlacement b) => a.baseTop.compareTo(b.baseTop),
  );

  final double maxTopBound = math.max(0, size - badgeExtent);
  double previousTop = 0;
  for (int i = 0; i < placements.length; i++) {
    final _IconPlacement placement = placements[i];
    double top = placement.baseTop;
    if (i == 0) {
      top = top.clamp(0, maxTopBound);
    } else {
      final double minTop = previousTop + badgeExtent + minGap;
      top = math.max(top, minTop);
      top = math.min(top, maxTopBound);
    }
    placement.top = top;
    previousTop = top;
  }

  for (int i = placements.length - 2; i >= 0; i--) {
    final double nextTop = placements[i + 1].top;
    final double maxTop = nextTop - (badgeExtent + minGap);
    if (placements[i].top > maxTop) {
      placements[i].top = maxTop.clamp(0, maxTopBound);
    }
  }
}

class _CategoryIconBadge extends StatelessWidget {
  const _CategoryIconBadge({required this.icon, required this.isSelected});

  final IconData icon;
  final bool isSelected;

  static const double extent = _kIconBadgeExtent;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final Color background = isSelected
        ? Color.alphaBlend(
            colors.primary.withValues(alpha: 0.16),
            colors.surface,
          )
        : colors.surface;
    final Color borderColor = isSelected
        ? colors.primary
        : colors.outlineVariant;
    final Color iconColor = isSelected
        ? colors.primary
        : colors.onSurfaceVariant;

    return Container(
      width: extent,
      height: extent,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 18, color: iconColor),
    );
  }
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
