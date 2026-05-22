import 'package:flutter_test/flutter_test.dart';
import 'package:unilost_found/shared/utils/center_utils.dart';

void main() {
  group('CenterUtils.normalizeCenterId', () {
    test('normalizes valid string ids', () {
      expect(CenterUtils.normalizeCenterId(' UAB '), 'uab');
    });

    test('extracts nested center_id from corrupted map values', () {
      final value = {
        'id': 'user-uid',
        'center_id': 'UAB',
        'settings': {'language': 'es'},
      };

      expect(CenterUtils.normalizeCenterId(value), 'uab');
    });

    test('falls back instead of stringifying invalid values', () {
      expect(CenterUtils.normalizeCenterId({'id': 'user-uid'}), 'uab');
      expect(CenterUtils.normalizeCenterId('{center_id: uab}'), 'uab');
    });
  });
}
