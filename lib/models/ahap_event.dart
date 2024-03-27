import 'package:gaimon/ahap_constants.dart';

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
  static List<AhapEvent> fromMap(Map<String, dynamic> map) {
    if (map.containsKey(AhapConstants.keys.event)) {
      return _mapBasicEvents(map);
    }

    throw Exception('No support yet for this type of event: ${map.keys.first}');
  }

  static List<AhapEvent> _mapBasicEvents(Map<String, dynamic> map) {
    Map<String, dynamic> event = map[AhapConstants.keys.event] as Map<String, dynamic>;

    List parameters = event[AhapConstants.keys.eventParameters] as List;
    Map<String, dynamic>? intensityMap;
    Map<String, dynamic>? sharpnessMap;

    for (var p in parameters) {
      Map<String, dynamic> parameter = p as Map<String, dynamic>;

      if (parameter[AhapConstants.keys.parameterId] == AhapConstants.keys.hapticIntensity) {
        intensityMap = parameter;
      } else if (parameter[AhapConstants.keys.parameterId] == AhapConstants.keys.hapticSharpness) {
        sharpnessMap = parameter;
      }
    }

    double eventDuration;

    if (event[AhapConstants.keys.eventType] == AhapConstants.keys.hapticContinuous) {
      eventDuration = (event[AhapConstants.keys.eventDuration] as num).toDouble();
    } else {
      eventDuration = AhapConstants.transientEventDuration;
    }

    return [
      AhapEvent(
        time: (event[AhapConstants.keys.time] as num).toDouble(),
        duration: eventDuration,
        intensity: intensityMap != null ? (intensityMap[AhapConstants.keys.parameterValue] as num).toDouble() : 0,
        sharpness: sharpnessMap != null ? (sharpnessMap[AhapConstants.keys.parameterValue] as num).toDouble() : 0,
      )
    ];
  }
}
