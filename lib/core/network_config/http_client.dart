import 'package:http/http.dart' as http;
import 'interceptor/interceptor_client.dart';

class AuthHttpClient extends http.BaseClient {
  final InterceptorClient _interceptorClient;
  final String token;
  final bool isGuest;
  String? customApikey;
  String? customApikeyTag;

  AuthHttpClient(
    this._interceptorClient, {
    required this.token,
    this.isGuest = false,
    this.customApikey,
    this.customApikeyTag,
  });

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (isGuest == true) {
      // request.headers[GPConfig.anonymousApiKeyTag] = GPConfig.anonymousApiKey;
    } else {
      if (customApikey != null) {
        request.headers[customApikeyTag ?? ""] = customApikey ?? "";
      } else {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    return _interceptorClient.send(request);
  }
}

class NormalHttpClient extends http.BaseClient {
  final InterceptorClient _interceptorClient;

  NormalHttpClient(this._interceptorClient);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _interceptorClient.send(request);
  }
}
