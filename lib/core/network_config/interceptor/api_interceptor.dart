// import 'package:com.tara.passenger/app/logic.dart';
// import 'package:com.tara.passenger/routes/app_pages.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get.dart' as g;
// import 'package:logger/logger.dart';

// import 'interceptor_client.dart';
// import 'dart:async';
// import 'package:http/http.dart' as http;

// class ApiInterceptor implements ResponseInterceptor {
//   bool showDialog = false;
//   bool _isNavigating = false;
//   bool _isDialogShowing = false;
//   final _refreshLock = Lock();
//   @override
//   Future<http.StreamedResponse> interceptResponse(
//       http.StreamedResponse response) async {
//     // Handle response data, error, etc.
//     final statusCode = response.statusCode;

//     switch (statusCode) {
//       case 401:
//         {
//           EasyLoading.dismiss();
//           return (await _unauthorizedHandler(response));
//         }
//       default:
//         return response;
//     }
//   }

//   // Future<void> refreshToken() async {
//   //   final UserLocal userLocal = UserLocal();
//   //   final appLogic = g.Get.find<AppLogic>();

//   //   try {
//   //     final refreshedTokens = await appLogic.refreshToken();
//   //     if (refreshedTokens?.accessToken != null &&
//   //         refreshedTokens?.refreshToken != null) {
//   //       // Update tokens in local storage
//   //       userLocal.updateTokens(
//   //         accessToken: refreshedTokens!.accessToken ?? "",
//   //         refreshToken: refreshedTokens.refreshToken ?? "",
//   //       );

//   //       // Update tokens in AppLogic
//   //       appLogic.state.userResponse.value.accessToken =
//   //           refreshedTokens.accessToken;
//   //       appLogic.state.userResponse.value.refreshToken =
//   //           refreshedTokens.refreshToken;
//   //       appLogic.state.userResponse.refresh(); 

//   //       Logger().i("Tokens refreshed successfully.");
//   //     } else {
//   //       Logger().e("Failed to refresh tokens.");
//   //       throw Exception("Failed to refresh tokens.");
//   //     }
//   //   } catch (error) {
//   //     Logger().e("Token refresh failed: $error");
//   //     // _navigateToLogin();
//   //     _showLogoutConfirmationDialog();
//   //     rethrow; // Ensure the error propagates
//   //   }
//   // }

//   void _navigateToLogin() {
//     if (_isNavigating) return;

//     _isNavigating = true;
//     Logger().i("Navigating to login screen...");

//     // Clear user data and navigate to login
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       g.Get.offAllNamed(AppRoutes.LOGIN);
//     });
//   }

//   Future<http.StreamedResponse> _retryRequest(
//       http.BaseRequest originalRequest) async {
//     final appLogic = g.Get.find<AppLogic>();
//     final newToken = appLogic.state.userResponse.value.accessToken;

//     if (originalRequest is http.Request) {
//       final newRequest =
//           http.Request(originalRequest.method, originalRequest.url);
//       newRequest.headers.addAll(originalRequest.headers);
//       newRequest.headers['Authorization'] =
//           'Bearer $newToken'; // Add refreshed token
//       newRequest.body = originalRequest.body;
//       newRequest.encoding = originalRequest.encoding;
//       return await http.Client().send(newRequest);
//     } else if (originalRequest is http.StreamedRequest) {
//       final newRequest =
//           http.StreamedRequest(originalRequest.method, originalRequest.url);
//       newRequest.headers.addAll(originalRequest.headers);
//       newRequest.headers['Authorization'] =
//           'Bearer $newToken'; // Add refreshed token
//       await originalRequest.finalize().pipe(newRequest.sink);
//       return await http.Client().send(newRequest);
//     } else {
//       throw ArgumentError(
//           'Unsupported request type: ${originalRequest.runtimeType}');
//     }
//   }

//   Future<http.StreamedResponse> _unauthorizedHandler(
//       http.StreamedResponse response) async {
//     return await _refreshLock.synchronized(() async {
//       await refreshToken();
//       return await _retryRequest(response.request!);
//     });
//     // Retry the original request with the new token
//     // await refreshToken();
//     // return (await _retryRequest(response.request!));
//   }

//   void _showLogoutConfirmationDialog() {
//     if (_isDialogShowing) return; // Prevent multiple dialogs

//     _isDialogShowing = true; // Mark dialog as showing
//     g.Get.dialog(
//       barrierDismissible: false,
//       AlertDialog(
//         title: Text(
//           AppLocale.sessionExpired.tr,
//           style: textDisplaySmall(),
//         ),
//         content: Text(
//           AppLocale.sessionExpiredContent.tr,
//           style: textDisplaySmall(fontSize: 12.0.d),
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: Text(AppLocale.ok.tr),
//             onPressed: () async {
//               EasyLoading.show();

//               await 1.delay();
//               g.Get.back(); // Close the dialog
//               _navigateToLogin(); // Navigate after closing
//               EasyLoading.dismiss();
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Simple mutex implementation
// class Lock {
//   Completer? _completer;

//   Future<T> synchronized<T>(Future<T> Function() action) async {
//     while (_completer != null) {
//       await _completer!.future;
//     }

//     final completer = Completer<T>();
//     _completer = completer;

//     try {
//       final result = await action();
//       completer.complete(result);
//       return result;
//     } catch (error, stackTrace) {
//       completer.completeError(error, stackTrace);
//       rethrow;
//     } finally {
//       _completer = null;
//     }
//   }
// }

// // Future<void> refreshToken() async {
//   //   final UserLocal userLocal = UserLocal();
//   //   final appLogic = g.Get.find<AppLogic>();

//   //   try {
//   //     final refreshedTokens = await appLogic.refreshToken();
//   //     if (refreshedTokens?.accessToken != null &&
//   //         refreshedTokens?.refreshToken != null) {
//   //       // Update tokens in local storage
//   //       userLocal.updateTokens(
//   //           accessToken: refreshedTokens?.accessToken ?? "",
//   //           refreshToken: refreshedTokens?.refreshToken ?? "");

//   //       // // Update tokens in AppLogic
//   //       // appLogic.state.userResponse.value.accessToken =
//   //       //     refreshedTokens?.accessToken;
//   //       // appLogic.state.userResponse.value.refreshToken =
//   //       //     refreshedTokens?.refreshToken;
        
//   //       Logger().i("Tokens refreshed successfully.");
//   //     } else {
//   //       Logger().e("Failed to refresh tokens.");
//   //       throw Exception("Failed to refresh tokens.");
//   //     }
//   //   } catch (error) {
//   //     Logger().e("Token refresh failed: $error");
//   //     _navigateToLogin();
//   //   }
//   // }




//   // Future<http.StreamedResponse> _retryRequest(
//   //     http.BaseRequest originalRequest) async {
//   //   if (originalRequest is http.Request) {
//   //     final newRequest =
//   //         http.Request(originalRequest.method, originalRequest.url);
//   //     newRequest.headers.addAll(originalRequest.headers);
//   //     // Add the new access token to the headers
//   //     final appLogic = g.Get.find<AppLogic>();
//   //     newRequest.headers['Authorization'] =
//   //         'Bearer ${appLogic.state.userResponse.value.accessToken}';
//   //     // Copy body and encoding
//   //     newRequest.body = originalRequest.body;
//   //     newRequest.encoding = originalRequest.encoding;
//   //     return await http.Client().send(newRequest);
//   //   } else if (originalRequest is http.StreamedRequest) {
//   //     final newRequest =
//   //         http.StreamedRequest(originalRequest.method, originalRequest.url);
//   //     newRequest.headers.addAll(originalRequest.headers);
//   //     // Add the new access token to the headers
//   //     final appLogic = g.Get.find<AppLogic>();
//   //     newRequest.headers['Authorization'] =
//   //         'Bearer ${appLogic.state.userResponse.value.accessToken}';
//   //     await originalRequest.finalize().pipe(newRequest.sink);
//   //     return await http.Client().send(newRequest);
//   //   } else {
//   //     throw ArgumentError(
//   //         'Unsupported request type: ${originalRequest.runtimeType}');
//   //   }
//   // }




// //   // Define your token refreshing logic here
// //   Future<void> refreshToken() async {
// //   final UserLocal userLocal = UserLocal();
// //   final appLogic = g.Get.find<AppLogic>();

// //   final refreshedTokens = await appLogic.refreshToken();
// //   if (refreshedTokens?.accessToken != null &&
// //       refreshedTokens?.refreshToken != null) {
// //     // Update tokens in local storage
// //     userLocal.updateTokens(
// //         accessToken: refreshedTokens!.accessToken??"",
// //         refreshToken: refreshedTokens.refreshToken??"");

// //     // Update tokens in AppLogic
// //     appLogic.state.userResponse.value.accessToken = refreshedTokens.accessToken;
// //     appLogic.state.userResponse.value.refreshToken = refreshedTokens.refreshToken;

// //     Logger().i("Tokens refreshed successfully.");
// //   } else {
// //     Logger().e("Failed to refresh tokens.");
// //     throw Exception("Failed to refresh tokens.");
// //   }
// // }