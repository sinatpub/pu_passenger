import 'package:com.tara.passenger/core/network/api_exception.dart';
import 'package:com.tara.passenger/core/network/result.dart';
import 'package:com.tara.passenger/core/utils/debug_auth_bypass.dart';
import 'package:com.tara.passenger/data/models/user_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// The sign-in behind the debug login. `DebugAuthBypass.isEnabled` itself is
/// a compile-time constant, off in a test run, so the gate is checked on its
/// own and the sign-in through [debugPasswordSignIn].
void main() {
  late Map<String, String> sent;
  late List<String> savedTokens;
  late Result<UserResponseModel> answer;

  Future<Result<UserResponseModel>> login({
    required String phone,
    required String password,
    required String deviceToken,
    required String platform,
  }) async {
    sent = {
      'phone': phone,
      'password': password,
      'deviceToken': deviceToken,
      'platform': platform,
    };
    return answer;
  }

  Future<String?> signIn({
    String phone = '012345678',
    String password = 'not-a-real-password',
    String? deviceToken = 'fcm-1',
  }) =>
      debugPasswordSignIn(
        phone: phone,
        password: password,
        deviceToken: deviceToken,
        platform: 'android',
        login: login,
        save: (token, model) async => savedTokens.add(token),
      );

  UserResponseModel session({int? userId = 7, String? token = 'token-1'}) =>
      UserResponseModel(
        data: Data(
          user: userId == null ? null : User(id: userId, name: 'Test'),
          token: token,
        ),
        status: true,
        message: 'success',
      );

  setUp(() {
    sent = {};
    savedTokens = [];
    answer = Ok(session());
  });

  test('the gate is shut unless the build asks for the bypass', () async {
    expect(DebugAuthBypass.isEnabled, isFalse);
    expect(DebugAuthBypass.accepts(DebugAuthBypass.bypassCode), isFalse);
    expect(await DebugAuthBypass.seedSession(login), isFalse);
    expect(sent, isEmpty);
  });

  test('a user and a token are kept as a session', () async {
    expect(await signIn(), isNull);

    expect(sent, {
      'phone': '012345678',
      'password': 'not-a-real-password',
      'deviceToken': 'fcm-1',
      'platform': 'android',
    });
    expect(savedTokens, ['token-1']);
  });

  test('with no FCM token yet, a placeholder device token is sent', () async {
    await signIn(deviceToken: null);
    expect(sent['deviceToken'], DebugAuthBypass.noDeviceToken);

    await signIn(deviceToken: '');
    expect(sent['deviceToken'], DebugAuthBypass.noDeviceToken);
  });

  test('unset credentials make no request', () async {
    expect(await signIn(phone: ''), contains('DEBUG_LOGIN_PHONE'));
    expect(await signIn(password: ''), contains('DEBUG_LOGIN_PASSWORD'));

    expect(sent, isEmpty);
    expect(savedTokens, isEmpty);
  });

  test('a token without a user is not a session', () async {
    // The user id opens the socket; without it the app is half signed in.
    answer = Ok(session(userId: null));

    expect(await signIn(), 'success');
    expect(savedTokens, isEmpty);
  });

  test('a user without a token is not a session', () async {
    answer = Ok(session(token: ''));

    expect(await signIn(), 'success');
    expect(savedTokens, isEmpty);
  });

  test('a refused login gives the server message', () async {
    answer = const Err(ApiException(
      type: ApiErrorType.badResponse,
      message: 'User does not exist',
      statusCode: 422,
    ));

    expect(await signIn(), 'User does not exist');
    expect(savedTokens, isEmpty);
  });
}
