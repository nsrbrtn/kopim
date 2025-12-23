import 'dart:html' as html;

bool isWebSafariImpl() {
  final String ua = html.window.navigator.userAgent;
  final bool isIosDevice =
      ua.contains('iPhone') || ua.contains('iPad') || ua.contains('iPod');
  final bool isSafari = ua.contains('Safari') &&
      !ua.contains('Chrome') &&
      !ua.contains('CriOS') &&
      !ua.contains('FxiOS') &&
      !ua.contains('EdgiOS');
  return isIosDevice && isSafari;
}
