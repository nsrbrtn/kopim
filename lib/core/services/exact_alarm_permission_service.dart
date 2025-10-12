import 'dart:io';

import 'package:flutter/services.dart';

class ExactAlarmPermissionService {
  ExactAlarmPermissionService({MethodChannel? channel, bool? isAndroidOverride})
    : _channel = channel ?? const MethodChannel(_channelName),
      _isAndroidOverride = isAndroidOverride;

  static const String _channelName = 'kopim/exact_alarms';
  final MethodChannel _channel;
  final bool? _isAndroidOverride;

  bool get _isAndroid => _isAndroidOverride ?? Platform.isAndroid;

  Future<bool> canScheduleExactAlarms() async {
    if (!_isAndroid) {
      return true;
    }
    try {
      final bool? granted = await _channel.invokeMethod<bool>(
        'canScheduleExactAlarms',
      );
      return granted ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> openExactAlarmsSettings() async {
    if (!_isAndroid) {
      return false;
    }
    try {
      final bool? started = await _channel.invokeMethod<bool>(
        'openExactAlarmsSettings',
      );
      return started ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
