class AhapConstants {
  static AhapKeys keys = AhapKeys();

  /// How long a `HapticTransient` event drives the motor on Android, in seconds.
  ///
  /// AHAP gives a transient no duration: iOS plays it as a single short tap. A longer
  /// drive at constant amplitude is felt as a buzz rather than a tap.
  static double transientEventDuration = 0.02;
  static double curveFrequency = 0.01;
}

class AhapKeys {
  final String parameterId = 'ParameterID';
  final String parameterValue = 'ParameterValue';

  final String event = 'Event';
  final String parameter = 'Parameter';
  final String parameterCurve = 'ParameterCurve';
  final String parameterCurveControlPoints = 'ParameterCurveControlPoints';

  final String time = 'Time';
  final String eventType = 'EventType';
  final String eventDuration = 'EventDuration';
  final String eventParameters = 'EventParameters';
  final String hapticIntensity = 'HapticIntensity';
  final String hapticIntensityControl = 'HapticIntensityControl';
  final String hapticSharpness = 'HapticSharpness';
  final String hapticSharpnessControl = 'HapticSharpnessControl';
  final String hapticContinuous = 'HapticContinuous';
}
