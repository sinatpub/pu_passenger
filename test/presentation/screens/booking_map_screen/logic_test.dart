import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:com.tara.passenger/app/logic.dart';
import 'package:com.tara.passenger/core/utils/status_util.dart';
import 'package:com.tara.passenger/data/datasources/check_request_book_source.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/booking_map_screen/logic.dart';
import 'package:com.tara.passenger/service/location_imp.dart';

/// P-09 (docs/12, docs/09 §7, docs/08 M-2) — `getBookingInfo` is triggered
/// by two independent channels (a 10s poll and socket events), both racing
/// to write the same `state.bookingRequestData`. A slower, earlier-started
/// call must not overwrite state a faster, later-started call already
/// wrote. Hand-written fake, no mocktail (`.agent/skills/testing.md`).
class _FakeCheckBookingApi extends CheckBookingApi {
  final List<Completer<RequestBookingModel>> _completers = [];

  @override
  Future<RequestBookingModel> checkBookingApi() {
    final completer = Completer<RequestBookingModel>();
    _completers.add(completer);
    return completer.future;
  }

  int get callCount => _completers.length;

  void completeCall(int index, RequestBookingModel response) {
    _completers[index].complete(response);
  }
}

/// `startLatitude`/`startLongitude` and `driver` are left null so
/// `drawPolyline()` hits its `start.latitude == 0` guard and returns before
/// any real network call — keeps this a pure logic test.
RequestBookingModel _modelWithStatus(int status) =>
    RequestBookingModel(data: Data(status: status));

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.put<LocationRepo>(LocationRepo());
    Get.put<AppLogic>(AppLogic());
  });

  tearDown(() => Get.reset());

  group('getBookingInfo out-of-order response guard', () {
    test('a single call updates state normally', () async {
      final fake = _FakeCheckBookingApi();
      final logic = BookingMapLogic(checkBookingApi: fake);

      final call = logic.getBookingInfo(isSilent: true);
      fake.completeCall(0, _modelWithStatus(BookingStatus.accepted));
      await call;

      expect(logic.state.bookingRequestData?.data?.status, BookingStatus.accepted);
    });

    test('a slower call started first does not overwrite a faster call started later', () async {
      final fake = _FakeCheckBookingApi();
      final logic = BookingMapLogic(checkBookingApi: fake);

      // Call 0 starts first (simulates the 10s poll firing).
      final firstCall = logic.getBookingInfo(isSilent: true);
      // Call 1 starts second, before call 0 has resolved (simulates a
      // socket event triggering a refresh while the poll is in flight).
      final secondCall = logic.getBookingInfo(isSilent: true);
      expect(fake.callCount, 2);

      // The newer call's response arrives first — this is the common case
      // (sockets are faster than a fixed 10s poll) and should apply.
      fake.completeCall(1, _modelWithStatus(BookingStatus.onGoing));
      await secondCall;
      expect(logic.state.bookingRequestData?.data?.status, BookingStatus.onGoing);

      // The older call's stale response arrives after — must be discarded,
      // not overwrite the newer state.
      fake.completeCall(0, _modelWithStatus(BookingStatus.accepted));
      await firstCall;
      expect(
        logic.state.bookingRequestData?.data?.status,
        BookingStatus.onGoing,
        reason: 'the stale "accepted" response must not regress the newer "onGoing" state',
      );
    });

    test('three interleaved calls: only the latest-started response wins', () async {
      final fake = _FakeCheckBookingApi();
      final logic = BookingMapLogic(checkBookingApi: fake);

      final call0 = logic.getBookingInfo(isSilent: true);
      final call1 = logic.getBookingInfo(isSilent: true);
      final call2 = logic.getBookingInfo(isSilent: true);

      // Resolve out of start order: 1, then 0, then 2 (the actually-latest
      // one). Only call2's response should be reflected at the end.
      fake.completeCall(1, _modelWithStatus(BookingStatus.accepted));
      await call1;
      fake.completeCall(0, _modelWithStatus(BookingStatus.request));
      await call0;
      fake.completeCall(2, _modelWithStatus(BookingStatus.arrival));
      await call2;

      expect(logic.state.bookingRequestData?.data?.status, BookingStatus.arrival);
    });
  });
}
