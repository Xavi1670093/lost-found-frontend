import 'package:flutter_test/flutter_test.dart';
import 'package:unilost_found/shared/utils/center_utils.dart';

void main() {
  group('CenterUtils.normalizeCenterId', () {
    test('normalizes scalar center ids', () {
      expect(CenterUtils.normalizeCenterId(' UAB '), 'uab');
      expect(CenterUtils.normalizeCenterId('campus_2'), 'campus_2');
      expect(CenterUtils.normalizeCenterId('campus-2'), 'campus-2');
    });

    test('falls back for missing or unsafe values', () {
      expect(CenterUtils.normalizeCenterId(null), 'uab');
      expect(CenterUtils.normalizeCenterId(''), 'uab');
      expect(CenterUtils.normalizeCenterId('uab campus'), 'uab');
      expect(CenterUtils.normalizeCenterId({'id': 'user-1'}), 'uab');
    });

    test('extracts center id from user profile maps', () {
      expect(
        CenterUtils.normalizeCenterId({
          'id': 'user-1',
          'center_id': 'UAB',
          'fcm_tokens': {'token': true},
        }),
        'uab',
      );

      expect(
        CenterUtils.normalizeCenterId({'ID': 'user-1', 'CENTER_ID': 'UAB'}),
        'uab',
      );
    });
  });
}
