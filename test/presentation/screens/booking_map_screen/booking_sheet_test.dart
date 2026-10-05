import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/network/api_exception.dart';
import 'package:com.tara.passenger/core/network/result.dart';
import 'package:com.tara.passenger/core/utils/booking_vehicle_info.dart';
import 'package:com.tara.passenger/core/utils/status_util.dart';
import 'package:com.tara.passenger/data/datasources/cancel_booking_api.dart';
import 'package:com.tara.passenger/data/datasources/check_request_book_source.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/booking_map_screen/logic.dart';
import 'package:com.tara.passenger/presentation/screens/booking_map_screen/widgets/booking_sheet.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Hand-written fakes, no mocktail (`.agent/skills/testing.md`), matching
/// `logic_test.dart`'s style.
class _FakeCheckBookingApi extends CheckBookingApi {
  @override
  Future<RequestBookingModel> checkBookingApi() async => RequestBookingModel();
}

class _FakeCancelBookingApi extends CancelBookingApi {
  _FakeCancelBookingApi(this.result);

  final Result<bool> result;
  int calls = 0;

  @override
  Future<Result<bool>> cancelBookingApi() async {
    calls++;
    return result;
  }
}

/// A controller holding a fixed booking. `onInit`/`onReady` are never run —
/// `BookingSheet` takes the controller directly, so nothing pumps the poll
/// timer or the marker-asset loading.
BookingMapLogic _logicWith({
  int? status,
  String? driverName = 'Sok Dara',
  String? phone = '012345678',
  String? plate = '2AB-1234',
  String? vehicleName = 'Tuk-Tuk',
  String? manufacturer,
  String? model,
  String? color,
  String? startAddress,
  String? endAddress,
  Duration? pickupEta,
  double? pickupDistanceMeters,
  Result<bool>? cancelResult,
  void Function()? onCancelRide,
}) {
  final logic = BookingMapLogic(
    checkBookingApi: _FakeCheckBookingApi(),
    isSocketConnected: () => true,
    cancelBookingRepo: _FakeCancelBookingApi(
      cancelResult ?? const Ok(true),
    ),
    onCancelRide: onCancelRide ?? () {},
  );
  logic.state.bookingRequestData = RequestBookingModel(
    data: Data(
      status: status,
      startAddress: startAddress,
      endAddress: endAddress,
      typeVehicle: TypeVehicle(name: vehicleName),
      driver: Driver(
        name: driverName,
        phone: phone,
        vehicle: Vehicle(
          plateNumber: plate,
          manufacturer: manufacturer,
          model: model,
          color: color,
        ),
      ),
    ),
  );
  logic.state.pickupEta = pickupEta;
  logic.state.pickupDistanceMeters = pickupDistanceMeters;
  return logic;
}

/// Marks the route a successful cancel lands on, so the test can tell
/// "navigated home" from "still on the ride".
const _homeMarker = Key('bottom-nav-stub');

Future<void> _pumpSheet(WidgetTester tester, BookingMapLogic logic) async {
  await tester.pumpWidget(
    GetMaterialApp(
      initialRoute: '/booking-under-test',
      getPages: [
        GetPage(
          name: '/booking-under-test',
          page: () => Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: BookingSheet(logic: logic),
            ),
          ),
        ),
        // `_cancel` navigates here on success; a stub stands in for the real
        // shell, which would need the whole app's DI.
        GetPage(
          name: AppRoutes.BOTTOMNAV,
          page: () => const Scaffold(body: SizedBox(key: _homeMarker)),
        ),
      ],
    ),
  );
  await tester.pump();
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(() => Get.reset());

  group('bookingPhaseFromStatus — socket stage only (C5 Done When, D14)', () {
    test('accepted is phase 0', () {
      expect(bookingPhaseFromStatus(BookingStatus.accepted), 0);
    });

    test('arrival is phase 1', () {
      expect(bookingPhaseFromStatus(BookingStatus.arrival), 1);
    });

    test('onGoing is phase 2', () {
      expect(bookingPhaseFromStatus(BookingStatus.onGoing), 2);
    });

    test('a still-pending request clamps to phase 0', () {
      expect(bookingPhaseFromStatus(BookingStatus.request), 0);
    });

    test('terminal statuses clamp to phase 0, never to the final step', () {
      // Showing "On trip" for a completed or payment-pending booking would
      // claim the ride is still running.
      expect(bookingPhaseFromStatus(BookingStatus.completed), 0);
      expect(bookingPhaseFromStatus(BookingStatus.pendingPayment), 0);
      expect(bookingPhaseFromStatus(BookingStatus.cancel), 0);
    });

    test('a missing status clamps to phase 0', () {
      expect(bookingPhaseFromStatus(null), 0);
    });
  });

  group('BookingSheet phase table (03 §Screen 9 States)', () {
    testWidgets('accepted: "on the way", bar at step 1, cancel offered',
        (tester) async {
      await _pumpSheet(tester, _logicWith(status: BookingStatus.accepted));

      expect(find.text(AppLocale.driverOnTheWay), findsOneWidget);
      final bar = tester.widget<TaStepIndicator>(find.byType(TaStepIndicator));
      expect(bar.current, 0);
      expect(find.text(AppLocale.cancelBooking), findsOneWidget);
    });

    testWidgets('arrival: "has arrived", bar at step 2, cancel still offered',
        (tester) async {
      await _pumpSheet(tester, _logicWith(status: BookingStatus.arrival));

      expect(find.text(AppLocale.driverHasArrived), findsOneWidget);
      final bar = tester.widget<TaStepIndicator>(find.byType(TaStepIndicator));
      expect(bar.current, 1);
      expect(find.text(AppLocale.cancelBooking), findsOneWidget);
    });

    testWidgets('onGoing: "On trip", bar full and cancel is withdrawn',
        (tester) async {
      await _pumpSheet(tester, _logicWith(status: BookingStatus.onGoing));

      expect(find.text(AppLocale.stepOnTrip), findsOneWidget);
      final bar = tester.widget<TaStepIndicator>(find.byType(TaStepIndicator));
      expect(bar.current, 2);
      expect(
        find.text(AppLocale.cancelBooking),
        findsNothing,
        reason: 'the passenger is already in the vehicle',
      );
    });
  });

  group('BookingSheet header — what matters at this stage', () {
    testWidgets('accepted: minutes and distance to the pickup',
        (tester) async {
      await _pumpSheet(
        tester,
        _logicWith(
          status: BookingStatus.accepted,
          pickupEta: const Duration(seconds: 250),
          pickupDistanceMeters: 1240,
        ),
      );

      expect(find.text('4 min'), findsOneWidget);
      expect(find.text('1.2 km away'), findsOneWidget);
    });

    testWidgets('accepted without a route: no arrival time is made up',
        (tester) async {
      await _pumpSheet(tester, _logicWith(status: BookingStatus.accepted));

      expect(find.textContaining('min'), findsNothing);
      expect(find.textContaining('km away'), findsNothing);
    });

    testWidgets('arrival: where to meet, and no stale arrival time',
        (tester) async {
      await _pumpSheet(
        tester,
        _logicWith(
          status: BookingStatus.arrival,
          startAddress: 'Street 271, Daun Penh, Phnom Penh',
          // Left over from the accepted stage; the header must not show it.
          pickupEta: const Duration(minutes: 4),
          pickupDistanceMeters: 1240,
        ),
      );

      expect(find.text('Meet at Street 271'), findsOneWidget);
      expect(find.text('4 min'), findsNothing);
    });

    testWidgets('onGoing: where the trip is heading', (tester) async {
      await _pumpSheet(
        tester,
        _logicWith(
          status: BookingStatus.onGoing,
          endAddress: 'Phnom Penh Airport, Russian Blvd',
        ),
      );

      expect(find.text('To Phnom Penh Airport'), findsOneWidget);
    });

    testWidgets('onGoing without a drop-off: the fare is by meter',
        (tester) async {
      await _pumpSheet(tester, _logicWith(status: BookingStatus.onGoing));

      expect(find.text(AppLocale.fareByMeter), findsOneWidget);
    });
  });

  group('BookingSheet trip card', () {
    testWidgets('pickup over drop-off', (tester) async {
      await _pumpSheet(
        tester,
        _logicWith(
          status: BookingStatus.accepted,
          startAddress: 'Street 271, Daun Penh',
          endAddress: 'Phnom Penh Airport',
        ),
      );

      final pickup = tester.getRect(find.text('Street 271, Daun Penh'));
      final dropOff = tester.getRect(find.text('Phnom Penh Airport'));
      expect(pickup.bottom, lessThanOrEqualTo(dropOff.top));
      expect(find.text(AppLocale.noDropOffMeter), findsNothing);
    });

    testWidgets('a trip booked without a drop-off says so', (tester) async {
      await _pumpSheet(
        tester,
        _logicWith(
          status: BookingStatus.accepted,
          startAddress: 'Street 271, Daun Penh',
        ),
      );

      expect(find.text(AppLocale.noDropOffMeter), findsOneWidget);
    });
  });

  group('etaMinutes', () {
    test('rounds to whole minutes', () {
      expect(etaMinutes(const Duration(seconds: 250)), 4);
      expect(etaMinutes(const Duration(seconds: 90)), 2);
    });

    test('never shows less than a minute', () {
      expect(etaMinutes(const Duration(seconds: 20)), 1);
      expect(etaMinutes(Duration.zero), 1);
    });
  });

  group('bookingVehicleInfo — what to look for on the street', () {
    Data dataWith({String? manufacturer, String? model, String? color}) => Data(
          typeVehicle: TypeVehicle(name: 'Classic Car'),
          driver: Driver(
            vehicle: Vehicle(
              manufacturer: manufacturer,
              model: model,
              color: color,
            ),
          ),
        );

    test('maker, model and colour', () {
      expect(
        bookingVehicleInfo(
            dataWith(manufacturer: 'Toyota', model: 'Prius', color: 'White')),
        'Toyota Prius · White',
      );
    });

    test('a model that already names the maker is not doubled', () {
      expect(
        bookingVehicleInfo(dataWith(
            manufacturer: 'Toyota', model: 'Toyota Prius', color: 'White')),
        'Toyota Prius · White',
      );
    });

    test('no model falls back to the vehicle type, keeping the colour', () {
      expect(bookingVehicleInfo(dataWith(color: 'White')),
          'Classic Car · White');
    });

    test('nothing known degrades to a placeholder', () {
      expect(bookingVehicleInfo(Data()), '---');
      expect(bookingVehicleInfo(null), '---');
    });
  });

  group('BookingSheet driver card', () {
    testWidgets('renders name, vehicle, plate and initials', (tester) async {
      await _pumpSheet(tester, _logicWith(status: BookingStatus.accepted));

      final card = tester.widget<TaDriverCard>(find.byType(TaDriverCard));
      expect(card.name, 'Sok Dara');
      expect(card.vehicleInfo, 'Tuk-Tuk');
      expect(card.plateNumber, '2AB-1234');
      expect(card.initials, 'SD');
    });

    testWidgets('a booking with no driver attached degrades instead of crashing',
        (tester) async {
      await _pumpSheet(
        tester,
        _logicWith(
          status: BookingStatus.accepted,
          driverName: null,
          phone: null,
          plate: null,
          vehicleName: null,
        ),
      );

      final card = tester.widget<TaDriverCard>(find.byType(TaDriverCard));
      expect(card.name, AppLocale.unKnown);
      expect(card.vehicleInfo, '---');
      expect(card.plateNumber, isNull);
      expect(card.initials, '');
    });
  });

  group('BookingSheet actions', () {
    testWidgets('Call is enabled when the driver has a phone', (tester) async {
      await _pumpSheet(tester, _logicWith(status: BookingStatus.accepted));

      final call = tester.widget<TaButton>(
        find.widgetWithText(TaButton, AppLocale.callDriver),
      );
      expect(call.isEnabled, isTrue);
    });

    testWidgets('Call is disabled when there is no phone to dial',
        (tester) async {
      await _pumpSheet(
        tester,
        _logicWith(status: BookingStatus.accepted, phone: null),
      );

      final call = tester.widget<TaButton>(
        find.widgetWithText(TaButton, AppLocale.callDriver),
      );
      expect(call.isEnabled, isFalse);
    });

    testWidgets('Call is the only button; Safety waits for the feature',
        (tester) async {
      await _pumpSheet(tester, _logicWith(status: BookingStatus.accepted));

      expect(find.byType(TaButton), findsOneWidget);
      expect(find.text(AppLocale.safety), findsNothing);
    });
  });

  group('BookingSheet cancel (Screen 9 §Interactions)', () {
    testWidgets('cancel opens the confirm dialog and does not call the API yet',
        (tester) async {
      final cancelApi = _FakeCancelBookingApi(const Ok(true));
      final logic = BookingMapLogic(
        checkBookingApi: _FakeCheckBookingApi(),
        isSocketConnected: () => true,
        cancelBookingRepo: cancelApi,
        onCancelRide: () {},
      );
      logic.state.bookingRequestData = RequestBookingModel(
        data: Data(status: BookingStatus.accepted),
      );
      await _pumpSheet(tester, logic);

      await tester.tap(find.text(AppLocale.cancelBooking));
      await tester.pumpAndSettle();

      expect(find.text(AppLocale.titleCancelBooking), findsOneWidget);
      expect(find.text(AppLocale.keepWaiting), findsOneWidget);
      expect(cancelApi.calls, 0, reason: 'confirming is what cancels');
    });

    testWidgets('"Keep waiting" closes the dialog and cancels nothing',
        (tester) async {
      final cancelApi = _FakeCancelBookingApi(const Ok(true));
      final logic = BookingMapLogic(
        checkBookingApi: _FakeCheckBookingApi(),
        isSocketConnected: () => true,
        cancelBookingRepo: cancelApi,
        onCancelRide: () {},
      );
      logic.state.bookingRequestData = RequestBookingModel(
        data: Data(status: BookingStatus.accepted),
      );
      await _pumpSheet(tester, logic);

      await tester.tap(find.text(AppLocale.cancelBooking));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TaButton, AppLocale.keepWaiting));
      await tester.pumpAndSettle();

      expect(find.text(AppLocale.titleCancelBooking), findsNothing);
      expect(cancelApi.calls, 0);
      expect(find.byType(BookingSheet), findsOneWidget);
    });

    testWidgets('confirming calls the API, emits the cancel and toasts',
        (tester) async {
      final cancelApi = _FakeCancelBookingApi(const Ok(true));
      var emitted = 0;
      final logic = BookingMapLogic(
        checkBookingApi: _FakeCheckBookingApi(),
        isSocketConnected: () => true,
        cancelBookingRepo: cancelApi,
        onCancelRide: () => emitted++,
      );
      logic.state.bookingRequestData = RequestBookingModel(
        data: Data(status: BookingStatus.accepted),
      );
      await _pumpSheet(tester, logic);

      await tester.tap(find.text(AppLocale.cancelBooking));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TaButton, AppLocale.yesCancel));
      await tester.pump();
      await tester.pump();

      expect(cancelApi.calls, 1);
      expect(emitted, 1, reason: 'the pinned passengerCancelDrive emit');
      expect(find.text(AppLocale.bookingCancelled), findsOneWidget);

      await tester.pumpAndSettle();
      expect(
        find.byKey(_homeMarker),
        findsOneWidget,
        reason: 'a confirmed cancel returns to the shell',
      );
      expect(find.byType(BookingSheet), findsNothing);

      // Let the toast's 2400ms auto-dismiss run out so no timer is pending.
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('a failed cancel reports it and keeps the passenger on the ride',
        (tester) async {
      final cancelApi = _FakeCancelBookingApi(
        const Err(
          ApiException(
            type: ApiErrorType.connection,
            message: 'no connection',
          ),
        ),
      );
      var emitted = 0;
      final logic = BookingMapLogic(
        checkBookingApi: _FakeCheckBookingApi(),
        isSocketConnected: () => true,
        cancelBookingRepo: cancelApi,
        onCancelRide: () => emitted++,
      );
      logic.state.bookingRequestData = RequestBookingModel(
        data: Data(status: BookingStatus.accepted),
      );
      await _pumpSheet(tester, logic);

      await tester.tap(find.text(AppLocale.cancelBooking));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TaButton, AppLocale.yesCancel));
      await tester.pump();
      await tester.pump();

      expect(cancelApi.calls, 1);
      expect(emitted, 0, reason: 'nothing was cancelled, so nothing is emitted');
      expect(find.text(AppLocale.cancelBookingFailed), findsOneWidget);
      expect(
        find.byType(BookingSheet),
        findsOneWidget,
        reason:
            'leaving a booking the backend still considers live would strand '
            'the passenger with no way back to it',
      );
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
