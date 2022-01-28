import 'dart:async';

import 'package:flutter/services.dart';

class Gaimon {
  static const MethodChannel _channel = MethodChannel('gaimon');

  /// check if the device can vibrate or not
  static Future<bool> get canSupportsHaptic async {
    return await _channel.invokeMethod('canSupportsHaptic');
  }

  /// generate a selection impact vibration
  static void selection() => _channel.invokeMethod('selection');

  /// generate an error impact vibration
  static void error() => _channel.invokeMethod('error');

  /// generate a success impact vibration
  static void success() => _channel.invokeMethod('success');

  /// generate a warning impact vibration
  static void warning() => _channel.invokeMethod('warning');

  /// generate a heavy impact vibration
  static void heavy() => _channel.invokeMethod('heavy');

  /// generate a medium impact vibration
  static void medium() => _channel.invokeMethod('medium');

  /// generate a light impact vibration
  static void light() => _channel.invokeMethod('light');

  /// generate a rigid impact vibration
  static void rigid() => _channel.invokeMethod('rigid');

  /// generate a soft impact vibration
  static void soft() => _channel.invokeMethod('soft');

  /// generate a custom pattern impact vibration
  static void patternFromData(String data) => _channel.invokeMethod(
        'pattern',
        {
          'data': data,
        },
      );
}
