import 'package:com.tara.passenger/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatMoney', () {
    test('dollars, always with cents', () {
      expect(formatMoney(0.3), '\$0.30');
      expect(formatMoney(0.5), '\$0.50');
      expect(formatMoney(1), '\$1.00');
      expect(formatMoney(12.346), '\$12.35');
    });

    test('thousands are grouped', () {
      expect(formatMoney(1234.5), '\$1,234.50');
    });

    test('zero is written, not left blank', () {
      expect(formatMoney(0), '\$0.00');
    });
  });

  group('roundToCents', () {
    test('keeps the cents a whole-unit rounding would lose', () {
      expect(roundToCents(1.7), 1.7);
      expect(roundToCents(1.704), 1.7);
      expect(roundToCents(1.706), 1.71);
    });

    test('a whole amount stays whole', () {
      expect(roundToCents(3), 3.0);
    });
  });
}
