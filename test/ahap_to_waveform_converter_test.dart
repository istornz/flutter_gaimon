// generate tests for ahap_to_waveform_converter.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:gaimon/ahap_to_waveform_converter.dart';
import 'package:gaimon/models/ahap_event.dart';

import 'test_data/ahap_heartbeat.dart';

void main() {
  group('JSON parsing', () {
    test('parseAhapEventsFromJson', () {
      const ahap = '''
    {
      "Pattern": [
        {
          "Event": {
            "Time": 0.0,
            "EventType": "HapticContinuous",
            "EventDuration": 0.1,
            "EventParameters": [
              {
                "ParameterID": "HapticIntensity",
                "ParameterValue": 0.5
              },
              {
                "ParameterID": "HapticSharpness",
                "ParameterValue": 0.5
              }
            ]
          }
        },
        {
          "Event": {
            "Time": 0.1,
            "EventType": "HapticContinuous",
            "EventDuration": 0.1,
            "EventParameters": [
              {
                "ParameterID": "HapticIntensity",
                "ParameterValue": 0.5
              },
              {
                "ParameterID": "HapticSharpness",
                "ParameterValue": 0.5
              }
            ]
          }
        }
      ]
    }
    ''';

      final ahapEvents = parseAhapEventsFromJson(ahap);
      expect(ahapEvents.length, 2);
      expect(ahapEvents[0].time, 0.0);
      expect(ahapEvents[0].duration, 0.1);
      expect(ahapEvents[0].intensity, 0.5);
      expect(ahapEvents[0].sharpness, 0.5);

      expect(ahapEvents[1].time, 0.1);
      expect(ahapEvents[1].duration, 0.1);
      expect(ahapEvents[1].intensity, 0.5);
      expect(ahapEvents[1].sharpness, 0.5);
    });

    test('parseAhapEvents from Large Files', () {
      final ahapEvents = parseAhapEventsFromJson(ahapHeartbeat);
      expect(ahapEvents.length, 82);
    });
  });

  group('Waveform creation', () {
    test('createWaveformFromAhapEvents', () {
      final ahapEvents = [
        AhapEvent(time: 0.0, duration: 0.1, intensity: 0.5, sharpness: 0.5),
        AhapEvent(time: 0.1, duration: 0.1, intensity: 0.5, sharpness: 0.5),
      ];

      final waveform = createWaveformFromAhapEvents(ahapEvents);
      expect(waveform.timings.length, 2);
      expect(waveform.timings[0], 100);
      expect(waveform.timings[1], 100);
      expect(waveform.amplitudes.length, 2);
      expect(waveform.amplitudes[0], 128);
      expect(waveform.amplitudes[1], 128);
    });

    test('adds an empty AhapEvent if starting time is after current total timing', () {
      final ahapEvents = [
        AhapEvent(time: 0.1, duration: 0.1, intensity: 0.5, sharpness: 0.5),
        AhapEvent(time: 0.3, duration: 0.1, intensity: 0.5, sharpness: 0.5),
      ];

      final waveform = createWaveformFromAhapEvents(ahapEvents);

      expect(waveform.timings.length, 4);
      expect(waveform.timings[0], 100);
      expect(waveform.timings[1], 100);
      expect(waveform.timings[2], 100);
      expect(waveform.timings[3], 100);
      expect(waveform.amplitudes.length, 4);
      expect(waveform.amplitudes[0], 0);
      expect(waveform.amplitudes[1], 128);
      expect(waveform.amplitudes[2], 0);
      expect(waveform.amplitudes[3], 128);
    });

    test('create waveform with overlapping events - higher intensity wins if comes last', () {
      final ahapEvents = [
        AhapEvent(time: 0.0, duration: 0.1, intensity: 0.5, sharpness: 0.5),
        AhapEvent(time: 0.1, duration: 0.1, intensity: 0.5, sharpness: 0.5),
        AhapEvent(time: 0.15, duration: 0.1, intensity: 1, sharpness: 0.5),
      ];

      final waveform = createWaveformFromAhapEvents(ahapEvents);
      expect(waveform.timings.length, 4);
      expect(waveform.timings[0], 100);
      expect(waveform.timings[1], 50);
      expect(waveform.timings[2], 50);
      expect(waveform.timings[3], 50);
      expect(waveform.amplitudes.length, 4);
      expect(waveform.amplitudes[0], 128);
      expect(waveform.amplitudes[1], 128);
      expect(waveform.amplitudes[2], 255);
      expect(waveform.amplitudes[3], 255);
    });

    test('create waveform with overlapping events - higher intensity wins if comes first', () {
      final ahapEvents2 = [
        AhapEvent(time: 0.0, duration: 0.1, intensity: 0.5, sharpness: 0.5),
        AhapEvent(time: 0.1, duration: 0.1, intensity: 1, sharpness: 0.5),
        AhapEvent(time: 0.15, duration: 0.1, intensity: 0.5, sharpness: 0.5),
      ];

      final waveform2 = createWaveformFromAhapEvents(ahapEvents2);
      expect(waveform2.timings.length, 4);
      expect(waveform2.timings[0], 100);
      expect(waveform2.timings[1], 50);
      expect(waveform2.timings[2], 50);
      expect(waveform2.timings[3], 50);

      expect(waveform2.amplitudes.length, 4);
      expect(waveform2.amplitudes[0], 128);
      expect(waveform2.amplitudes[1], 255);
      expect(waveform2.amplitudes[2], 255);
      expect(waveform2.amplitudes[3], 128);
    });
  });
}