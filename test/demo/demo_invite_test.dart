import 'package:com.tara.passenger/core/network/api_client.dart';
import 'package:com.tara.passenger/demo/demo_invite.dart';
import 'package:com.tara.passenger/mock/mock_fixtures.dart';
import 'package:com.tara.passenger/presentation/screens/invite/data/datasource/referral_datasource.dart';
import 'package:com.tara.passenger/presentation/screens/invite/data/models/referral_model.dart';
import 'package:com.tara.passenger/presentation/screens/invite/invite_presentation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter_test/flutter_test.dart';

/// D41 — the invite routes answered with made-up data on the real backend,
/// which has none of them. Nothing else is answered here.
void main() {
  // D47: a store build cannot carry the sample data by accident. The release
  // half cannot run here (tests are never a release build); this pins the
  // half that can.
  test('on by default outside a release build', () {
    expect(DemoInvite.enabled, !kReleaseMode);
    expect(DemoInvite.enabled, isTrue);
  });

  /// What the stand-in for the real backend was asked.
  late List<String> reachedBackend;
  late bool demoOn;
  late Dio dio;

  setUp(() {
    reachedBackend = <String>[];
    demoOn = true;
    dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..interceptors.add(DemoInviteInterceptor(
        isActive: () => demoOn,
        clock: () => DateTime(2026, 10, 13, 12),
        latency: Duration.zero,
      ))
      // The "real backend": one route it knows, and no invite route.
      ..interceptors.add(InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler h) {
          reachedBackend.add(options.uri.path);
          if (options.uri.path.endsWith('/taxi-passenger/vehicle-types')) {
            return h.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{'status': true, 'data': <dynamic>[]},
              ),
              true,
            );
          }
          h.reject(
            DioException.badResponse(
              statusCode: 404,
              requestOptions: options,
              response: Response<dynamic>(
                requestOptions: options,
                statusCode: 404,
                data: <String, dynamic>{'message': 'Incorect route'},
              ),
            ),
            true,
          );
        },
      ));
  });

  group('demo on', () {
    test('the referral is answered without reaching the backend', () async {
      final response = await dio.get<dynamic>('/taxi-passenger/referral');
      final referral = ReferralModel.fromJson(response.data);

      expect(reachedBackend, isEmpty);
      expect(referral.code, MockData.inviteCode);
      expect(referral.rewardBalance, 2.07);
    });

    test('a code is checked against the made-up inviters', () async {
      Future<InviteCodeCheck> check(String code) async =>
          InviteCodeCheck.fromJson((await dio.get<dynamic>(
            '/taxi-passenger/referral/check-code',
            queryParameters: <String, dynamic>{'code': code},
          ))
              .data);

      final known = await check('pu7k2m');
      final unknown = await check('NOBODY1');

      expect(reachedBackend, isEmpty);
      expect(known.valid, isTrue);
      expect(known.inviterName, 'Dara Sok');
      expect(unknown.valid, isFalse);
    });

    test('the code on a friend\'s passenger QR is accepted at sign-up',
        () async {
      // Every passenger shows the same made-up QR. What the scanner reads
      // from it is the link; the code is its last part.
      final scanned = parseInviteCode(MockData.inviteLink);
      final response = await dio.get<dynamic>(
        '/taxi-passenger/referral/check-code',
        queryParameters: <String, dynamic>{'code': scanned},
      );
      final check = InviteCodeCheck.fromJson(response.data);

      expect(scanned, MockData.inviteCode);
      expect(check.valid, isTrue);
      expect(check.inviterName, MockData.passengerName);
    });

    test('every other request goes to the backend', () async {
      await dio.get<dynamic>('/taxi-passenger/vehicle-types');

      expect(reachedBackend, <String>['/taxi-passenger/vehicle-types']);
    });

    test('the app reads it through its own client', () async {
      final result = await ReferralDatasource(apiClient: ApiClient(dio: dio))
          .checkCode('SOKHA88');

      result.when(
        ok: (check) => expect(check.inviterName, 'Sokha Vann'),
        err: (error) => fail('refused: ${error.message}'),
      );
    });
  });

  test('demo off: the invite routes reach the backend, which has none',
      () async {
    demoOn = false;

    await expectLater(
      dio.get<dynamic>('/taxi-passenger/referral'),
      throwsA(isA<DioException>()
          .having((e) => e.response?.statusCode, 'status', 404)),
    );
    expect(reachedBackend, <String>['/taxi-passenger/referral']);
  });
}
