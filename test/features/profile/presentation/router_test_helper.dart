import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kopim/l10n/app_localizations.dart';

Widget buildTestAppWithRouter({
  required Widget child,
  List<RouteBase> additionalRoutes = const <RouteBase>[],
  String initialLocation = '/',
}) {
  final GoRouter router = GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(
        path: initialLocation,
        builder: (BuildContext context, GoRouterState state) => child,
      ),
      ...additionalRoutes,
    ],
  );

  return MaterialApp.router(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  );
}

GoRoute mockRoute(String path, {String? text}) {
  return GoRoute(
    path: path,
    builder: (BuildContext context, GoRouterState state) =>
        Scaffold(body: Text(text ?? 'Mock Route: $path')),
  );
}
