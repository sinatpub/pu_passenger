import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/core/utils/display_date.dart';
import 'package:com.tara.passenger/core/utils/fee_presentation.dart';
import 'package:com.tara.passenger/core/utils/initials.dart';
import 'package:com.tara.passenger/core/utils/status_util.dart';
import 'package:com.tara.passenger/data/models/history_booking_model.dart';
import 'package:com.tara.passenger/presentation/widgets/ta_history_card.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:get/get.dart';

/// Maps a history `Datum` onto the presentational [HistoryItem] (S1), the same
/// split as `vehicle_cell_data.dart` (C3) and `fee_presentation.dart` (C6) —
/// the card takes pre-formatted strings, so every formatting and degrade rule
/// lives here where it can be tested.
///
/// The payload policy holds: the amount is money and fails loudly; everything
/// else degrades to an em dash.
HistoryItem historyCellData(Datum? data) {
  final driverName = data?.driver?.name;
  return HistoryItem(
    invoice: historyInvoice(data?.payment?.invoiceId),
    driver: driverName ?? AppLocale.unKnown.tr,
    initials: initialsFromName(driverName),
    date: historyDate(data?.createdAt),
    amount: feeAmount(data?.payment?.amount) ?? '—',
    from: feeDisplayValue(data?.startAddress),
    to: historyDestination(data?.endAddress),
    distance: feeDisplayValue(data?.payment?.distance),
    duration: historyDuration(data?.payment?.duration),
  );
}

/// `INV-2041`, or an em dash when the backend sent no invoice — never
/// "INV-null".
String historyInvoice(int? invoiceId) =>
    invoiceId == null ? '—' : 'INV-$invoiceId';

/// The destination, or **null** when the trip never had one.
///
/// A cancelled booking frequently has no `end_address`, and the card drops the
/// row rather than printing "Unknown" as if a destination had been chosen
/// (roadmap S1 Risk).
String? historyDestination(String? endAddress) {
  final text = endAddress?.trim();
  if (text == null || text.isEmpty || text == 'null') return null;
  return text;
}

/// `createdAt` is an ISO timestamp. The card this replaced called
/// `DateTime.parse("${data?.createdAt}")` unguarded, which throws on anything
/// unparseable and takes the whole list down with it.
///
/// Delegates to the shared [displayIsoDate] so the history card and the
/// announcement card (S3) cannot drift on what a missing date looks like.
String historyDate(String? createdAt) => displayIsoDate(createdAt);

/// Duration through the existing short formatter, degrading when absent.
String historyDuration(String? duration) {
  final raw = duration?.trim();
  if (raw == null || raw.isEmpty || raw == 'null') return '—';
  final formatted = raw.toShortTimeFormat().trim();
  return formatted.isEmpty ? '—' : formatted;
}

/// Whether [status] is a completed trip, for the card's badge tone.
bool isCompletedHistory(int? status) => status == BookingStatus.completed;

/// The badge's localised label.
String historyStatusLabel(int? status) => isCompletedHistory(status)
    ? AppLocale.completed.tr
    : AppLocale.cancelled.tr;
