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

    test('rounds the final fare to the nearest whole unit', () {
      // (2.5 - 1) * 333 + 1000 = 1499.5 -> rounds to 1500
      final fee = estimateFare(distanceKm: 2.5, pricePerKm: 333, minimumFare: 1000);
      expect(fee, 1500.0);
    });

    test('zero distance still returns the minimum fare', () {
      final fee = estimateFare(distanceKm: 0.0, pricePerKm: 2000, minimumFare: 5000);
      expect(fee, 5000.0);
    });
  });
}
