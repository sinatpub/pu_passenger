import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:get/get.dart';

/// Screen 10 (Fee) display formatting, kept pure and out of the widget so the
/// degrade rules below are testable — the same split as `vehicle_cell_data.dart`
/// (C3) and `initials.dart` (C5).
///
/// The payload policy applies: **money fails loudly, display degrades.** An
/// amount that will not parse is not guessed at and not silently zeroed —
/// [feeAmount] returns null and the caller shows nothing rather than a wrong
/// number. Distance, duration and date are display-only, so a missing or
/// malformed value degrades to an em dash.

/// The fare, formatted through today's formatter (`PDD-01`: keep the existing
/// currency treatment — KHR via `toMoneyFormat()` + `khmerCurrency`, not `D15`'s
/// USD, which is superseded for this app).
///
/// Returns null when `payment.amount` is absent or not a number. A fare is
/// money: rendering "0 ៛" or the raw string for an unparseable amount would
/// tell the passenger something false about what they owe.
String? feeAmount(String? amount) {
  final raw = amount?.trim();
  if (raw == null || raw.isEmpty) return null;
  final value = num.tryParse(raw);
  if (value == null) return null;
  return '${value.toMoneyFormat()} ${AppLocale.khmerCurrency.tr}';
}

/// A display-only value, or an em dash when the backend did not send one.
String feeDisplayValue(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty || text == 'null') return '—';
  return text;
}

/// `start_time` arrives as `dynamic` and is not always the
/// `yyyy-MM-dd HH:mm:ss` that `formatDateTime` demands — it can be null, a
/// number, or an ISO string. The bare `formatDateTime(data.startTime)` this
/// replaced threw on every one of those, taking the whole fee screen down
/// with it, so parsing is attempted and falls back to the em dash.
String feeDateTime(Object? startTime) {
  final raw = startTime?.toString().trim();
  if (raw == null || raw.isEmpty || raw == 'null') return '—';
  try {
    return formatDateTime(raw);
  } catch (_) {
    // Not the expected pattern — try ISO-8601 before giving up.
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return '—';
    return parsed.formatDateTime();
  }
}
