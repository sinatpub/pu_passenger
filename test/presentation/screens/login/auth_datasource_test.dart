import 'package:com.tara.passenger/core/network/api_client.dart';
import 'package:com.tara.passenger/core/network/result.dart';
import 'package:com.tara.passenger/data/models/user_response_model.dart';
import 'package:com.tara.passenger/presentation/screens/login/data/datasource/auth_datasource.dart';
import 'package:com.tara.passenger/presentation/screens/login/data/repository/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// The debug login's request (`DebugAuthBypass`): `POST /taxi-passenger/login`.
///
/// The response below is the `verify-phone-otp` shape, which this endpoint is
/// expected to share; it has not been seen from the real backend yet. The
/// token is made up.
void main() {
  late RequestOptions sent;

  AuthRepository repositoryAnswering(int status, Map<String, dynamic> body) {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          sent = options;
          final response = Response<dynamic>(
            requestOptions: options,
            statusCode: status,
            data: body,
          );
          if (status >= 400) {
            handler.reject(DioException(
              requestOptions: options,
              response: response,
              type: DioExceptionType.badResponse,
            ));
          } else {
            handler.resolve(response);
          }
        },
      ));
    return AuthRepository(AuthDatasource(apiClient: ApiClient(dio: dio)));
  }

  setUp(() {
    // A token from an earlier session must not ride along on a sign-in.
    FlutterSecureStorage.setMockInitialValues({'session_token': 'stale'});
  });

  test('passwordLogin posts the four fields, without a token', () async {
    final auth = repositoryAnswering(201, {
      'data': {
        'user': {'id': 7, 'name': 'Test Passenger', 'role_id': 3},
        'token': 'made-up-token',
      },
      'status': true,
      'message': 'success',
    });

    final result = await auth.passwordLogin(
      phone: '012345678',
      password: 'not-a-real-password',
      deviceToken: 'device-1',
      platform: 'android',
    );

    expect(sent.method, 'POST');
    expect(sent.path, '/taxi-passenger/login');
    expect(sent.data, {
      'phone': '012345678',
      'password': 'not-a-real-password',
      'device_token': 'device-1',
      'platform': 'android',
    });
    expect(sent.headers.containsKey('Authorization'), isFalse);

    final model = (result as Ok<UserResponseModel>).value;
    expect(model.data?.token, 'made-up-token');
    expect(model.data?.user?.id, 7);
    expect(model.data?.user?.name, 'Test Passenger');
  });

  test('a refused login carries the server message', () async {
    final auth = repositoryAnswering(422, {
      'data': null,
      'status': false,
      'message': 'User does not exist',
    });

    final result = await auth.passwordLogin(
      phone: '012345678',
      password: 'not-a-real-password',
      deviceToken: 'device-1',
      platform: 'android',
    );

    expect(
      (result as Err<UserResponseModel>).error.message,
      'User does not exist',
    );
  });
}
