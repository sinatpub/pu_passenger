import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/network/api_exception.dart';
import 'package:com.tara.passenger/core/network/result.dart';
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
      typeVehicle: TypeVehicle(name: vehicleName),
      driver: Driver(
        name: driverName,
        phone: phone,
        vehicle: Vehicle(plateNumber: plate),
      ),
    ),
  );
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
    testWidgets('accepted: timeline at step 1, cancel offered', (tester) async {
      await _pumpSheet(tester, _logicWith(status: BookingStatus.accepted));

      final timeline = tester.widget<TaTimeline>(find.byType(TaTimeline));
      expect(timeline.currentStep, 0);
      expect(find.text(AppLocale.cancelBooking), findsOneWidget);
    });

    testWidgets('arrival: timeline at step 2, cancel still offered',
        (tester) async {
      await _pumpSheet(tester, _logicWith(status: BookingStatus.arrival));

      final timeline = tester.widget<TaTimeline>(find.byType(TaTimeline));
      expect(timeline.currentStep, 1);
      expect(find.text(AppLocale.cancelBooking), findsOneWidget);
    });

    testWidgets('onGoing: timeline at step 3 and cancel is withdrawn',
        (tester) async {
      await _pumpSheet(tester, _logicWith(status: BookingStatus.onGoing));

      final timeline = tester.widget<TaTimeline>(find.byType(TaTimeline));
      expect(timeline.currentStep, 2);
      expect(
        find.text(AppLocale.cancelBooking),
        findsNothing,
        reason: 'the passenger is already in the vehicle',
      );
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

    testWidgets('Safety toasts "coming soon" rather than navigating',
        (tester) async {
      await _pumpSheet(tester, _logicWith(status: BookingStatus.accepted));

      await tester.tap(find.widgetWithText(TaButton, AppLocale.safety));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(AppLocale.safetyComingSoon), findsOneWidget);
      // Let the toast's 2400ms auto-dismiss run out so no timer is pending.
      await tester.pump(const Duration(seconds: 3));
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

      await tester.tap(find.widgetWithText(TaButton, AppLocale.cancelBooking));
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

      await tester.tap(find.widgetWithText(TaButton, AppLocale.cancelBooking));
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

      await tester.tap(find.widgetWithText(TaButton, AppLocale.cancelBooking));
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

      await tester.tap(find.widgetWithText(TaButton, AppLocale.cancelBooking));
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
