import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:com.tara.passenger/mock/mock_fixtures.dart';
import 'package:com.tara.passenger/mock/mock_mode.dart';

/// The invite QR, the rewards and the invite code at sign-up, answered with
/// made-up data on the **real** backend (D41).
///
/// The backend has no invite routes yet. Everything else in the app stays
/// real: sign-in, booking, trips, history. Only the two invite routes are
/// answered from here, with the QA mock backend's figures.
///
/// **On in debug and profile builds, off in a release build** (D47), so a
/// store build cannot carry it by accident. Any build can say otherwise with
/// `--dart-define=DEMO_INVITE=true` or `=false` — the test APK passes `true`.
/// The driver app's flag is off in every build by default (DD-55). It is a
/// compile-time constant: a build with it off has none of this.
///
/// **What is made up:** the passenger's own code and link, the people they
/// invited, the rewards and the ride credit balance. Every passenger sees the
/// same ones. The credit cannot be used on a trip (`rideCreditUsable`): the
/// real backend would ignore it and the driver would still be owed the
/// whole fare.
///
/// **Remove this when the backend has the routes**, and turn it off for any
/// build that goes to a store before then.
class DemoInvite {
  const DemoInvite._();

  static const bool enabled =
      bool.fromEnvironment('DEMO_INVITE', defaultValue: !kReleaseMode);

  /// QA mock mode already answers the whole feature; this stands aside.
  static bool get isActive => enabled && !MockMode.isActive;
}

/// Answers the two invite routes from made-up data. Every other request
/// goes to the network untouched.
class DemoInviteInterceptor extends Interceptor {
  DemoInviteInterceptor({
    @visibleForTesting bool Function()? isActive,
    @visibleForTesting DateTime Function()? clock,
    @visibleForTesting Duration latency = const Duration(milliseconds: 350),
  })  : _isActive = isActive ?? (() => DemoInvite.isActive),
        _now = clock ?? DateTime.now,
        _latency = latency;

  final bool Function() _isActive;
  final DateTime Function() _now;

  /// A made-up answer that arrives instantly looks made up.
  final Duration _latency;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isActive()) return handler.next(options);

    final String path = options.uri.path;
    final Map<String, dynamic> answer;
    if (path.endsWith('/taxi-passenger/referral')) {
      answer = MockData.referral(_now());
    } else if (path.endsWith('/taxi-passenger/referral/check-code')) {
      answer = _checkCode(options.uri.queryParameters['code']);
    } else {
      return handler.next(options);
    }

    await Future<void>.delayed(_latency);
    handler.resolve(
      Response<dynamic>(
        requestOptions: options,
        statusCode: 200,
        data: answer,
      ),
      // `true`: let the API log, earlier in the chain, see the answer too.
      true,
    );
  }

  /// The mock backend's codes, and the passenger's own as well: here every
  /// passenger shows the same made-up QR, so the one on a friend's phone has
  /// to be a code sign-up accepts.
  Map<String, dynamic> _checkCode(Object? raw) {
    if (MockData.inviteCodeOf(raw) != MockData.inviteCode) {
      return MockData.inviteCodeCheck(raw);
    }
    return <String, dynamic>{
      'status': true,
      'message': 'Success',
      'data': <String, dynamic>{
        'valid': true,
        'inviter_name': MockData.passengerName,
      },
    };
  }
}
