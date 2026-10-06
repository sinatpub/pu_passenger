import 'dart:async';

import 'package:com.tara.passenger/core/api_service/client/dio_http_client.dart';
import 'package:com.tara.passenger/services/session_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

import 'api_exception.dart';
import 'result.dart';

class ApiClient {
  ApiClient({Dio? dio, SessionService? session})
      : _dio = dio ?? BaseHttpClient.dio,
        _session = session ?? SessionService.instance;

  final Dio _dio;
  final SessionService _session;

  Future<Result<T>> request<T>({
    required String path,
    required String method,
    required T Function(Response response) decode,
    Map<String, dynamic>? query,
    dynamic body,
    bool requiresToken = true,
  }) async {
    try {
      final token = requiresToken ? await _session.getToken() : null;
      final response = await _dio.request(
        path,
        data: body,
        queryParameters: query,
        options: Options(
          method: method,
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );
      return Result.ok(decode(response));
    } on DioException catch (exception) {
      final apiException = ApiException.fromDioException(exception);
      if (apiException.endsSession) {
        unawaited(_session.handleUnauthorized());
      }
      return Result.err(apiException);
    } catch (exception) {
      // Almost always a response `decode` could not read. The caller gets a
      // generic error, so without this line the reason is lost: a model
      // that expects text and is sent a number fails here, silently.
      if (kDebugMode) {
        debugPrint(
          '[ApiClient] $method $path: could not read the response: $exception',
        );
      }
      return Result.err(ApiException.unknown(exception));
    }
  }
}
