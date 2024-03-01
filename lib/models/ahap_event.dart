class AhapEvent {
  final double time;
  final double duration;
  final double sharpness;
  final double intensity;

  AhapEvent({
    required this.time,
    required this.duration,
    required this.sharpness,
    required this.intensity,
  });

  /// Converts a map to an AhapEvent
  // {
  //  "Event": {
  //    "Time": 0.043859649122807015,
  //    "EventType": "HapticContinuous",
  //    "EventDuration": 0.8771929824561403,
  //    "EventParameters": [
  //      {
  //        "ParameterID": "HapticIntensity",
  //        "ParameterValue": 0.9764705882352941
  //      },
  //      {
  //        "ParameterID": "HapticSharpness",
  //        "ParameterValue": 0.9764705882352941
  //      }
  //    ]
  //  }
  //}
  factory AhapEvent.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> event = map['Event'] as Map<String, dynamic>;

    List parameters = event['EventParameters'] as List;
    Map<String, dynamic>? intensityMap;
    Map<String, dynamic>? sharpnessMap;

    for (var p in parameters) {
      Map<String, dynamic> parameter = p as Map<String, dynamic>;

      if (parameter['ParameterID'] == 'HapticIntensity') {
        intensityMap = parameter;
      } else if (parameter['ParameterID'] == 'HapticSharpness') {
        sharpnessMap = parameter;
      }
    }

    // try cast EventDuration to double else use 0
    double eventDuration;

    try {
      eventDuration = (event['EventDuration'] as num).toDouble();
    } catch (e) {
      eventDuration = 0;
    }

    return AhapEvent(
      time: (event['Time'] as num).toDouble(),
      duration: eventDuration,
      intensity: intensityMap != null ? (intensityMap['ParameterValue'] as num).toDouble() : 0,
      sharpness: sharpnessMap != null ? (sharpnessMap['ParameterValue'] as num).toDouble() : 0,
    );
  }
}
