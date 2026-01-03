import 'package:flutter/material.dart';
import 'package:kopim/features/categories/presentation/utils/category_color_palette.dart';

class AccountCardGradient {
  const AccountCardGradient({
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

final List<AccountCardGradient> kAccountCardGradients = <AccountCardGradient>[
  AccountCardGradient(
    id: 'sunrise',
    colors: <Color>[kCategoryPastelPalette[0], kCategoryPastelPalette[3]],
  ),
  AccountCardGradient(
    id: 'lavender',
    colors: <Color>[kCategoryPastelPalette[7], kCategoryPastelPalette[12]],
  ),
  AccountCardGradient(
    id: 'ocean',
    colors: <Color>[kCategoryPastelPalette[15], kCategoryPastelPalette[18]],
  ),
  AccountCardGradient(
    id: 'mint',
    colors: <Color>[kCategoryPastelPalette[21], kCategoryPastelPalette[25]],
  ),
  AccountCardGradient(
    id: 'sand',
    colors: <Color>[kCategoryPastelPalette[27], kCategoryPastelPalette[31]],
  ),
  AccountCardGradient(
    id: 'citrus',
    colors: <Color>[kCategoryPastelPalette[36], kCategoryPastelPalette[37]],
  ),
  AccountCardGradient(
    id: 'pistachio',
    colors: <Color>[kCategoryPastelPalette[38], kCategoryPastelPalette[39]],
  ),
  AccountCardGradient(
    id: 'lagoon',
    colors: <Color>[kCategoryPastelPalette[40], kCategoryPastelPalette[41]],
  ),
  AccountCardGradient(
    id: 'orchid',
    colors: <Color>[kCategoryPastelPalette[42], kCategoryPastelPalette[43]],
  ),
  AccountCardGradient(
    id: 'latte',
    colors: <Color>[kCategoryPastelPalette[44], kCategoryPastelPalette[45]],
  ),
];

AccountCardGradient? resolveAccountCardGradient(String? id) {
  if (id == null || id.isEmpty) {
    return null;
  }
  for (final AccountCardGradient gradient in kAccountCardGradients) {
    if (gradient.id == id) {
      return gradient;
    }
  }
  return null;
}
