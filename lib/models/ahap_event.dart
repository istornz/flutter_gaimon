import 'package:gaimon/ahap_constants.dart';

enum AhapEventType { hapticEvent, hapticParameter }

enum AhapParameterType { hapticIntensity, hapticSharpness }

class AhapEvent {
  final double time;
  final double duration;
  final double sharpness;
  final double intensity;

  final AhapEventType type;
  final AhapParameterType? parameterType;

  AhapEvent({
    required this.time,
    required this.duration,
    required this.sharpness,
    required this.intensity,
    this.type = AhapEventType.hapticEvent,
    this.parameterType,
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

    if (map.containsKey(AhapConstants.keys.parameter)) {
      return _mapParameterEvents(map);
    }

    if (map.containsKey(AhapConstants.keys.parameterCurve)) {
      return _mapParameterCurves(map);
    }

    throw Exception('No support yet for this type of event: ${map.keys.first}');
  }

  /* 
  {
      "ParameterCurve" : {
        "Time" : 0.595,
        "ParameterID" : "HapticIntensityControl",
        "ParameterCurveControlPoints" : [
          {
            "Time" : 0,
            "ParameterValue" : 0.876
          },
          {
            "ParameterValue" : 0.419,
            "Time" : 0.165
          },
          {
            "ParameterValue" : 0.355,
            "Time" : 0.262
          },
          {
            "Time" : 1.257,
            "ParameterValue" : 0.735
         },.....
          {
            "Time" : 2.097,
            "ParameterValue" : 0.099
          },
          {
            "Time" : 2.197,
            "ParameterValue" : 0.064
          },
          {
            "Time" : 2.273,
            "ParameterValue" : 0.015
          },
          {
            "Time" : 2.404,
            "ParameterValue" : 0.001
          }
        ]
      }
    },
  */
  static List<AhapEvent> _mapParameterCurves(Map<String, dynamic> map) {
    Map<String, dynamic> parameterCurve =
        map[AhapConstants.keys.parameterCurve] as Map<String, dynamic>;

    double time = (parameterCurve[AhapConstants.keys.time] as num).toDouble();

    List controlPoints =
        parameterCurve[AhapConstants.keys.parameterCurveControlPoints] as List;

    AhapParameterType curveType =
        parameterCurve[AhapConstants.keys.parameterId] ==
                AhapConstants.keys.hapticIntensityControl
            ? AhapParameterType.hapticIntensity
            : AhapParameterType.hapticSharpness;

    List<AhapEvent> events = [];

    /// add every point as long as the time lasts for each point according to [AhapConstants.curveFrequency]
    for (int i = 0; i < controlPoints.length - 1; i++) {
      Map<String, dynamic> point = controlPoints[i];
      Map<String, dynamic> nextPoint = controlPoints[i + 1];

      double pointTime = (point[AhapConstants.keys.time] as num).toDouble();
      double nextPointTime =
          (nextPoint[AhapConstants.keys.time] as num).toDouble();

      double pointValue =
          (point[AhapConstants.keys.parameterValue] as num).toDouble();
      double nextPointValue =
          (nextPoint[AhapConstants.keys.parameterValue] as num).toDouble();
      double pointDuration = nextPointTime - pointTime;

      for (double t = pointTime;
          t < nextPointTime;
          t += AhapConstants.curveFrequency) {
        // this calculates the value of the curve at time t in a linear fashion
        // to-do: implement curve with attack / sustain / release
        double value = pointValue +
            (nextPointValue - pointValue) * (t - pointTime) / pointDuration;

        events.add(
          AhapEvent(
            time: time + t,
            duration: 0,
            intensity:
                curveType == AhapParameterType.hapticIntensity ? value : 0,
            sharpness:
                curveType == AhapParameterType.hapticSharpness ? value : 0,
            type: AhapEventType.hapticParameter,
            parameterType: AhapParameterType.hapticIntensity,
          ),
        );
      }
    }

    return events;
  }

  static List<AhapEvent> _mapParameterEvents(Map<String, dynamic> map) {
    Map<String, dynamic> parameter =
        map[AhapConstants.keys.parameter] as Map<String, dynamic>;

    double time = (parameter[AhapConstants.keys.time] as num).toDouble();
    double value =
        (parameter[AhapConstants.keys.parameterValue] as num).toDouble();

    AhapParameterType type;

    if (parameter[AhapConstants.keys.parameterId] ==
        AhapConstants.keys.hapticIntensityControl) {
      type = AhapParameterType.hapticIntensity;
    } else if (parameter[AhapConstants.keys.parameterId] ==
        AhapConstants.keys.hapticSharpnessControl) {
      type = AhapParameterType.hapticSharpness;
    } else {
      throw Exception(
          'No support yet for this type of parameter: ${parameter[AhapConstants.keys.parameterId]}');
    }

    return [
      AhapEvent(
        time: time,
        duration: 0,
        intensity: type == AhapParameterType.hapticIntensity ? value : 0,
        sharpness: type == AhapParameterType.hapticSharpness ? value : 0,
        type: AhapEventType.hapticParameter,
        parameterType: type,
      )
    ];
  }

  static List<AhapEvent> _mapBasicEvents(Map<String, dynamic> map) {
    Map<String, dynamic> event =
        map[AhapConstants.keys.event] as Map<String, dynamic>;

    List parameters = event[AhapConstants.keys.eventParameters] as List;
    Map<String, dynamic>? intensityMap;
    Map<String, dynamic>? sharpnessMap;

    for (var p in parameters) {
      Map<String, dynamic> parameter = p as Map<String, dynamic>;

      if (parameter[AhapConstants.keys.parameterId] ==
          AhapConstants.keys.hapticIntensity) {
        intensityMap = parameter;
      } else if (parameter[AhapConstants.keys.parameterId] ==
          AhapConstants.keys.hapticSharpness) {
        sharpnessMap = parameter;
      }
    }

    double eventDuration;

    if (event[AhapConstants.keys.eventType] ==
        AhapConstants.keys.hapticContinuous) {
      eventDuration =
          (event[AhapConstants.keys.eventDuration] as num).toDouble();
    } else {
      eventDuration = AhapConstants.transientEventDuration;
    }

    return [
      AhapEvent(
        time: (event[AhapConstants.keys.time] as num).toDouble(),
        duration: eventDuration,
        intensity: intensityMap != null
            ? (intensityMap[AhapConstants.keys.parameterValue] as num)
                .toDouble()
            : 0,
        sharpness: sharpnessMap != null
            ? (sharpnessMap[AhapConstants.keys.parameterValue] as num)
                .toDouble()
            : 0,
        type: AhapEventType.hapticEvent,
      )
    ];
  }
}
