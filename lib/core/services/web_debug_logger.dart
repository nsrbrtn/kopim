import 'package:flutter/foundation.dart';

final ValueNotifier<List<String>> webDebugMessages =
    ValueNotifier<List<String>>(<String>[]);

bool get isWebDebugEnabled =>
    kIsWeb && Uri.base.queryParameters['firebaseDebug'] == '1';

void addWebDebugMessage(String message) {
  if (!isWebDebugEnabled) {
    return;
  }
  final List<String> next = List<String>.from(webDebugMessages.value)
    ..add(message);
  webDebugMessages.value = next;
}
