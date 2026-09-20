import 'package:flutter_test/flutter_test.dart';

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
      expect(historyDate('2026-09-11T09:41:00'), contains('2026'));
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
}
