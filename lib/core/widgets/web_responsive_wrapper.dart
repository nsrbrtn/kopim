import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

const double kDefaultResponsiveMaxWidth = 600;
const double kAccountDetailsResponsiveMaxWidth = 1120;
const String _accountDetailsRoutePath = '/accounts/details';

@visibleForTesting
double resolveResponsiveMaxWidthForLocation(String? location) {
  if (location == null || location.isEmpty) {
    return kDefaultResponsiveMaxWidth;
  }

  final Uri? uri = Uri.tryParse(location);
  final String path = uri?.path ?? location;

  if (path == _accountDetailsRoutePath) {
    return kAccountDetailsResponsiveMaxWidth;
  }

  return kDefaultResponsiveMaxWidth;
}

/// Виджет-обертка для ограничения ширины приложения на веб-платформе
/// и десктопах. Позволяет избежать чрезмерного растягивания интерфейса
/// на широкоформатных мониторах.
class WebResponsiveWrapper extends StatelessWidget {
  const WebResponsiveWrapper({
    required this.child,
    this.maxWidth = kDefaultResponsiveMaxWidth,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    // Применяем ограничение только для веба или десктопных платформ.
    // На мобильных устройствах всегда занимаем весь экран.
    final bool isWidePlatform =
        kIsWeb ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows;

    if (!isWidePlatform) {
      return child;
    }

    final GoRouter? router = GoRouter.maybeOf(context);
    final String? location = router?.routeInformationProvider.value.uri
        .toString();
    final double resolvedMaxWidth = resolveResponsiveMaxWidthForLocation(
      location,
    );
    final double effectiveMaxWidth = resolvedMaxWidth > maxWidth
        ? resolvedMaxWidth
        : maxWidth;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth <= effectiveMaxWidth) {
          return child;
        }

        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
              child: ClipRect(child: child),
            ),
          ),
        );
      },
    );
  }
}
