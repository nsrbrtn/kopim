import 'dart:math' as math;

import 'package:flutter/material.dart';

const double _kDonutStartAngle = -math.pi / 2;
const int _kMaxVisibleRings = 4;
const double _kMinRingStroke = 10;
const double _kMaxRingStrokeFactor = 0.18;
const double _kRingGapFactor = 0.012;
const double _kMinRingGap = 3;
const double _kRingOuterPadding = 2;
const double _kInnerHoleFactor = 0.08;
const double _kMinInnerHole = 9;

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
                          final List<_RingGeometry> ringGeometries =
                              _buildRingGeometries(
                                size: size,
                                count: segments.length,
                              );
                          final bool hasSelection =
                              selectedIndex != null &&
                              selectedIndex! >= 0 &&
                              selectedIndex! < segments.length;
                          final int? highlightIndex = hasSelection
                              ? selectedIndex!
                              : null;
                          Widget chart = SizedBox(
                            width: size,
                            height: size,
                            child: CustomPaint(
                              size: Size.square(size),
                              painter: _DonutChartPainter(
                                segments: segments,
                                ringGeometries: ringGeometries,
                                backgroundColor: backgroundColor,
                                selectedIndex: highlightIndex,
                                animationProgress: animationProgress,
                              ),
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
                                  ringGeometries: ringGeometries,
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
    final List<(int index, AnalyticsChartItem item)> sortedItems =
        items.indexed
            .where(
              ((int, AnalyticsChartItem) entry) => entry.$2.absoluteAmount > 0,
            )
            .toList()
          ..sort(
            ((int, AnalyticsChartItem) a, (int, AnalyticsChartItem) b) =>
                b.$2.absoluteAmount.compareTo(a.$2.absoluteAmount),
          );
    final Iterable<(int index, AnalyticsChartItem item)> visibleItems =
        sortedItems.take(_kMaxVisibleRings);

    final List<_DonutSegment> segments = <_DonutSegment>[];
    for (final (int index, AnalyticsChartItem item) in visibleItems) {
      if (item.absoluteAmount <= 0) {
        continue;
      }
      final double share = item.absoluteAmount / total;
      if (share <= 0) {
        continue;
      }
      final double sweep = share * (2 * math.pi);
      segments.add(
        _DonutSegment(
          key: item.key,
          sourceIndex: index,
          color: item.color,
          startAngle: _kDonutStartAngle,
          sweepAngle: sweep,
        ),
      );
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
    this.amountFormatter,
    this.selectedIndex,
    this.onBarSelected,
    this.animate = true,
  });

  final List<AnalyticsChartItem> items;
  final Color backgroundColor;
  final double? totalAmount;
  final String Function(double amount)? amountFormatter;
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
    final List<_BarChartEntry> entries =
        List<_BarChartEntry>.generate(
          items.length,
          (int index) => _BarChartEntry(index: index, item: items[index]),
        )..sort((_BarChartEntry a, _BarChartEntry b) {
          final int byAmount = b.item.absoluteAmount.compareTo(
            a.item.absoluteAmount,
          );
          if (byAmount != 0) {
            return byAmount;
          }
          return a.index.compareTo(b.index);
        });
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (BuildContext context, int i) {
            final _BarChartEntry entry = entries[i];
            final AnalyticsChartItem item = entry.item;
            final double share = item.absoluteAmount <= 0
                ? 0
                : (item.absoluteAmount / computedTotal).clamp(0.0, 1.0);
            final bool isSelected =
                selectedIndex != null && selectedIndex == entry.index;
            final String amountText =
                amountFormatter?.call(item.absoluteAmount) ??
                _defaultAmount(item.absoluteAmount);
            final String percentText = share <= 0
                ? '0%'
                : share * 100 >= 1
                ? '${(share * 100).round()}%'
                : '${(share * 100).toStringAsFixed(1)}%';
            final Widget tile = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _HorizontalCategoryLeading(
                      icon: item.icon ?? Icons.circle,
                      color: item.color,
                      title: item.title,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$amountText • $percentText',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? colors.onSurface
                            : colors.onSurfaceVariant,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    height: 8,
                    color: backgroundColor.withValues(alpha: 0.45),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: share),
                        duration: animate
                            ? const Duration(milliseconds: 380)
                            : Duration.zero,
                        curve: Curves.easeOutCubic,
                        builder:
                            (
                              BuildContext context,
                              double value,
                              Widget? child,
                            ) {
                              return FractionallySizedBox(
                                widthFactor: value.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? item.color
                                        : item.color.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              );
                            },
                      ),
                    ),
                  ),
                ),
              ],
            );

            if (onBarSelected == null) {
              return tile;
            }
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onBarSelected!(entry.index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 2,
                  ),
                  child: tile,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

String _defaultAmount(double amount) {
  final double value = amount.abs();
  if (value >= 1000000000) {
    return '${(value / 1000000000).toStringAsFixed(1)}B';
  }
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  }
  return value.toStringAsFixed(0);
}

class _BarChartEntry {
  const _BarChartEntry({required this.index, required this.item});

  final int index;
  final AnalyticsChartItem item;
}

class _HorizontalCategoryLeading extends StatelessWidget {
  const _HorizontalCategoryLeading({
    required this.icon,
    required this.color,
    required this.title,
  });

  final IconData icon;
  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Expanded(
      child: Row(
        children: <Widget>[
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, size: 14, color: colors.surface),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutSegment {
  const _DonutSegment({
    required this.key,
    required this.sourceIndex,
    required this.color,
    required this.startAngle,
    required this.sweepAngle,
  });

  final String key;
  final int sourceIndex;
  final Color color;
  final double startAngle;
  final double sweepAngle;
}

class _RingGeometry {
  const _RingGeometry({required this.radius, required this.strokeWidth});

  final double radius;
  final double strokeWidth;
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({
    required this.segments,
    required this.ringGeometries,
    required this.backgroundColor,
    required this.animationProgress,
    this.selectedIndex,
  });

  final List<_DonutSegment> segments;
  final List<_RingGeometry> ringGeometries;
  final Color backgroundColor;
  final double animationProgress;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final double progress = animationProgress.clamp(0.0, 1.0);
    final Offset center = size.center(Offset.zero);
    final Paint trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final Paint ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final Paint glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int index = 0; index < segments.length; index++) {
      final _DonutSegment segment = segments[index];
      final _RingGeometry geometry = ringGeometries[index];
      final bool isSelected =
          selectedIndex != null && segment.sourceIndex == selectedIndex;
      final bool isDimmed = selectedIndex != null && !isSelected;
      final Rect rect = Rect.fromCircle(
        center: center,
        radius: geometry.radius,
      );

      trackPaint
        ..strokeWidth = geometry.strokeWidth
        ..color = backgroundColor.withValues(
          alpha: selectedIndex == null ? 0.44 : 0.3,
        );
      canvas.drawArc(rect, 0, 2 * math.pi, false, trackPaint);

      final Color activeColor = isDimmed
          ? segment.color.withValues(alpha: 0.33)
          : segment.color;
      if (!isDimmed) {
        glowPaint
          ..strokeWidth = geometry.strokeWidth * (isSelected ? 1.0 : 0.92)
          ..color = activeColor.withValues(alpha: isSelected ? 0.45 : 0.28)
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            geometry.strokeWidth * 0.75,
          );
        canvas.drawArc(
          rect,
          segment.startAngle,
          segment.sweepAngle * progress,
          false,
          glowPaint,
        );
      }

      ringPaint
        ..strokeWidth = geometry.strokeWidth
        ..color = activeColor;
      canvas.drawArc(
        rect,
        segment.startAngle,
        segment.sweepAngle * progress,
        false,
        ringPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.segments != segments ||
        oldDelegate.ringGeometries != ringGeometries ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}

int? _hitTestSegment({
  required Offset position,
  required List<_DonutSegment> segments,
  required double canvasSize,
  required List<_RingGeometry> ringGeometries,
}) {
  if (segments.isEmpty || ringGeometries.length != segments.length) {
    return null;
  }
  final Offset center = Offset(canvasSize / 2, canvasSize / 2);
  final Offset vector = position - center;
  final double distance = vector.distance;
  double angle = math.atan2(vector.dy, vector.dx);
  angle = _normalizeAngle(angle);

  for (int index = 0; index < segments.length; index++) {
    final _RingGeometry geometry = ringGeometries[index];
    final double innerRadius = geometry.radius - geometry.strokeWidth / 2;
    final double outerRadius = geometry.radius + geometry.strokeWidth / 2;
    if (distance < innerRadius || distance > outerRadius) {
      continue;
    }
    final _DonutSegment segment = segments[index];
    final double start = _normalizeAngle(segment.startAngle);
    final double end = start + segment.sweepAngle;
    double candidate = angle;
    if (candidate < start) {
      candidate += 2 * math.pi;
    }
    if (candidate >= start && candidate <= end) {
      return segment.sourceIndex;
    }
  }
  return null;
}

List<_RingGeometry> _buildRingGeometries({
  required double size,
  required int count,
}) {
  if (count <= 0 || !size.isFinite || size <= 0) {
    return const <_RingGeometry>[];
  }
  final double outerRadius = size / 2 - _kRingOuterPadding;
  final double ringGap = math.max(size * _kRingGapFactor, _kMinRingGap);
  final double minInnerHole = math.max(
    size * _kInnerHoleFactor,
    _kMinInnerHole,
  );
  final double availableThickness =
      (outerRadius - minInnerHole - ringGap * (count - 1)).clamp(
        _kMinRingStroke * count,
        double.infinity,
      );
  final double rawStroke = availableThickness / count;
  final double maxStroke = math.max(
    size * _kMaxRingStrokeFactor,
    _kMinRingStroke,
  );
  final double strokeWidth = rawStroke.clamp(_kMinRingStroke, maxStroke);
  final double firstRadius = outerRadius - strokeWidth / 2;

  final List<_RingGeometry> geometries = <_RingGeometry>[];
  for (int index = 0; index < count; index++) {
    final double radius = math.max(
      firstRadius - index * (strokeWidth + ringGap),
      minInnerHole + strokeWidth / 2,
    );
    geometries.add(_RingGeometry(radius: radius, strokeWidth: strokeWidth));
  }
  return geometries;
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
