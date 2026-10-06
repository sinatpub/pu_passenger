import 'package:flutter_test/flutter_test.dart';
import 'package:com.tara.passenger/core/utils/fare_estimate.dart';

void main() {
  group('estimateFare', () {
    test('returns the minimum fare for a trip under 1km', () {
      final fee = estimateFare(distanceKm: 0.4, pricePerKm: 2000, minimumFare: 5000);
      expect(fee, 5000.0);
    });

    test('returns the minimum fare for a trip of exactly 1km', () {
      final fee = estimateFare(distanceKm: 1.0, pricePerKm: 2000, minimumFare: 5000);
      expect(fee, 5000.0);
    });

    test('charges pricePerKm for each km past the first', () {
      final fee = estimateFare(distanceKm: 3.0, pricePerKm: 2000, minimumFare: 5000);
      expect(fee, 9000.0);
    });

    test('dollar rates keep their cents', () {
      // (5 - 1) * 0.30 + 0.50 = 1.70. Rounding to a whole unit made it 2.
      final fee = estimateFare(distanceKm: 5, pricePerKm: 0.30, minimumFare: 0.50);
      expect(fee, 1.70);
    });

    test('rounds the final fare to the cent', () {
      // (3.257 - 1) * 0.80 + 1.50 = 3.3056 -> 3.31
      final fee = estimateFare(distanceKm: 3.257, pricePerKm: 0.80, minimumFare: 1.50);
      expect(fee, 3.31);
    });

    test('zero distance still returns the minimum fare', () {
      final fee = estimateFare(distanceKm: 0.0, pricePerKm: 2000, minimumFare: 5000);
      expect(fee, 5000.0);
    });
  });
}
