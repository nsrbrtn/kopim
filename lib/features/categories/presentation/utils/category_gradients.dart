import 'package:flutter/material.dart';
import 'package:kopim/core/utils/helpers.dart';

const String kCategoryGradientPrefix = 'gradient:';

class CategoryGradient {
  const CategoryGradient({
    required this.id,
    required this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  final String id;
  final List<Color> colors;
  final Alignment begin;
  final Alignment end;

  LinearGradient toGradient() =>
      LinearGradient(colors: colors, begin: begin, end: end);

  Color get primaryColor => colors.first;

  Color get sampleColor =>
      Color.lerp(colors.first, colors.last, 0.5) ?? colors.first;
}

class CategoryColorStyle {
  const CategoryColorStyle({this.color, this.gradient});

  final Color? color;
  final CategoryGradient? gradient;

  Color? get sampleColor => gradient?.sampleColor ?? color;

  Gradient? get backgroundGradient => gradient?.toGradient();
}

const List<CategoryGradient> kCategoryGradients = <CategoryGradient>[
  CategoryGradient(
    id: 'apricot',
    colors: <Color>[Color(0xFFFFB07A), Color(0xFFFFF5D4)],
  ),
  CategoryGradient(
    id: 'citrus',
    colors: <Color>[Color(0xFFFFE24D), Color(0xFFFFF7D6)],
  ),
  CategoryGradient(
    id: 'pistachio',
    colors: <Color>[Color(0xFFA5E85E), Color(0xFFD8F8C5)],
  ),
  CategoryGradient(
    id: 'seafoam',
    colors: <Color>[Color(0xFF77E6D7), Color(0xFFD3ECFF)],
  ),
  CategoryGradient(
    id: 'skyline',
    colors: <Color>[Color(0xFF8CC4FF), Color(0xFFE5D8FF)],
  ),
  CategoryGradient(
    id: 'lilac',
    colors: <Color>[Color(0xFFB08CFF), Color(0xFFF5D7FF)],
  ),
  CategoryGradient(
    id: 'blush',
    colors: <Color>[Color(0xFFFF9AC3), Color(0xFFFFE5F2)],
  ),
  CategoryGradient(
    id: 'toffee',
    colors: <Color>[Color(0xFFD8AD76), Color(0xFFFFEAD1)],
  ),
  CategoryGradient(
    id: 'sage',
    colors: <Color>[Color(0xFF8FDAB0), Color(0xFFD7F0E8)],
  ),
  CategoryGradient(
    id: 'sunburst',
    colors: <Color>[Color(0xFFFFB14A), Color(0xFFFFF4B8)],
  ),
];

String encodeCategoryGradientId(String id) => '$kCategoryGradientPrefix$id';

CategoryGradient? resolveCategoryGradient(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  final String trimmed = value.trim();
  if (!trimmed.startsWith(kCategoryGradientPrefix)) {
    return null;
  }
  final String id = trimmed.substring(kCategoryGradientPrefix.length);
  for (final CategoryGradient gradient in kCategoryGradients) {
    if (gradient.id == id) {
      return gradient;
    }
  }
  return null;
}

CategoryColorStyle resolveCategoryColorStyle(String? value) {
  final CategoryGradient? gradient = resolveCategoryGradient(value);
  if (gradient != null) {
    return CategoryColorStyle(gradient: gradient);
  }
  return CategoryColorStyle(color: parseHexColor(value));
}
