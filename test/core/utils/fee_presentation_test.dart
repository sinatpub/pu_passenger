import 'package:flutter_test/flutter_test.dart';

import 'package:com.tara.passenger/core/utils/fee_presentation.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

void main() {
  group('feeAmount — money fails loudly (payload policy, PDD-01)', () {
    test('formats a whole amount through today\'s formatter', () {
      expect(feeAmount('12000'), '12,000 ${AppLocale.khmerCurrency}');
    });

    test('formats a decimal amount', () {
      expect(feeAmount('4.85'), '4.85 ${AppLocale.khmerCurrency}');
    });

    test('trims surrounding whitespace', () {
      expect(feeAmount('  7500 '), '7,500 ${AppLocale.khmerCurrency}');
    });

    test('a null amount returns null rather than a zero', () {
      expect(feeAmount(null), isNull);
    });

    test('an empty amount returns null', () {
      expect(feeAmount('   '), isNull);
    });

    test('an unparseable amount returns null rather than the raw string', () {
      // Showing "abc ៛" or silently coercing to 0 would tell the passenger
      // something false about what they owe.
      expect(feeAmount('abc'), isNull);
      expect(feeAmount('12,000'), isNull);
    });
  });

  group('feeDisplayValue — display degrades', () {
    test('passes a real value through', () {
      expect(feeDisplayValue('6.1 km'), '6.1 km');
    });

    test('stringifies a number', () {
      expect(feeDisplayValue(18), '18');
    });

    test('null degrades to an em dash', () {
      expect(feeDisplayValue(null), '—');
    });

    test('an empty or literal-null string degrades to an em dash', () {
      expect(feeDisplayValue('  '), '—');
      expect(feeDisplayValue('null'), '—');
    });
  });

  group('feeDateTime — never throws the screen away', () {
    test('formats the documented backend pattern', () {
      expect(feeDateTime('2026-09-11 09:41:00'), '11 Sep 2026, 9:41 AM');
    });

    test('falls back to ISO-8601 parsing, in the same format', () {
      expect(feeDateTime('2026-10-05T14:03:00'), '5 Oct 2026, 2:03 PM');
    });

    test('a null start time degrades to an em dash', () {
      // The bare `formatDateTime(data.startTime)` this replaced threw here and
      // took the whole fee screen down.
      expect(feeDateTime(null), '—');
    });

    test('a malformed start time degrades to an em dash', () {
      expect(feeDateTime('not a date'), '—');
      expect(feeDateTime('null'), '—');
      expect(feeDateTime(''), '—');
    });
  });

  group('feeOptionalValue — absent is null, for the caller to word', () {
    test('a value is trimmed and kept', () {
      expect(feeOptionalValue('  Aeon Mall '), 'Aeon Mall');
    });

    test('null, empty and the string "null" are all absent', () {
      expect(feeOptionalValue(null), isNull);
      expect(feeOptionalValue('  '), isNull);
      expect(feeOptionalValue('null'), isNull);
    });

    test('the payment method follows the same rule — never invented', () {
      expect(feePaymentMethod('Cash'), 'Cash');
      expect(feePaymentMethod(null), isNull);
      expect(feePaymentMethod('null'), isNull);
    });
  });
}
