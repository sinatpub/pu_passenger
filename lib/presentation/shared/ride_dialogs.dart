import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/services/booking_session.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Why a booking request did not go through — only as far as the passenger
/// can act on it.
enum BookingFailure {
  /// The app has no pickup point to send.
  noLocation,

  /// The request failed or came back empty: a dropped connection, a server
  /// error. One message, because the passenger's next step is the same.
  requestFailed,
}

/// The arguments the booking map opens with to start again from a trip that
/// did not happen: the same vehicle, and the same drop-off if it had one.
Map<String, dynamic> rebookArguments({int? vehicleTypeId, LatLng? destination}) {
  return {
    if (vehicleTypeId != null) 'vehicleId': vehicleTypeId,
    if (destination != null) 'destination': destination,
  };
}

/// "Your driver cancelled" — Close, or Book again.
///
/// A real dialog: it stays until the passenger answers. "Book again" opens
/// the booking map with [vehicleTypeId] and [destination] filled in; the
/// passenger still confirms the pickup and taps Book, because they may have
/// moved since the first request.
Future<void> showDriverCancelledDialog(
  BuildContext context, {
  int? vehicleTypeId,
  LatLng? destination,
}) {
  return TaDialog.show(
    context,
    leading: const TaDialogIcon(
      icon: Icons.person_off_outlined,
      tone: TaDialogTone.warning,
    ),
    title: AppLocale.driverCancelledTitle.tr,
    body: AppLocale.driverCancelledBody.tr,
    actions: [
      TaButton(
        label: AppLocale.close.tr,
        variant: TaButtonVariant.ghost,
        size: TaButtonSize.small,
        onTap: () => Get.back(),
      ),
      TaButton(
        label: AppLocale.bookAgain.tr,
        size: TaButtonSize.small,
        onTap: () {
          Get.back();
          Get.toNamed(
            AppRoutes.MAP,
            arguments: rebookArguments(
              vehicleTypeId: vehicleTypeId,
              destination: destination,
            ),
          );
        },
      ),
    ],
  );
}

/// The driver cancelled an accepted ride: leave the ride screen for Home and
/// say so there, offering to book again from the trip that was lost.
///
/// The vehicle and drop-off come from [session], which still holds the draft
/// of the request that driver accepted. After an app restart there is no
/// draft, and "Book again" simply opens the booking map.
void presentDriverCancelled({BookingSession? session}) {
  final draft = session ??
      (Get.isRegistered<BookingSession>() ? Get.find<BookingSession>() : null);
  final vehicleTypeId = draft?.vehicleTypeId;
  final destination = draft?.destination;

  Get.offAllNamed(AppRoutes.BOTTOMNAV);
  final context = Get.context;
  if (context == null) return;
  showDriverCancelledDialog(
    context,
    vehicleTypeId: vehicleTypeId,
    destination: destination,
  );
}

/// "Couldn't book your ride" — Close, or Try again. Completes with true when
/// the passenger asks to try again.
Future<bool> showBookingFailedDialog(
  BuildContext context,
  BookingFailure failure,
) async {
  var retry = false;
  await TaDialog.show(
    context,
    leading: const TaDialogIcon(
      icon: Icons.error_outline,
      tone: TaDialogTone.error,
    ),
    title: AppLocale.bookingFailedTitle.tr,
    body: switch (failure) {
      BookingFailure.noLocation => AppLocale.bookingFailedNoLocation.tr,
      BookingFailure.requestFailed => AppLocale.bookingFailedBody.tr,
    },
    actions: [
      TaButton(
        label: AppLocale.close.tr,
        variant: TaButtonVariant.ghost,
        size: TaButtonSize.small,
        onTap: () => Get.back(),
      ),
      TaButton(
        label: AppLocale.pleaseTryAgain.tr,
        size: TaButtonSize.small,
        onTap: () {
          retry = true;
          Get.back();
        },
      ),
    ],
  );
  return retry;
}
