// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

bool isWebSafariImpl() {
  final String ua = html.window.navigator.userAgent;
  final bool isIosDevice =
      ua.contains('iPhone') || ua.contains('iPad') || ua.contains('iPod');
  // На iOS Firebase Web может падать при доступе к Firebase.apps.
  // Возвращаем true для любых iOS браузеров, чтобы использовать обход.
  return isIosDevice;
}
