import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Describes the widgets that compose a single tab in the main navigation shell.
class NavigationTabContent {
  const NavigationTabContent({
    this.appBarBuilder,
    required this.bodyBuilder,
    this.floatingActionButtonBuilder,
    this.navigatorKey,
    this.secondaryBodyBuilder,
  });

  final PreferredSizeWidget? Function(BuildContext context, WidgetRef ref)?
  appBarBuilder;
  final Widget Function(BuildContext context, WidgetRef ref) bodyBuilder;
  final Widget? Function(BuildContext context, WidgetRef ref)?
  floatingActionButtonBuilder;
  final GlobalKey<NavigatorState>? navigatorKey;
  final Widget? Function(BuildContext context, WidgetRef ref)?
  secondaryBodyBuilder;
}
