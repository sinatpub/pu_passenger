import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/core/utils/initials.dart';
import 'package:com.tara.passenger/core/utils/status_util.dart';
import 'package:com.tara.passenger/presentation/screens/booking_map_screen/logic.dart';
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

/// Status pill copy for a phase (Screen 9 §States). Kept beside the phase
/// mapping so the pill and the timeline can never disagree about the stage.
String bookingStatusText(int phase) {
  switch (phase) {
    case 1:
      return AppLocale.driverArriving.tr;
    case 2:
      return AppLocale.onTripEnjoy.tr;
    default:
      return AppLocale.driverAccepted.tr;
  }
}

/// Screen 9 — Booking (Active Ride)'s bottom sheet: the 3-step timeline
/// (`D6`), the driver card, the Call + Safety row and the cancel button.
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

    return Container(
      decoration: BoxDecoration(
        color: TaColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: TaShadows.shadowLg,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.d, 12.d, 20.d, 16.d),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.55,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TaGrabHandle(),
                  SizedBox(height: 16.d),
                  TaTimeline(
                    currentStep: phase,
                    steps: [
                      AppLocale.stepAccepted.tr,
                      AppLocale.stepArriving.tr,
                      AppLocale.stepOnTrip.tr,
                    ],
                  ),
                  SizedBox(height: 16.d),
                  _driverCard(),
                  SizedBox(height: 14.d),
                  _actionRow(context),

                  /// Screen 9 §States — cancelling is gone once the trip is
                  /// under way; the passenger is in the vehicle by then.
                  if (phase < 2) ...[
                    SizedBox(height: 10.d),
                    _cancelButton(context),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _driverCard() {
    final data = logic.state.bookingRequestData?.data;
    final name = data?.driver?.name ?? AppLocale.unKnown.tr;
    return TaDriverCard(
      name: name,
      initials: initialsFromName(data?.driver?.name),
      vehicleInfo: data?.typeVehicle?.name ?? '---',
      plateNumber: data?.driver?.vehicle?.plateNumber,
    );
  }

  Widget _actionRow(BuildContext context) {
    final phone = logic.state.bookingRequestData?.data?.driver?.phone;
    return Row(
      children: [
        Expanded(
          flex: 12,
          child: TaButton(
            label: AppLocale.callDriver.tr,
            variant: TaButtonVariant.dark,
            size: TaButtonSize.small,

            /// No phone on the booking yet means nothing to dial, so the
            /// button greys out rather than launching `tel:`.
            isEnabled: phone != null && phone.isNotEmpty,
            onTap: () => logic.makePhoneCall(phone ?? ''),
          ),
        ),
        SizedBox(width: 10.d),
        Expanded(
          flex: 10,
          child: TaButton(
            label: AppLocale.safety.tr,
            variant: TaButtonVariant.ghost,
            size: TaButtonSize.small,
            onTap: () => TaToast.show(context, AppLocale.safetyComingSoon.tr),
          ),
        ),
      ],
    );
  }

  Widget _cancelButton(BuildContext context) {
    return TaButton(
      label: AppLocale.cancelBooking.tr,
      variant: TaButtonVariant.dangerGhost,
      onTap: () => openCancelDialog(context),
    );
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
