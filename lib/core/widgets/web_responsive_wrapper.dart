import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Виджет-обертка для ограничения ширины приложения на веб-платформе
/// и десктопах. Позволяет избежать чрезмерного растягивания интерфейса
/// на широкоформатных мониторах.
class WebResponsiveWrapper extends StatelessWidget {
  const WebResponsiveWrapper({
    required this.child,
    this.maxWidth = 600,
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

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth <= maxWidth) {
          return child;
        }

        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: ClipRect(child: child),
            ),
          ),
        );
      },
    );
  }
}
