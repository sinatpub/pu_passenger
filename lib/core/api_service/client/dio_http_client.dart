import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:com.tara.passenger/core/network/curl_log_interceptor.dart';
import 'package:com.tara.passenger/core/utils/app_constant.dart';
import 'package:com.tara.passenger/mock/mock_http_interceptor.dart';
import 'package:com.tara.passenger/mock/mock_mode.dart';

class BaseHttpClient {
  static late final Dio dio;

  static void init() {
    final BaseOptions options = BaseOptions(
      baseUrl: AppConstant.baseUrlApi,
      connectTimeout: const Duration(minutes: 1),
      receiveTimeout: const Duration(minutes: 1),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json"
      }
    );

    dio = Dio()..options = options;

    // Each call as a copyable `curl` line and its response. Not in a release
    // build: an entry holds the bearer token and the request body. It goes
    // first so it also sees what the mock backend below answers.
    if (!kReleaseMode) dio.interceptors.add(CurlLogInterceptor());

    // QA mock mode (`lib/mock/`). `MockMode.enabled` is a compile-time
    // constant that is false in every release build, so this is dead code
    // there. The interceptor passes requests through when mock mode was
    // switched off at runtime.
    if (MockMode.enabled) dio.interceptors.add(MockHttpInterceptor());
  }
}

const JsonDecoder decoder = JsonDecoder();
const JsonEncoder encoder = JsonEncoder.withIndent('  ');
