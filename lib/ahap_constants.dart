class AhapConstants {
  static AhapKeys keys = AhapKeys();

  static double transientEventDuration = 0.1;
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
