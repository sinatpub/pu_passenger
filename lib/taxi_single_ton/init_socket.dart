import 'package:com.tara.passenger/core/utils/app_log.dart';
import 'package:com.tara.passenger/core/utils/pretty_logger.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/booking_map_screen/logic.dart';
import 'package:com.tara.passenger/presentation/screens/calculate_fee/logic.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/logic.dart';
import 'package:com.tara.passenger/presentation/screens/home/logic.dart';
import 'package:com.tara.passenger/taxi_single_ton/taxi_notification.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../app/logic.dart';
import '../routes/app_pages.dart';

// Enum for socket events
enum SocketEvent {
  registerPassenger,
  rideRequest,
  rideAccepted,
  rideCancel,
  driverArrival,
  driverStartDrive,
  onDriverCancel,
  driverDropDrive,
  driverAcceptPayment,
  rideRequestSpecificDriver,
}

// Extension to get event name
extension SocketEventName on SocketEvent {
  String get eventName {
    switch (this) {
      case SocketEvent.registerPassenger:
        return "registerPassenger";
      case SocketEvent.rideRequest:
        return "rideRequest";
      case SocketEvent.rideAccepted:
        return "rideAccepted";
      case SocketEvent.rideCancel:
        return "passengerCancelDrive";
      case SocketEvent.driverArrival:
        return "driverArrival";
      case SocketEvent.driverStartDrive:
        return "driverStartDrive";
      case SocketEvent.driverDropDrive:
        return "driverDropDrive";
      case SocketEvent.driverAcceptPayment:
        return "driverAcceptPayment";
      case SocketEvent.onDriverCancel:
        return "onDriverCancelDrive";
      case SocketEvent.rideRequestSpecificDriver:
        return "rideRequestSpecificDriver";
    }
  }
}

// Base socket service
abstract class BaseSocketService {
  io.Socket? _socket;

  void connectToSocket(String url, String id, String role,
      {required BuildContext context}) {
    _socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setReconnectionAttempts(4)
          .setReconnectionDelay(60000)
          .build(),
    );

    _socket?.onConnect((_) {
      tlog('$role connected to socket');
      register(id);
    });

    _socket?.onConnectError((err) {
      tlog('Connection Error: $err');
    });

    _socket?.onDisconnect((_) {
      tlog('$role socket disconnected');
    });
  }

  void register(String id);

  void emitEvent(SocketEvent event, dynamic data) {
    if (_socket != null && _socket!.connected) {
      _socket?.emit(event.eventName, data);
      tlog('Event emitted: ${event.eventName}, data: $data');
    } else {
      tlog(
          'Failed to emit event: ${event.eventName}, socket is not connected.');
    }
  }

  void disconnectSocket() {
    _socket?.disconnect();
    _socket = null;
  }
}

class PassengerSocketService extends BaseSocketService {
  static final PassengerSocketService _instance =
      PassengerSocketService._internal();

  factory PassengerSocketService() {
    return _instance;
  }

  PassengerSocketService._internal();

  // Add a flag to track whether listeners were already set up
  bool _listenersSetup = false;

  @override
  void register(String id) {
    emitEvent(SocketEvent.registerPassenger, id);
    tlog('Passenger registered with ID: $id');
  }

  @override
  void connectToSocket(String url, String id, String role,
      {required BuildContext context}) {
    // Only connect if not already connected
    if (_socket == null || !_socket!.connected) {
      super.connectToSocket(url, id, role, context: context);
    } else {
      tlog('Socket already connected.');
    }

    xPrettyLog(message: "connect socket: url$url, user id $id");

    // Only setup listeners once
    if (!_listenersSetup) {
      setupListeners(context);
      _listenersSetup = true;
    }
  }

  void setupListeners(BuildContext context) {
    addSocketListeners({
      SocketEvent.rideAccepted: (data) => _handleBookingUpdate(),
      SocketEvent.driverArrival: (data) => _handleBookingUpdate(),
      SocketEvent.driverStartDrive: (data) => _handleBookingUpdate(),
      SocketEvent.driverDropDrive: (data) async {
        await Future.delayed(const Duration(seconds: 1));
        // 3. Then go to payment
        Get.offAllNamed(AppRoutes.CALCULATEFEE);
      },
      SocketEvent.driverAcceptPayment: (data) =>
          _handleDriverAcceptedPayment(context, data),
      // P-15 (docs/12) — re-enabled 2026-09-03. Was dead: the handler and
      // its user-facing panel (ShowInfoWidget, wired in main.dart) already
      // existed; only this registration was commented out, so a
      // driver-initiated mid-trip cancellation reached the passenger only
      // via the 10s poll or a push notification (docs/08 H-7).
      SocketEvent.onDriverCancel: (data) =>
          _handleOnDriverCancel(context, data),
    });
  }

  void _handleBookingUpdate() {
    if (Get.currentRoute == AppRoutes.BOOKING) {
      // If already on the page, just tell the logic to refresh silently
      if (Get.isRegistered<BookingMapLogic>()) {
        HapticFeedback.heavyImpact();
        Get.find<BookingMapLogic>().getBookingInfo(isSilent: true);
      }
    } else {
      // If not on the page, navigate to it
      Get.offNamed(AppRoutes.BOOKING);
    }
  }

  void _handleDriverAcceptedPayment(BuildContext context, dynamic data) {
    _socket?.emit(SocketEvent.driverAcceptPayment.eventName);
    if (Get.isRegistered<CalculateFeeLogic>()) {
      Get.lazyPut(() => CalculateFeeLogic());
    }
    var paymentLogic = Get.find<CalculateFeeLogic>();
    Logger().e("Accept Payment $data");
    if (data != null) {
      paymentLogic.syncNavigateBack();
      HapticFeedback.heavyImpact();
      // TaxiNotification.shared.notifyBooking(title: AppLocale.paymentDone.tr);
      tlog(
          "Received Data from ${SocketEvent.driverAcceptPayment.eventName} Socket $data");

      // Get.find<AppLogic>().titleEvent = "";
      // Get.find<AppLogic>().update([AppUpdate.titleEventID]);
    }
  }

  void addSocketListeners(Map<SocketEvent, Function(dynamic)> listeners) {
    listeners.forEach((event, handler) {
      try {
        _socket?.on(event.eventName, handler);
        tlog("Listener added for event: ${event.eventName}");
      } catch (e) {
        tlog("Error adding listener for event ${event.eventName}: $e");
      }
    });
  }

  void rideRequestSocket({
    required RequestBookingModel data,
    double? startLatitude,
    double? startLongitude,
    double? startDestinationLat,
    double? startDestinationLong,
  }) {
    emitEvent(
      SocketEvent.rideRequest,
      {
        "booking_code": data.data?.bookingCode.toString(),
        "booking_id": data.data?.id?.toString(),
        "passengerId": data.data?.passenger?.id.toString(),
        "location": {"latitude": startLatitude, "longitude": startLongitude},
        "vehiclePrice": data.data?.typeVehicle?.price ?? 0,
        "vehicleType": int.parse("${data.data?.typeVehicleId}"),
        "timeout": data.data?.timeoutParam,
        "passenger": {
          "name": data.data?.passenger?.name,
          "phone": data.data?.passenger?.phone,
          "profile": data.data?.passenger?.profileImage,
        },
        "destination": {
          "latitude": startDestinationLat,
          "longitude": startDestinationLong
        }
      },
    );
  }

  void rideRequestSpecificDriverSocket({
    int? driverID,
    required RequestBookingModel data,
    double? startLatitude,
    double? startLongitude,
    double? startDestinationLat,
    double? startDestinationLong,
  }) {
    emitEvent(SocketEvent.rideRequestSpecificDriver, {
      "booking_code": data.data?.bookingCode.toString(),
      "booking_id": data.data?.id?.toString(),
      "passengerId": data.data?.passenger?.id.toString(),
      "location": {"latitude": startLatitude, "longitude": startLongitude},
      "vehiclePrice": data.data?.typeVehicle?.price ?? 0,
      "vehicleType": int.parse("${data.data?.typeVehicleId}"),
      "timeout": data.data?.timeoutParam,
      "passenger": {
        "name": data.data?.passenger?.name,
        "phone": data.data?.passenger?.phone,
        "profile": data.data?.passenger?.profileImage,
      },
      "destination": {
        "latitude": startDestinationLat,
        "longitude": startDestinationLong
      },
      "driver_id": driverID,
    });
  }

  void handleCancelRide({RequestBookingModel? data}) {
    emitEvent(
      SocketEvent.rideCancel,
      {"driver_id": data?.data?.driver?.id},
    );
  }

  void _handleOnDriverCancel(BuildContext context, dynamic data) {
    _socket?.emit(SocketEvent.onDriverCancel.eventName);
    if (data != null) {
      EasyLoading.showInfo("", duration: const Duration(seconds: 8));
      Get.offAllNamed(AppRoutes.BOTTOMNAV);
    }
  }
}
