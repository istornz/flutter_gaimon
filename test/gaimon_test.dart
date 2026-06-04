import 'package:flutter_test/flutter_test.dart';
import 'package:gaimon/gaimon.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Gaimon Multi-platform Safety Tests', () {
    test('canSupportsHaptic returns false on unsupported platform (macOS/test environment)', () async {
      final supportsHaptic = await Gaimon.canSupportsHaptic;
      expect(supportsHaptic, isFalse);
    });

    test('calling haptic actions does not throw on unsupported platforms', () {
      expect(() => Gaimon.selection(), returnsNormally);
      expect(() => Gaimon.error(), returnsNormally);
      expect(() => Gaimon.success(), returnsNormally);
      expect(() => Gaimon.warning(), returnsNormally);
      expect(() => Gaimon.heavy(), returnsNormally);
      expect(() => Gaimon.medium(), returnsNormally);
      expect(() => Gaimon.light(), returnsNormally);
      expect(() => Gaimon.rigid(), returnsNormally);
      expect(() => Gaimon.soft(), returnsNormally);
      expect(() => Gaimon.patternFromData('{}'), returnsNormally);
      expect(() => Gaimon.patternFromWaveForm([100], [128], false), returnsNormally);
      expect(() => Gaimon.stop(), returnsNormally);
    });
  });
}
