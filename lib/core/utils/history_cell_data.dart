import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/core/utils/booking_vehicle_info.dart';
import 'package:com.tara.passenger/core/utils/display_date.dart';
import 'package:com.tara.passenger/core/utils/fee_presentation.dart';
import 'package:com.tara.passenger/core/utils/initials.dart';
import 'package:com.tara.passenger/core/utils/status_util.dart';
import 'package:com.tara.passenger/core/utils/vehicle_art.dart';
import 'package:com.tara.passenger/core/utils/vehicle_kind.dart';
import 'package:com.tara.passenger/data/models/history_booking_model.dart';
import 'package:com.tara.passenger/presentation/widgets/ta_history_card.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

/// Maps a history `Datum` onto the presentational [HistoryItem] (S1), the same
/// split as `vehicle_cell_data.dart` (C3) and `fee_presentation.dart` (C6) —
/// the card takes pre-formatted strings, so every formatting and degrade rule
/// lives here where it can be tested.
///
/// The payload policy holds: the amount is money and fails loudly; everything
/// else degrades to an em dash.
///
/// [vehicleName] is the trip's vehicle type as Home names it today. The
/// caller looks it up by the type id: a past trip records only that id, and
/// what an id means is the backend's to say. Without a name the card shows
/// no vehicle rather than a guessed one.
/// [now] decides whether the card's date needs its year.
HistoryItem historyCellData(
  Datum? data, {
  String? vehicleName,
  DateTime? now,
}) {
  final driverName = data?.driver?.name;
  final completed = isCompletedHistory(data?.status);
  final fare = feeAmount(data?.payment?.amount);
  final art = vehicleArtAsset(vehicleKindFromName(vehicleName));
  return HistoryItem(
    invoice: historyInvoice(data?.payment?.invoiceId),
    driver: driverName ?? AppLocale.unKnown.tr,
    initials: initialsFromName(driverName),
    date: historyDate(data?.createdAt),
    amount: fare ?? '—',
    from: feeDisplayValue(data?.startAddress),
    to: historyDestination(data?.endAddress),
    distance: feeDisplayValue(data?.payment?.distance),
    duration: historyDuration(data?.payment?.duration),
    cardDate: historyCardDate(data?.createdAt, now: now),
    subtitle: historySubtitle(
      vehicleName: vehicleName,
      driverName: driverName,
    ),

    /// A completed trip was charged, so a fare the backend did not send is
    /// said to be missing ("—") rather than left out. A cancelled trip was
    /// not, and shows none.
    fare: completed ? fare ?? '—' : null,
    summary: completed
        ? historyTripSummary(
            distance: data?.payment?.distance,
            duration: data?.payment?.duration,
          )
        : null,

    /// A completed trip with no drop-off was booked by meter. A cancelled
    /// one simply never had one, and the row is dropped (roadmap S1 Risk).
    noDropOffText: completed ? AppLocale.noDropOffMeter.tr : null,
    art: art == null ? null : SvgPicture.asset(art),
  );
}

/// The card's headline: `5 Oct, 2:59 PM`, with the year only when the trip
/// is not from this one — the list is mostly recent trips, and the year on
/// every row crowds out the fare beside it.
String historyCardDate(String? createdAt, {DateTime? now}) {
  final raw = createdAt?.trim();
  if (raw == null || raw.isEmpty || raw == 'null') return '—';
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return '—';
  final sameYear = parsed.year == (now ?? DateTime.now()).year;
  return DateFormat(sameYear ? 'd MMM, h:mm a' : 'd MMM yyyy, h:mm a')
      .format(parsed);
}

/// `Classic Car · Sok Dara` — whichever parts the booking has, or null.
String? historySubtitle({String? vehicleName, String? driverName}) {
  final parts = [vehicleName, driverName]
      .map((part) => part?.trim() ?? '')
      .where((part) => part.isNotEmpty);
  return parts.isEmpty ? null : parts.join(' · ');
}

/// `10.25 km` as `10.3 km`. Anything that is not a plain kilometre figure is
/// shown as the backend sent it; nothing at all is null.
String? historyDistanceShort(String? distance) {
  final raw = distance?.trim();
  if (raw == null || raw.isEmpty || raw == 'null') return null;
  final match =
      RegExp(r'^(\d+(?:\.\d+)?)\s*km$', caseSensitive: false).firstMatch(raw);
  final km = match == null ? null : double.tryParse(match.group(1)!);
  return km == null ? raw : '${km.toStringAsFixed(1)} km';
}

/// `27 mins 57 seconds` as `28 min`; `1 hours 5 mins` as `1 h 5 min`.
/// Rounded to the minute and never below one. A value in some other shape is
/// shown as the backend sent it; nothing at all is null.
String? historyDurationShort(String? duration) {
  final raw = duration?.trim();
  if (raw == null || raw.isEmpty || raw == 'null') return null;

  int? part(String unit) {
    final match =
        RegExp('(\\d+)\\s*$unit', caseSensitive: false).firstMatch(raw);
    return match == null ? null : int.parse(match.group(1)!);
  }

  final hours = part('hour');
  final minutes = part('min');
  final seconds = part('sec');
  if (hours == null && minutes == null && seconds == null) return raw;

  final totalSeconds =
      (hours ?? 0) * 3600 + (minutes ?? 0) * 60 + (seconds ?? 0);
  var totalMinutes = (totalSeconds / 60).round();
  if (totalMinutes < 1) totalMinutes = 1;

  final h = totalMinutes ~/ 60;
  final m = totalMinutes % 60;
  return [
    if (h > 0) AppLocale.hoursShort.trParams({'count': '$h'}),
    if (m > 0 || h == 0) AppLocale.etaMinutes.trParams({'count': '$m'}),
  ].join(' ');
}

/// `10.3 km · 28 min`, or null when the trip has neither to show.
String? historyTripSummary({String? distance, String? duration}) {
  final parts = [
    historyDistanceShort(distance),
    historyDurationShort(duration),
  ].whereType<String>();
  return parts.isEmpty ? null : parts.join(' · ');
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

/// "Paid · Wallet" when the record names a method, plain "Paid" otherwise —
/// the method is not invented.
String historyPaidLabel(Object? paymentMethod) {
  final method = feePaymentMethod(paymentMethod);
  return method == null
      ? AppLocale.paid.tr
      : '${AppLocale.paid.tr} · $method';
}

/// The car as the detail page describes it: maker, model and colour, with
/// the vehicle type standing in for a missing model.
String historyVehicleInfo(Datum? data, {String? vehicleName}) {
  final vehicle = data?.driver?.vehicle;
  return vehicleDescription(
    manufacturer: vehicle?.manufacturer,
    model: vehicle?.model,
    color: vehicle?.color,
    typeName: vehicleName,
  );
}

/// A cancelled trip is said to have cost nothing only when its record agrees:
/// no amount, or zero. Anything else is a charge, and is shown as one.
bool historyWasCharged(Object? amount) {
  final value = num.tryParse(amount?.toString().trim() ?? '');
  return value != null && value > 0;
}

/// A coordinate pair from the record's strings, or null when either half is
/// missing or unparseable — never (0, 0).
LatLng? historyLatLng(String? latitude, String? longitude) {
  final lat = double.tryParse(latitude?.trim() ?? '');
  final lng = double.tryParse(longitude?.trim() ?? '');
  return lat == null || lng == null ? null : LatLng(lat, lng);
}
