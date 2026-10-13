import 'package:com.tara.passenger/core/utils/status_util.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/mock/mock_backend.dart';
import 'package:com.tara.passenger/mock/mock_fixtures.dart';
import 'package:com.tara.passenger/mock/mock_mode.dart';
import 'package:com.tara.passenger/mock/mock_models.dart';
import 'package:com.tara.passenger/presentation/screens/invite/data/models/referral_model.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

/// D40 — the mock backend's side of invite and ride credit. It is the only
/// backend the feature has, so these are the rules the screens are built on:
/// the ones in the backend spec, section 5.
void main() {
  final DateTime now = DateTime(2026, 10, 13, 10);

  /// With [scale] the simulated driver runs the whole trip at once; without
  /// it nobody accepts, and a booking stays a request.
  MockBackend backend({Duration Function(Duration)? scale}) {
    final MockBackend b = MockBackend(
      clock: () => now,
      settings: () => MockSettings(
        dispatch: scale == null ? MockDispatch.manual : MockDispatch.auto,
      ),
      scale: scale ?? (d) => d,
      persist: false,
    );
    addTearDown(b.dispose);
    return b;
  }

  Future<ReferralModel> referral(MockBackend b) async => ReferralModel.fromJson(
        (await b.handle(const MockRequest(
          method: 'GET',
          path: '/taxi-passenger/referral',
        )))
            .data,
      );

  MockRequest booking({String? rideCredit}) => MockRequest(
        method: 'POST',
        path: '/taxi-passenger/request-booking',
        body: {
          'start_latitude': '11.569600',
          'start_longitude': '104.921000',
          'end_latitude': '11.546600',
          'end_longitude': '104.844100',
          'type_vehicle_id': 2,
          if (rideCredit != null) 'ride_credit': rideCredit,
        },
      );

  test('OTP 1111 is a phone with no account: the app opens sign-up', () async {
    final reply = await backend().handle(const MockRequest(
      method: 'POST',
      path: '/taxi-passenger/verify-phone-otp',
      body: {'otp_code': '1111'},
    ));
    final data = (reply.data as Map)['data'] as Map;

    expect(reply.statusCode, 200);
    expect(data['user'], isNull);
    expect(data['token'], isNull);
  });

  group('invite code', () {
    test('a known code is valid, with the inviter\'s name', () async {
      final reply = await backend().handle(const MockRequest(
        method: 'GET',
        path: '/taxi-passenger/referral/check-code',
        query: {'code': 'pu7k2m'},
      ));
      final check = InviteCodeCheck.fromJson(reply.data);

      expect(check.valid, isTrue);
      expect(check.inviterName, MockData.inviteCodes['PU7K2M']);
    });

    test('an unknown code is a 200 that says no', () async {
      final reply = await backend().handle(const MockRequest(
        method: 'GET',
        path: '/taxi-passenger/referral/check-code',
        query: {'code': 'NOPE00'},
      ));

      expect(reply.statusCode, 200);
      expect(InviteCodeCheck.fromJson(reply.data).valid, isFalse);
    });

    test('sign-up takes a known code, or none', () async {
      final b = backend();
      for (final Map<String, dynamic> body in [
        <String, dynamic>{},
        {'invite_code': ''},
        {'invite_code': 'SOKHA88'},
      ]) {
        final reply = await b.handle(MockRequest(
          method: 'POST',
          path: '/taxi-passenger/register',
          body: body,
        ));
        expect(reply.statusCode, 200, reason: '$body');
      }
    });

    test('sign-up refuses a code nobody has', () async {
      final reply = await backend().handle(const MockRequest(
        method: 'POST',
        path: '/taxi-passenger/register',
        body: {'invite_code': 'NOPE00'},
      ));

      expect(reply.statusCode, 422);
    });
  });

  test('the referral answer adds up: credit is earned minus used', () async {
    final model = await referral(backend());

    expect(model.code, MockData.inviteCode);
    expect(model.link, endsWith(MockData.inviteCode));
    expect(model.invitees, hasLength(2));
    expect(model.uses, isEmpty);
    expect(model.rewardBalance, 2.07);
    expect(
      model.rewards.fold<double>(0, (sum, r) => sum + r.amount!),
      closeTo(2.07, 0.0001),
    );
  });

  group('ride credit on a trip', () {
    test('asking for more than the balance is refused', () async {
      final reply = await backend().handle(booking(rideCredit: '5.00'));

      expect(reply.statusCode, 422);
    });

    test('credit is taken at drop-off, and never more than was asked', () {
      fakeAsync((async) {
        final b = backend(scale: (_) => Duration.zero);
        final List<MockSocketEvent> events = <MockSocketEvent>[];
        final sub = b.socketEvents.listen(events.add);

        b.handle(booking(rideCredit: '1.00'));
        async.flushMicrotasks();
        async.elapse(Duration.zero);

        final drop = RequestBookingModel.fromJson(
            events.firstWhere((e) => e.name == 'driverDropDrive').data);
        final payment = drop.data!.payment!;
        expect(drop.data!.status, BookingStatus.pendingPayment);
        expect(double.parse(payment.amount!), greaterThan(1.00));
        expect(payment.rideCredit, '1.00');

        late ReferralModel after;
        referral(b).then((m) => after = m);
        async.flushMicrotasks();
        expect(after.rewardBalance, closeTo(1.07, 0.0001));
        expect(after.uses.single.amount, 1.00);
        expect(after.uses.single.bookingId, drop.data!.id);

        sub.cancel();
      });
    });

    test('a trip without credit costs none', () {
      fakeAsync((async) {
        final b = backend(scale: (_) => Duration.zero);
        final List<MockSocketEvent> events = <MockSocketEvent>[];
        final sub = b.socketEvents.listen(events.add);

        b.handle(booking());
        async.flushMicrotasks();
        async.elapse(Duration.zero);

        final drop = RequestBookingModel.fromJson(
            events.firstWhere((e) => e.name == 'driverDropDrive').data);
        expect(drop.data!.payment!.rideCredit, '0.00');
        expect(b.rideCreditBalance, 2.07);

        sub.cancel();
      });
    });

    test('a cancelled trip costs none: nothing is taken at booking', () async {
      final b = backend();
      await b.handle(booking(rideCredit: '2.00'));
      await b.handle(const MockRequest(
        method: 'POST',
        path: '/taxi-passenger/cancel-request-booking-info',
      ));

      expect(b.rideCreditBalance, 2.07);
      expect((await referral(b)).uses, isEmpty);
    });

    test('"Reset all" gives the credit back', () {
      fakeAsync((async) {
        final b = backend(scale: (_) => Duration.zero);
        b.handle(booking(rideCredit: '2.07'));
        async.flushMicrotasks();
        async.elapse(Duration.zero);
        expect(b.rideCreditBalance, 0);

        b.resetAll();
        expect(b.rideCreditBalance, 2.07);
      });
    });
  });
}
