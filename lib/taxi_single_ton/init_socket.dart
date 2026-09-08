import 'package:com.tara.passenger/core/utils/app_log.dart';
import 'package:com.tara.passenger/core/utils/pretty_logger.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/booking_map_screen/logic.dart';
import 'package:com.tara.passenger/presentation/screens/calculate_fee/logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

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

/// F-03 (docs/12) — the old config (4 attempts, flat 60s delay) gave up for
/// good after ~4 minutes of no connectivity and never tried again, silently
/// going deaf mid-trip. Omitting the attempts cap is what makes the client
/// default (infinite retries) apply, so its *absence* from this map is
/// load-bearing, not an oversight; the delay backs off from 2s toward a 30s
/// ceiling instead of a flat wait.
///
/// Extracted so the reconnection policy can be asserted without opening a
/// socket — see `test/taxi_single_ton/socket_event_contract_test.dart`.
@visibleForTesting
Map<String, dynamic> buildSocketOptions() => io.OptionBuilder()
    .setTransports(['websocket'])
    .enableAutoConnect()
    .enableReconnection()
    .setReconnectionDelay(2000)
    .setReconnectionDelayMax(30000)
    .build();

/// Resolves the vehicle type for an outbound ride request.
///
/// This used to be `int.parse("${data.data?.typeVehicleId}")` inline in both
/// request emits. `typeVehicleId` is typed `dynamic` on the model, so a null
/// stringified to `"null"` and `int.parse` threw `FormatException` — killing
/// the ride request inside `MapScreenLogic.requestBooking()`'s `ok` branch,
/// which only calls `toggleBookLoading()` on the error path and so left the
/// booking spinner stuck on screen for good. Every other field in that
/// payload already degraded to a default (`vehiclePrice` to 0) rather than
/// taking the whole request down with it.
///
/// Falls back to the nested `typeVehicle.id`, which is the same vehicle type
/// carried elsewhere in the very same response, before giving up and sending
/// 0. Valid input — an `int` or a numeric `String`, both of which the old
/// `int.parse` accepted — is unaffected.
int resolveVehicleTypeId(RequestBookingModel data) {
  final raw = data.data?.typeVehicleId;
  if (raw is int) return raw;
  if (raw is double) return raw.toInt();
  if (raw is String) {
    final parsed = int.tryParse(raw);
    if (parsed != null) return parsed;
  }
  return data.data?.typeVehicle?.id ?? 0;
}

// Base socket service
abstract class BaseSocketService {
  io.Socket? _socket;

  void connectToSocket(String url, String id, String role,
      {required BuildContext context}) {
    _socket = io.io(url, buildSocketOptions());

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

  /// Emits [event], letting Socket.IO buffer it when the connection is
  /// temporarily down.
  ///
  /// The old body refused to emit unless `connected` was already true and
  /// logged "socket is not connected" instead. That **permanently dropped**
  /// the event: `Socket.emit` on a disconnected-but-live socket appends to
  /// `sendBuffer` and `emitBuffered()` flushes it on reconnect, so the guard
  /// was throwing away a packet the client would otherwise have delivered a
  /// few seconds later. It cost `rideRequest`, `rideRequestSpecificDriver`
  /// and `passengerCancelDrive` — a passenger tapping "book" during a brief
  /// loss of signal got a request that was never sent and never retried.
  ///
  /// A null socket is still unrecoverable — there is nothing to buffer into —
  /// so that case keeps its log line and stays the only real failure.
  void emitEvent(SocketEvent event, dynamic data) {
    final socket = _socket;
    if (socket == null) {
      tlog('Failed to emit event: ${event.eventName}, '
          'socket was never created.');
      return;
    }

    socket.emit(event.eventName, data);
    if (socket.connected) {
      tlog('Event emitted: ${event.eventName}, data: $data');
    } else {
      tlog('Event buffered until reconnect: ${event.eventName}, data: $data');
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

  /// The singleton's own constructor is private, so nothing outside this
  /// library can build an instance to assert against. This exists purely so
  /// tests can subclass and observe `emitEvent`; production code must keep
  /// going through the `PassengerSocketService()` factory.
  @visibleForTesting
  PassengerSocketService.forTesting();

  factory PassengerSocketService() {
    return _instance;
  }

  PassengerSocketService._internal();

  @override
  void register(String id) {
    emitEvent(SocketEvent.registerPassenger, id);
    tlog('Passenger registered with ID: $id');
  }

  @override
  void connectToSocket(String url, String id, String role,
      {required BuildContext context}) {
    if (_socket != null && _socket!.connected) {
      tlog('Socket already connected.');
      return;
    }

    super.connectToSocket(url, id, role, context: context);
    xPrettyLog(message: "connect socket: url$url, user id $id");

    // F-03 (docs/12) — this line only runs when `_socket` was just replaced
    // with a fresh instance above (the guard at the top of this method
    // returns early otherwise), so it's always safe — and, unlike the old
    // one-shot `_listenersSetup` flag, always necessary — to attach these to
    // the new socket. The flag left every socket created after the app's
    // first one (e.g. after the built-in reconnection exhausted its 4
    // attempts and the passenger reopened a screen) with no listener for
    // ride acceptance, driver arrival, trip start/end, or payment at all.
    setupListeners(context);
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
        "vehicleType": resolveVehicleTypeId(data),
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
      "vehicleType": resolveVehicleTypeId(data),
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
