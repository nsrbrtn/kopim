import 'dart:html' as html;

bool isWebSafariImpl() {
  final String ua = html.window.navigator.userAgent;
  final bool isIosDevice =
      ua.contains('iPhone') || ua.contains('iPad') || ua.contains('iPod');
  return isIosDevice;
}
