import 'package:com.tara.passenger/services/location_imp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatAddressParts', () {
    test('joins the parts, most specific first', () {
      expect(
        formatAddressParts(
            ['Street 271', 'Sangkat Boeung Tumpun', 'Phnom Penh', 'Cambodia']),
        'Street 271, Sangkat Boeung Tumpun, Phnom Penh, Cambodia',
      );
    });

    test('a part given twice is written once, and a blank one not at all',
        () {
      // What the geocoder gave near Chip Mong 271: the place and the street
      // named alike, and no postal code. It read "Near Chip Mong, Near Chip
      // Mong, Khan Mean Chey, Phnom Penh, , កម្ពុជា".
      expect(
        formatAddressParts([
          'Near Chip Mong',
          'Near Chip Mong',
          'Khan Mean Chey',
          'Phnom Penh',
          '',
          'កម្ពុជា',
        ]),
        'Near Chip Mong, Khan Mean Chey, Phnom Penh, កម្ពុជា',
      );
    });

    test('spaces and letter case do not make a part new', () {
      expect(formatAddressParts([' Phnom Penh ', 'phnom penh', null]),
          'Phnom Penh');
    });

    test('nothing usable is no address, not an empty one', () {
      expect(formatAddressParts([null, '', '  ']), isNull);
      expect(formatAddressParts(const []), isNull);
    });
  });
}
