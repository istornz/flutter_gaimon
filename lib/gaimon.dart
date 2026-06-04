import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:gaimon/ahap_to_waveform_converter.dart';

class Gaimon {
  static const MethodChannel _channel = MethodChannel('gaimon');

  static bool get _isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get _isIOS => !kIsWeb && Platform.isIOS;
  static bool get _supportsMethodChannel => _isAndroid || _isIOS;

  /// check if the device can vibrate or not
  static Future<bool> get canSupportsHaptic async {
    if (!_supportsMethodChannel) return false;
    try {
      return await _channel.invokeMethod<bool>('canSupportsHaptic') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// generate a selection impact vibration
  static void selection() => HapticFeedback.selectionClick();

  /// generate an error impact vibration
  static void error() {
    if (!_supportsMethodChannel) return;
    _channel.invokeMethod('error');
  }

  /// generate a success impact vibration
  static void success() {
    if (!_supportsMethodChannel) return;
    _channel.invokeMethod('success');
  }

  /// generate a warning impact vibration
  static void warning() {
    if (!_supportsMethodChannel) return;
    _channel.invokeMethod('warning');
  }

  /// generate a heavy impact vibration
  static void heavy() => HapticFeedback.heavyImpact();

  /// generate a medium impact vibration
  static void medium() => HapticFeedback.mediumImpact();

  /// generate a light impact vibration
  static void light() => HapticFeedback.lightImpact();

  /// generate a rigid impact vibration
  static void rigid() {
    if (!_supportsMethodChannel) return;
    _channel.invokeMethod('rigid');
  }

  /// generate a soft impact vibration
  static void soft() {
    if (!_supportsMethodChannel) return;
    _channel.invokeMethod('soft');
  }

  /// generate a custom pattern impact vibration
  static void patternFromData(String data) {
    if (!_supportsMethodChannel) return;
    if (_isAndroid) {
      _patternFromAhapToWaveform(data);
    } else {
      _channel.invokeMethod('pattern', {'data': data});
    }
  }

  static void _patternFromAhapToWaveform(String data) {
    final waveform = ahapToWaveform(data);
    patternFromWaveForm(waveform.timings, waveform.amplitudes, waveform.repeat);
  }

  /// stop any ongoing vibration
  static void stop() {
    if (!_supportsMethodChannel) return;
    _channel.invokeMethod('stop');
  }

  /// generate a custom pattern impact vibration from waveform (android only)
  static void patternFromWaveForm(
    List<int> timings,
    List<int> amplitudes,
    bool repeat,
  ) {
    if (!_supportsMethodChannel) return;
    _channel.invokeMethod('pattern', {
      'timings': timings,
      'amplitudes': amplitudes,
      'repeat': repeat,
    });
  }
}

