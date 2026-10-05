import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/core/utils/booking_vehicle_info.dart';
import 'package:com.tara.passenger/core/utils/initials.dart';
import 'package:com.tara.passenger/core/utils/status_util.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/booking_map_screen/logic.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/search_state.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Booking phase derived from the **socket stage only** (roadmap C5 Done When,
/// `D14`): the timeline and the cancel affordance read `data.status`, which is
/// written by `getBookingInfo()` from the socket and the bounded poll — never
/// by a demo timer, and never by `appLogic.titleEvent`.
///
/// `accepted(2) → 0 · arrival(8) → 1 · onGoing(3) → 2`. Every other status
/// (the request still in flight, completed, pending payment) clamps to 0 so a
/// transient or terminal state cannot show a false mid-trip step. The screen is
/// only reachable once a booking exists, and `socket_service` routes completed /
/// pending-payment bookings on to the fee screen.
int bookingPhaseFromStatus(int? status) {
  if (status == BookingStatus.arrival) return 1;
  if (status == BookingStatus.onGoing) return 2;
  return 0;
}

/// The sheet's headline for a phase (Screen 9 §States). Kept beside the phase
/// mapping so the headline and the progress bar can never disagree about the
/// stage.
String bookingStatusText(int phase) {
  switch (phase) {
    case 1:
      return AppLocale.driverHasArrived.tr;
    case 2:
      return AppLocale.stepOnTrip.tr;
    default:
      return AppLocale.driverOnTheWay.tr;
  }
}

/// Screen 9 — Booking (Active Ride)'s bottom sheet: the stage as a headline
/// with the driver's arrival time, a three-segment progress bar, the driver
/// and car to look for, the trip, Call, and — until the trip starts — Cancel.
///
/// Extracted from `booking_map_screen.dart` (C5) — as C3 did with
/// `MapBottomSheet` — so the whole phase table is widget-testable without the
/// GoogleMap platform view. Presentation only: `BookingMapLogic` (the socket +
/// poll source of truth and P-09's race guard) is read, never changed.
class BookingSheet extends StatelessWidget {
  const BookingSheet({super.key, required this.logic});

  final BookingMapLogic logic;

  @override
  Widget build(BuildContext context) {
    final data = logic.state.bookingRequestData?.data;
    final phase = bookingPhaseFromStatus(data?.status);

    /// Screen 9 §States — cancelling is gone once the trip is under way; the
    /// passenger is in the vehicle by then.
    final canCancel = phase < 2;

    return Container(
      decoration: BoxDecoration(
        color: TaColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: TaShadows.shadowLg,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          // The cancel link brings its own space below Call.
          padding: EdgeInsets.fromLTRB(20.d, 20.d, 20.d, canCancel ? 4.d : 20.d),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(data, phase),
                  SizedBox(height: 12.d),
                  ExcludeSemantics(
                    child: TaStepIndicator(current: phase, expanded: true),
                  ),
                  SizedBox(height: 14.d),
                  _driverCard(data),
                  SizedBox(height: 10.d),
                  _tripCard(data),
                  SizedBox(height: 14.d),
                  _callButton(data),
                  if (canCancel) _cancelLink(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The stage, what matters about it right now, and — while the driver is
  /// still coming — how many minutes away they are.
  Widget _header(Data? data, int phase) {
    final subtitle = _subtitle(data, phase);
    final eta = phase == 0 ? logic.state.pickupEta : null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bookingStatusText(phase),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TaTextStyles.headlineMedium
                    .copyWith(color: TaColors.textPrimary),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 2.d),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TaTextStyles.bodySmall
                      .copyWith(color: TaColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
        if (eta != null) ...[
          SizedBox(width: 12.d),
          Text(
            AppLocale.etaMinutes.trParams({'count': '${etaMinutes(eta)}'}),
            style: TaTextStyles.headlineLarge
                .copyWith(color: TaColors.textPrimary),
          ),
        ],
      ],
    );
  }

  /// Under the headline: how far the driver is, where to meet them, or where
  /// the trip is going. Null when the booking does not say.
  String? _subtitle(Data? data, int phase) {
    switch (phase) {
      case 1:
        final pickup = splitPlaceDescription(_text(data?.startAddress)).primary;
        return pickup == null
            ? null
            : AppLocale.meetAt.trParams({'place': pickup});
      case 2:
        final dropOff = splitPlaceDescription(_text(data?.endAddress)).primary;
        return dropOff == null
            ? AppLocale.fareByMeter.tr
            : AppLocale.headingTo.trParams({'place': dropOff});
      default:
        final metres = logic.state.pickupDistanceMeters;
        return metres == null
            ? null
            : '${(metres / 1000).toStringAsFixed(1)} ${AppLocale.kmAway.tr}';
    }
  }

  Widget _driverCard(Data? data) {
    return TaDriverCard(
      bordered: true,
      name: data?.driver?.name ?? AppLocale.unKnown.tr,
      initials: initialsFromName(data?.driver?.name),
      vehicleInfo: bookingVehicleInfo(data),
      plateNumber: data?.driver?.vehicle?.plateNumber,
    );
  }

  /// Pickup over drop-off. A trip booked without a drop-off says so, and
  /// that the fare is metered.
  Widget _tripCard(Data? data) {
    return TaTripCard(
      pickupLabel: AppLocale.pickup.tr,
      pickup: _text(data?.startAddress) ?? '---',
      dropOffLabel: AppLocale.destination.tr,
      dropOff: _text(data?.endAddress),
      noDropOffText: AppLocale.noDropOffMeter.tr,
    );
  }

  Widget _callButton(Data? data) {
    final phone = data?.driver?.phone;
    return TaButton(
      label: AppLocale.callDriver.tr,
      icon: Icons.call,
      variant: TaButtonVariant.dark,
      width: double.infinity,

      /// No phone on the booking yet means nothing to dial, so the button
      /// greys out rather than launching `tel:`.
      isEnabled: phone != null && phone.isNotEmpty,
      onTap: () => logic.makePhoneCall(phone ?? ''),
    );
  }

  /// Cancel is a link, not a button: the way out should be there, without
  /// being the largest thing on the sheet.
  Widget _cancelLink(BuildContext context) {
    return Center(
      child: Semantics(
        button: true,
        child: TaPressable(
          onTap: () => openCancelDialog(context),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.d, vertical: 14.d),
            child: Text(
              AppLocale.cancelBooking.tr,
              style: TaTextStyles.labelLarge.copyWith(color: TaColors.error),
            ),
          ),
        ),
      ),
    );
  }

  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  /// Screen 9 §Interactions — "Cancel booking?" → Yes cancels, No closes.
  @visibleForTesting
  void openCancelDialog(BuildContext context) {
    TaDialog.show(
      context,
      title: AppLocale.titleCancelBooking.tr,
      body: AppLocale.contentCancelBooking.tr,
      // `TaDialogCard` lays actions out itself — each is wrapped in an
      // `Expanded` with a 10px gap, so they are passed bare.
      actions: [
        TaButton(
          label: AppLocale.keepWaiting.tr,
          variant: TaButtonVariant.ghost,
          size: TaButtonSize.small,
          onTap: () => Get.back(),
        ),
        TaButton(
          label: AppLocale.yesCancel.tr,
          variant: TaButtonVariant.dangerGhost,
          size: TaButtonSize.small,
          onTap: () {
            Get.back();
            _cancel(context);
          },
        ),
      ],
    );
  }

  /// `logic.cancelBooking()` owns the wire: POST `cancel-request-booking-info`
  /// first, then emit `passengerCancelDrive` — that order and the emit itself
  /// are pinned by `socket_emit_contract_test.dart` and are not touched here.
  ///
  /// The view only decides what to show: leaving the screen is conditional on
  /// the API confirming the cancel, because navigating away from a booking the
  /// backend still considers live would strand the passenger with no way back
  /// to it. The toast is raised **before** navigating — it is inserted into the
  /// navigator's overlay, which survives `offAllNamed`, whereas this context
  /// does not.
  Future<void> _cancel(BuildContext context) async {
    final cancelled = await logic.cancelBooking();
    if (!context.mounted) return;
    TaToast.show(
      context,
      cancelled
          ? AppLocale.bookingCancelled.tr
          : AppLocale.cancelBookingFailed.tr,
    );
    if (cancelled) Get.offAllNamed(AppRoutes.BOTTOMNAV);
  }
}

/// Whole minutes for an arrival time, never less than one: "0 min" reads as
/// "already here", which is the arrived stage's job to say.
int etaMinutes(Duration eta) {
  final minutes = (eta.inSeconds / 60).round();
  return minutes < 1 ? 1 : minutes;
}
