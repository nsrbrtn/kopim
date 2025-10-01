import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/features/app_shell/presentation/models/navigation_tab_content.dart';
import 'package:kopim/l10n/app_localizations.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  static const String routeName = '/analytics';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NavigationTabContent content = buildAnalyticsTabContent(context, ref);
    return Scaffold(
      appBar: content.appBarBuilder?.call(context, ref),
      body: content.bodyBuilder(context, ref),
      floatingActionButton: content.floatingActionButtonBuilder?.call(
        context,
        ref,
      ),
    );
  }
}

NavigationTabContent buildAnalyticsTabContent(
  BuildContext context,
  WidgetRef ref,
) {
  final AppLocalizations strings = AppLocalizations.of(context)!;
  return NavigationTabContent(
    appBarBuilder: (BuildContext context, WidgetRef ref) =>
        AppBar(title: Text(strings.analyticsTitle)),
    bodyBuilder: (BuildContext context, WidgetRef ref) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(strings.analyticsComingSoon, textAlign: TextAlign.center),
      ),
    ),
  );
}
