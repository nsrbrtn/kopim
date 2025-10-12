import 'dart:io';

import 'package:flutter/services.dart';

class ExactAlarmPermissionService {
  ExactAlarmPermissionService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName);

  static const String _channelName = 'kopim/exact_alarms';
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

  Future<bool> openExactAlarmsSettings() async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      final bool? started = await _channel.invokeMethod<bool>(
        'openExactAlarmsSettings',
      );
      return started ?? false;
    } on PlatformException {
      return false;
    }
  }
}
