import 'dart:io';

import 'package:flutter/services.dart';

class ExactAlarmPermissionService {
  ExactAlarmPermissionService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName);

  static const String _channelName = 'ru.qmodo.kopim/exact_alarm';
  final MethodChannel _channel;

  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) {
      return true;
    }
    try {
      final bool? granted = await _channel.invokeMethod<bool>(
        'canScheduleExactAlarms',
      );
      return granted ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> openExactAlarmSettings() async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      final bool? started = await _channel.invokeMethod<bool>(
        'openExactAlarmSettings',
      );
      return started ?? false;
    } on PlatformException {
      return false;
    }
  }
}
