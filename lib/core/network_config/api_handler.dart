// ignore_for_file: avoid_shadowing_type_parameters
import 'dart:async';
import 'dart:convert';
import 'package:com.tara.passenger/core/utils/app_constant.dart';
import 'package:com.tara.passenger/core/utils/app_log.dart';
import 'package:com.tara.passenger/storages/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import '../network_config/interceptor/interceptor_client.dart';
import 'exception/exception.dart';
import 'exception/exception_handler.dart';
import 'http_client.dart';
import 'method.dart';
import 'paging.dart';
import 'typedefs.dart';

class ApiHandler<T> {
  final T Function(dynamic value) converter;
  final String method;
  static bool isHandlingTokenExpiration = false;

  ApiHandler({
    required this.method,
    required this.converter,
  });

  //region Method
  factory ApiHandler.get({
    required T Function(dynamic value) converter,
  }) =>
      ApiHandler<T>(converter: converter, method: Method.GET);

  factory ApiHandler.post({
    required T Function(dynamic value) converter,
  }) =>
      ApiHandler<T>(converter: converter, method: Method.POST);

  factory ApiHandler.put({
    required T Function(dynamic value) converter,
  }) =>
      ApiHandler<T>(converter: converter, method: Method.PUT);

  factory ApiHandler.patch({
    required T Function(dynamic value) converter,
  }) =>
      ApiHandler<T>(converter: converter, method: Method.PATCH);

  factory ApiHandler.delete({
    required T Function(dynamic value) converter,
  }) =>
      ApiHandler<T>(converter: converter, method: Method.DELETE);

  factory ApiHandler.head({
    required T Function(dynamic value) converter,
  }) =>
      ApiHandler<T>(converter: converter, method: Method.HEAD);

  factory ApiHandler.options({
    required T Function(dynamic value) converter,
  }) =>
      ApiHandler<T>(converter: converter, method: Method.OPTIONS);

  Future<T?> execute({
    required OnComplete<T> onComplete,
    OnFail? onFail,
    Future<void> Function()? onFinished,
    bool isAuthenticated = true,
    required String endPoint,
    JSON? body,
    JSON? formData,
    JSON? queryParams,
    String? customApikey,
    String? customApikeyTag,
  }) async {
    GetStoragePref storagePref = GetStoragePref();
    var driverData = await storagePref.getJsonToken;
    String? accessToken = driverData.data?.token;
    AppConstant.driverToken = accessToken;

    final client = isAuthenticated
        ? AuthHttpClient(
            InterceptorClient(
              http.Client(),
              // responseInterceptor: Get.find<ApiInterceptor>(),
            ),
            customApikey: customApikey,
            customApikeyTag: customApikeyTag,
            token: "${AppConstant.driverToken}",
          )
        : NormalHttpClient(InterceptorClient(http.Client()));

    try {
      //region Set Up Body
      http.BaseRequest request = http.Request(method, Uri.parse(endPoint));

      if (body != null) {
        request = http.Request(method, Uri.parse(endPoint))
          ..headers['Content-Type'] = 'application/json'
          ..body = jsonEncode(body);
      } else if (formData != null) {
        final multipartRequest =
            http.MultipartRequest(method, Uri.parse(endPoint))
              ..headers['Content-Type'] = 'multipart/form-data';
        formData.forEach((key, value) async {
          xLog(message: "value: ${value.runtimeType.toString()}");
          if (value.runtimeType == List<XFile>) {
            for (final file in value) {
              var resultFile =
                  await http.MultipartFile.fromPath(key, file.path);
              xPrettyLog(
                  message: "resultFile: ${resultFile.runtimeType.toString()}");
              multipartRequest.files.add(resultFile);
            }
          } else {
            multipartRequest.fields[key] = value.toString();
          }
        });

        request = multipartRequest;
      }
      if (queryParams != null) {
        final uri = Uri.parse(endPoint).replace(queryParameters: queryParams);
        request = http.Request(method, uri);
      }
      //endregion

      //region request
      http.StreamedResponse response =
          await client.send(request).timeout(const Duration(minutes: 1));
      final responseBody = await _streamToByte(response.stream);
      if (responseBody.isEmpty) {
        if (onFail != null) {
          return await onFail(ExceptionHandler.handle(
              ApiException(statusCode: response.statusCode, message: "")));
        } else {
          throw Exception(response);
        }
      }

      final jsonResponse = jsonDecode(responseBody);
      xPrettyLog(message: "jsonResponse: $jsonResponse");
      xPrettyLog(message: "jsonResponse type: ${jsonResponse.runtimeType}");
      xPrettyLog(message: "converter: ${converter.toString()}");
      //endregion

      if (response.statusCode != 200) {
        if (onFail != null) {
          await onFail(ExceptionHandler.handle(ApiException(
              statusCode: response.statusCode,
              message: "",
              body: jsonResponse)));
        } else {
          throw Exception(response);
        }
      } else {
        final T data = converter(jsonResponse);
        return await onComplete(data);
      }
    } catch (error, stack) {
      xPrettyLog(message: "$error\n$stack");
      if (onFail != null) {
        await onFail(ExceptionHandler.handle(error));
      } else {
        ExceptionHandler.handle(error);
      }
    } finally {
      client.close(); // Close the client when finished
      if (onFinished != null) {
        await onFinished();
      }
    }
    return null;
  }

  Future<Paging<T>?> executePaging<T>({
    required OnComplete<Paging<T>?> onComplete,
    OnFail? onFail,
    Future<void> Function()? onFinished,
    bool isAuthenticated = true,
    required String endPoint,
    JSON? body,
    JSON? formData,
    JSON? queryParams,
    String? customApikey,
    String? customApikeyTag,
  }) async {
    GetStoragePref storagePref = GetStoragePref();

    // Await token retrieval
    var driverData = await storagePref.getJsonToken;
    String? accessToken = driverData.data?.token;
    AppConstant.driverToken = accessToken;
    final client = isAuthenticated
        ? AuthHttpClient(
            InterceptorClient(
              http.Client(),
              // responseInterceptor: Get.find<ApiInterceptor>(),
            ),
            customApikey: customApikey,
            customApikeyTag: customApikeyTag,
            token: "${AppConstant.driverToken}",
          )
        : NormalHttpClient(InterceptorClient(http.Client()));

    try {
      //region Set Up Body
      http.BaseRequest request = http.Request(method, Uri.parse(endPoint));

      if (body != null) {
        request = http.Request(method, Uri.parse(endPoint))
          ..headers['Content-Type'] = 'application/json'
          ..body = jsonEncode(body);
      } else if (formData != null) {
        final multipartRequest =
            http.MultipartRequest(method, Uri.parse(endPoint));
        formData.forEach((key, value) {
          if (value is List<http.MultipartFile>) {
            for (final file in value) {
              multipartRequest.files.add(file);
            }
          } else {
            multipartRequest.fields[key] = value.toString();
          }
        });
        request = multipartRequest;
      }
      if (queryParams != null) {
        final uri = Uri.parse(endPoint).replace(queryParameters: queryParams);
        request = http.Request(method, uri);
      }
      //endregion

      //region request
      http.StreamedResponse response =
          await client.send(request).timeout(const Duration(minutes: 1));
      final responseBody = await _streamToByte(response.stream);
      if (responseBody.isEmpty) {
        if (onFail != null) {
          return await onFail(ExceptionHandler.handle(
              ApiException(statusCode: response.statusCode, message: "")));
        } else {
          throw Future.error(Exception(response));
        }
      }
      final jsonResponse = jsonDecode(responseBody);

      xPrettyLog(message: "jsonResponse: $jsonResponse");
      xPrettyLog(message: "jsonResponse type: ${jsonResponse.runtimeType}");
      xPrettyLog(message: "converter: ${converter.toString()}");
      xPrettyLog(message: "request: ${request.url.toString()}");

      //endregion

      if (response.statusCode != 200) {
        if (onFail != null) {
          await onFail(ExceptionHandler.handle(ApiException(
              statusCode: response.statusCode,
              message: "",
              body: jsonResponse)));
        } else {
          throw Exception(response);
        }
      } else {
        // Extract paging information from the response
        final pagingData = Paging<T>.fromMap(jsonResponse, type: T);

        return await onComplete(pagingData);
      }
    } catch (error, stack) {
      Logger().e("$error\n$stack");
      if (onFail != null) {
        await onFail(ExceptionHandler.handle(error));
      } else {
        throw Future.error(error);
      }
    } finally {
      client.close();
      if (onFinished != null) {
        await onFinished();
      }
    }
    return null;
  }

  Future<String> _streamToByte(Stream<List<int>> stream) async {
    final bytes = <int>[];

    await for (final chunk in stream) {
      bytes.addAll(chunk);
    }

    return utf8.decode(bytes);
  }
}
