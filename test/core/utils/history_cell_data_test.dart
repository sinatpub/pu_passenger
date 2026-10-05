import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:com.tara.passenger/core/utils/history_cell_data.dart';
import 'package:com.tara.passenger/core/utils/status_util.dart';
import 'package:com.tara.passenger/data/models/history_booking_model.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

void main() {
  group('historyInvoice', () {
    test('prefixes the invoice id', () {
      expect(historyInvoice(2041), 'INV-2041');
    });

    test('a missing id degrades, never "INV-null"', () {
      expect(historyInvoice(null), '—');
    });
  });

  group('historyDestination — a cancelled trip may have none (S1 Risk)', () {
    test('passes a real destination through', () {
      expect(historyDestination('Aeon Mall'), 'Aeon Mall');
    });

    test('returns null so the row is dropped, not filled with "Unknown"', () {
      expect(historyDestination(null), isNull);
      expect(historyDestination('   '), isNull);
      expect(historyDestination('null'), isNull);
    });
  });

  group('historyDate — never takes the list down', () {
    test('formats an ISO timestamp', () {
      expect(historyDate('2026-09-11T09:41:00'), '11 Sep 2026, 9:41 AM');
    });

    test('a null or malformed timestamp degrades to an em dash', () {
      // The card this replaced called `DateTime.parse("${data?.createdAt}")`
      // unguarded, which throws on every one of these.
      expect(historyDate(null), '—');
      expect(historyDate('not a date'), '—');
      expect(historyDate('null'), '—');
      expect(historyDate(''), '—');
    });
  });

  group('historyDuration', () {
    test('a missing duration degrades to an em dash', () {
      expect(historyDuration(null), '—');
      expect(historyDuration('  '), '—');
      expect(historyDuration('null'), '—');
    });
  });

  group('status helpers', () {
    test('completed is the only completed status', () {
      expect(isCompletedHistory(BookingStatus.completed), isTrue);
      expect(isCompletedHistory(BookingStatus.cancel), isFalse);
      expect(isCompletedHistory(null), isFalse);
    });

    test('the badge label is localised, not hardcoded English', () {
      expect(historyStatusLabel(BookingStatus.completed), AppLocale.completed);
      expect(historyStatusLabel(BookingStatus.cancel), AppLocale.cancelled);
    });
  });

  group('historyCellData', () {
    test('maps a full payload', () {
      final item = historyCellData(
        Datum(
          status: BookingStatus.completed,
          createdAt: '2026-09-11T09:41:00',
          startAddress: 'No. 128, St. 271',
          endAddress: 'Aeon Mall',
          driver: Driver(name: 'Sok Dara'),
          payment: Payment(
            invoiceId: 2041,
            amount: '12000',
            distance: '6.1 km',
          ),
        ),
      );

      expect(item.invoice, 'INV-2041');
      expect(item.driver, 'Sok Dara');
      expect(item.initials, 'SD');
      expect(item.amount, '12,000 ${AppLocale.khmerCurrency}');
      expect(item.from, 'No. 128, St. 271');
      expect(item.to, 'Aeon Mall');
      expect(item.distance, '6.1 km');
    });

    test('money fails loudly: an unparseable amount degrades, not zeroes', () {
      final item = historyCellData(
        Datum(payment: Payment(amount: 'abc')),
      );
      expect(item.amount, '—');
    });

    test('a cancelled trip with no destination leaves `to` null', () {
      final item = historyCellData(
        Datum(status: BookingStatus.cancel, startAddress: 'No. 128'),
      );
      expect(item.to, isNull);
      expect(item.from, 'No. 128');
    });

    test('an entirely empty payload degrades on every field', () {
      final item = historyCellData(null);

      expect(item.invoice, '—');
      expect(item.driver, AppLocale.unKnown);
      expect(item.initials, '');
      expect(item.amount, '—');
      expect(item.from, '—');
      expect(item.to, isNull);
      expect(item.distance, '—');
      expect(item.duration, '—');
    });
  });

  group('historyCardDate — the card headline', () {
    final now = DateTime(2026, 10, 5);

    test('a trip from this year drops the year', () {
      expect(historyCardDate('2026-10-05T14:59:00', now: now),
          '5 Oct, 2:59 PM');
    });

    test('a trip from another year keeps it', () {
      expect(historyCardDate('2025-12-31T09:05:00', now: now),
          '31 Dec 2025, 9:05 AM');
    });

    test('a null or malformed timestamp degrades to an em dash', () {
      expect(historyCardDate(null, now: now), '—');
      expect(historyCardDate('not a date', now: now), '—');
      expect(historyCardDate('null', now: now), '—');
    });
  });

  group('historyDistanceShort', () {
    test('rounds kilometres to one decimal', () {
      expect(historyDistanceShort('10.25 km'), '10.3 km');
      expect(historyDistanceShort('3.40 km'), '3.4 km');
      expect(historyDistanceShort('6 km'), '6.0 km');
    });

    test('anything else is shown as sent; nothing is null', () {
      expect(historyDistanceShort('850 m'), '850 m');
      expect(historyDistanceShort(null), isNull);
      expect(historyDistanceShort('  '), isNull);
      expect(historyDistanceShort('null'), isNull);
    });
  });

  group('historyDurationShort', () {
    test('rounds to the minute', () {
      expect(historyDurationShort('27 mins 57 seconds'), '28 min');
      expect(historyDurationShort('9 mins 16 seconds'), '9 min');
      expect(historyDurationShort('18 mins'), '18 min');
    });

    test('never shows less than a minute', () {
      expect(historyDurationShort('0 mins 20 seconds'), '1 min');
    });

    test('an hour or more shows hours and minutes', () {
      expect(historyDurationShort('1 hours 5 mins'), '1 h 5 min');
      expect(historyDurationShort('2 hours 0 mins'), '2 h');
      expect(historyDurationShort('59 mins 40 seconds'), '1 h');
    });

    test('another shape is shown as sent; nothing is null', () {
      expect(historyDurationShort('about half an hr'), 'about half an hr');
      expect(historyDurationShort(null), isNull);
      expect(historyDurationShort('null'), isNull);
    });
  });

  group('historyTripSummary', () {
    test('distance and time, joined', () {
      expect(
        historyTripSummary(
            distance: '10.25 km', duration: '27 mins 57 seconds'),
        '10.3 km · 28 min',
      );
    });

    test('whichever one there is; null with neither', () {
      expect(historyTripSummary(distance: '3.40 km'), '3.4 km');
      expect(historyTripSummary(duration: '9 mins'), '9 min');
      expect(historyTripSummary(), isNull);
    });
  });

  group('historySubtitle and historyVehicleName', () {
    test('vehicle then driver, skipping what is missing', () {
      expect(historySubtitle(vehicleName: 'Tuk Tuk', driverName: 'Sok Dara'),
          'Tuk Tuk · Sok Dara');
      expect(historySubtitle(driverName: 'Sok Dara'), 'Sok Dara');
      expect(historySubtitle(vehicleName: 'Tuk Tuk'), 'Tuk Tuk');
      expect(historySubtitle(), isNull);
    });

    test('the booking names its own vehicle type', () {
      Datum trip(int? typeId) => Datum(
          driver: Driver(vehicle: Vehicle(typeVehicleId: typeId)));

      expect(historyVehicleName(trip(1)), 'Tuk Tuk');
      expect(historyVehicleName(trip(4)), 'SUV');
      expect(historyVehicleName(trip(5)), 'Alphard VIP');
    });

    test('no vehicle, or a type the app does not know, has no name', () {
      expect(historyVehicleName(Datum()), isNull);
      expect(historyVehicleName(null), isNull);
      expect(
        historyVehicleName(
            Datum(driver: Driver(vehicle: Vehicle(typeVehicleId: 42)))),
        isNull,
      );
    });
  });

  group('historyCellData — the list card', () {
    Datum trip({int? status = BookingStatus.completed, String? amount}) =>
        Datum(
          status: status,
          createdAt: '2026-10-05T14:59:00',
          startAddress: 'Central Market',
          driver: Driver(
            name: 'Sok Dara',
            vehicle: Vehicle(typeVehicleId: 1),
          ),
          payment: Payment(
            amount: amount,
            distance: '3.40 km',
            duration: '9 mins 16 seconds',
          ),
        );

    test('a completed trip carries its fare, summary and meter note', () {
      final item = historyCellData(trip(amount: '9600'),
          now: DateTime(2026, 10, 6));

      expect(item.cardDate, '5 Oct, 2:59 PM');
      expect(item.subtitle, 'Tuk Tuk · Sok Dara');
      expect(item.fare, '9,600 ${AppLocale.khmerCurrency}');
      expect(item.summary, '3.4 km · 9 min');
      expect(item.noDropOffText, AppLocale.noDropOffMeter);
      expect(item.art, isNotNull);
    });

    test('a cancelled trip carries none of them', () {
      final item = historyCellData(
          trip(status: BookingStatus.cancel, amount: '9600'));

      expect(item.fare, isNull);
      expect(item.summary, isNull);
      expect(item.noDropOffText, isNull);
    });

    test('the caller can name the vehicle as the app names it now', () {
      final item = historyCellData(trip(), vehicleName: 'Remorque');

      expect(item.subtitle, 'Remorque · Sok Dara');
    });
  });

  group('trip details helpers', () {
    test('historyPaidLabel names the method only when the record does', () {
      expect(historyPaidLabel('Wallet'), '${AppLocale.paid} · Wallet');
      expect(historyPaidLabel(null), AppLocale.paid);
      expect(historyPaidLabel('null'), AppLocale.paid);
    });

    test('historyWasCharged: only a positive amount is a charge', () {
      expect(historyWasCharged('2000'), isTrue);
      expect(historyWasCharged('0'), isFalse);
      expect(historyWasCharged(null), isFalse);
      expect(historyWasCharged('abc'), isFalse);
    });

    test('historyLatLng: a point, or null — never (0, 0)', () {
      expect(historyLatLng('11.5564', '104.9282'),
          const LatLng(11.5564, 104.9282));
      expect(historyLatLng(null, '104.9282'), isNull);
      expect(historyLatLng('11.5564', ''), isNull);
      expect(historyLatLng('north', 'east'), isNull);
    });

    test('historyVehicleInfo: model and colour, else the type', () {
      final withModel = Datum(
        driver: Driver(
          vehicle: Vehicle(
            typeVehicleId: 2,
            manufacturer: 'Toyota',
            model: 'Prius',
            color: 'White',
          ),
        ),
      );
      final typeOnly =
          Datum(driver: Driver(vehicle: Vehicle(typeVehicleId: 1)));

      expect(historyVehicleInfo(withModel), 'Toyota Prius · White');
      expect(historyVehicleInfo(typeOnly), 'Tuk Tuk');
      expect(historyVehicleInfo(typeOnly, vehicleName: 'Remorque'), 'Remorque');
      expect(historyVehicleInfo(null), '---');
    });
  });
}
