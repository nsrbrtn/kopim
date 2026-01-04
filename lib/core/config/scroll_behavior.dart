import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// ScrollBehavior, который позволяет пролистывать интерфейс любым устройством ввода.
class KopimScrollBehavior extends MaterialScrollBehavior {
  const KopimScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}
