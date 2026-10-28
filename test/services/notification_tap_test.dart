import 'package:com.tara.passenger/core/utils/status_util.dart';
import 'package:com.tara.passenger/data/datasources/check_request_book_source.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/services/notification_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// The passenger's booking as the server has it. Hand-written fake, no
/// mocktail (`.agent/skills/testing.md`).
class _FakeCheckBookingApi extends CheckBookingApi {
  _FakeCheckBookingApi(this.status, {this.hasBooking = true});

  final int? status;
  final bool hasBooking;
  int calls = 0;

  @override
  Future<RequestBookingModel> checkBookingApi() async {
    calls++;
    return RequestBookingModel(
        data: hasBooking ? Data(id: 1, status: status) : null);
  }
}

/// Audit S-4 — where tapping a push takes the passenger.
void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });
  tearDown(Get.reset);

  group('announcementIdOf', () {
    test('reads notification_id, as a number or as text', () {
      expect(announcementIdOf({'notification_id': '12'}), 12);
      expect(announcementIdOf({'notification_id': 12}), 12);
    });

    test('no id: not about an announcement', () {
      expect(announcementIdOf({}), isNull);
      expect(announcementIdOf({'notification_id': ''}), isNull);
      expect(announcementIdOf({'notification_type': 'service_booking'}),
          isNull);
    });
  });

  group('handleOnNotificationPress', () {
    Object? detailArguments;

    Future<void> pumpHome(WidgetTester tester) async {
      detailArguments = null;
      await tester.pumpWidget(GetMaterialApp(
        initialRoute: '/home-stub',
        getPages: [
          GetPage(
            name: '/home-stub',
            page: () => const Scaffold(body: Text('home')),
          ),
          GetPage(
            name: AppRoutes.ANNOUNCEMENTDETAIL,
            page: () {
              detailArguments = Get.arguments;
              return const Scaffold(body: Text('announcement'));
            },
          ),
          GetPage(
            name: AppRoutes.BOOKING,
            page: () => const Scaffold(body: Text('ride')),
          ),
          GetPage(
            name: AppRoutes.CALCULATEFEE,
            page: () => const Scaffold(body: Text('fee')),
          ),
        ],
      ));
    }

    testWidgets('an announcement opens that announcement', (tester) async {
      await pumpHome(tester);
      final api = _FakeCheckBookingApi(BookingStatus.accepted);

      await NotificationLogic.handleOnNotificationPress(
          {'notification_id': '12'},
          checkBookingApi: api);
      await tester.pumpAndSettle();

      expect(find.text('announcement'), findsOneWidget);
      expect(detailArguments, {'id': 12});
      expect(api.calls, 0, reason: 'nothing to ask about a ride');
    });

    testWidgets('anything else with a ride under way opens the ride',
        (tester) async {
      await pumpHome(tester);

      await NotificationLogic.handleOnNotificationPress(
          {}, checkBookingApi: _FakeCheckBookingApi(BookingStatus.onGoing));
      await tester.pumpAndSettle();

      expect(find.text('ride'), findsOneWidget);
    });

    testWidgets('a trip waiting for payment opens the fee page',
        (tester) async {
      await pumpHome(tester);

      await NotificationLogic.handleOnNotificationPress({},
          checkBookingApi: _FakeCheckBookingApi(BookingStatus.pendingPayment));
      await tester.pumpAndSettle();

      expect(find.text('fee'), findsOneWidget);
    });

    testWidgets('no ride: the passenger stays where they are',
        (tester) async {
      await pumpHome(tester);

      await NotificationLogic.handleOnNotificationPress({},
          checkBookingApi: _FakeCheckBookingApi(null, hasBooking: false));
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
      expect(find.text('ride'), findsNothing);
    });

    testWidgets('a push that launched the app navigates nowhere',
        (tester) async {
      await pumpHome(tester);
      final api = _FakeCheckBookingApi(BookingStatus.accepted);

      await NotificationLogic.handleOnNotificationPress(
          {'notification_id': '12'},
          isTerminate: true,
          checkBookingApi: api);
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
      expect(api.calls, 0);
    });
  });
}
