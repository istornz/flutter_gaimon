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

Waveform createWaveformFromAhapEvents(List<AhapEvent> ahapEvents) {
  List<int> timings = [];
  List<int> amplitudes = [];
  bool repeat = false;

  ahapEvents.sort((a, b) => a.time.compareTo(b.time));

  // find where all cuts in events are
  List<int> borders = [0];
  for (var event in ahapEvents) {
    borders.add(event.time.toMs());
    borders.add((event.time + event.duration).toMs());
  }

  borders = borders.toSet().toList()..sort();

  for (int i = 0; i < borders.length - 1; i++) {
    int start = borders[i];
    int end = borders[i + 1];

    List<AhapEvent> filteredEvents = ahapEvents
        .where((element) => element.time.toMs() < end && (element.time + element.duration).toMs() > start)
        .toList();

    timings.add(end - start);
    if (filteredEvents.isEmpty) {
      amplitudes.add(0);
    } else {
      filteredEvents.sort((a, b) => a.intensity.compareTo(b.intensity));
      amplitudes.add(min(255, filteredEvents.last.intensity * 255).round());
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
