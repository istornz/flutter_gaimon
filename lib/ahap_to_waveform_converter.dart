import 'dart:convert';
import 'dart:math';

import 'package:gaimon/extensions/time_extension.dart';
import 'package:gaimon/models/ahap_event.dart';
import 'package:gaimon/models/waveform.dart';

List<AhapEvent> parseAhapEventsFromJson(String ahap) {
  List<AhapEvent> ahapEvents = [];

  //parse ahap json
  Map<String, dynamic> ahapJson;

  try {
    ahapJson = json.decode(ahap);

    List events = ahapJson['Pattern'] as List;

    for (var event in events) {
      Map<String, dynamic> eventMap = event as Map<String, dynamic>;
      List<AhapEvent> ahapEvent = AhapEvent.fromMap(eventMap);
      ahapEvents.addAll(ahapEvent);
    }

    return ahapEvents;
  } catch (e) {
    throw Exception('Invalid AHAP JSON $e');
  }
}

Waveform createWaveformFromAhapEvents(List<AhapEvent> input) {
  List<int> timings = [];
  List<int> amplitudes = [];
  bool repeat = false;

  // split input events into parameters and events
  input.sort((a, b) => a.time.compareTo(b.time));

  List<AhapEvent> ahapEvents = input
      .where((element) => element.type == AhapEventType.hapticEvent)
      .toList();

  List<AhapEvent> parameters = input
      .where((element) => element.type == AhapEventType.hapticParameter)
      .toList();

  // find where all cuts in events are
  List<int> borders = [0];
  for (var event in input) {
    borders.add(event.time.toMs());
    borders.add((event.time + event.duration).toMs());
  }

  borders = borders.toSet().toList()..sort();

  for (int i = 0; i < borders.length - 1; i++) {
    int start = borders[i];
    int end = borders[i + 1];

    List<AhapEvent> filteredEvents = ahapEvents
        .where((element) =>
            element.time.toMs() < end &&
            (element.time + element.duration).toMs() > start)
        .toList();

    timings.add(end - start);
    if (filteredEvents.isEmpty) {
      amplitudes.add(0);
    } else {
      filteredEvents.sort((a, b) => a.intensity.compareTo(b.intensity));
      amplitudes.add(min(255, filteredEvents.last.intensity * 255).round());
    }
  }

  // After creating all seperate events, we now need to apply the paremeters. We need to make cuts in the waveform where the parameters change
  // How to apply parameters according to the AHAP standard:
  //  For haptic intensity and audio volume, the final property value is equal to the original event parameter value multiplied by the dynamic parameter value.
  //  For all other parameters, the final property value is equal to the dynamic parameter value added to the original event parameter value.
  //  In both cases, the resulting value is limited to the range with minimum and maximum values corresponding to the specified event parameter.
  //  https://developer.apple.com/documentation/corehaptics/chhapticdynamicparameter
  // We will only support haptic intensity for now, as we can only pass amplitude to the waveform

  var time = 0;

  for (int i = 0; i < timings.length - 1; i++) {
    var timing = timings[i];
    var amplitude = amplitudes[i];

    time += timing;
    // find matching parameters for this timing
    AhapEvent? parameter =
        parameters.where((element) => element.time.toMs() <= time).lastOrNull;

    // apply parameter to amplitude
    if (parameter != null) {
      amplitudes[i] =
          max(0, min(255, (amplitude * parameter.intensity).round()));
    }
  }

  return Waveform(
    timings: timings,
    amplitudes: amplitudes,
    repeat: repeat,
  );
}

Waveform ahapToWaveform(String ahap) {
  try {
    List<AhapEvent> ahapEvents = parseAhapEventsFromJson(ahap);
    return createWaveformFromAhapEvents(ahapEvents);
  } catch (e) {
    throw Exception('Invalid AHAP JSON');
  }
}
