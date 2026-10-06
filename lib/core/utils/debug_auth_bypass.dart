import 'dart:convert';
import 'dart:io' show Platform;

import 'package:com.tara.passenger/core/config/app_config.dart';
import 'package:com.tara.passenger/core/network/result.dart';
import 'package:com.tara.passenger/data/models/user_response_model.dart';
import 'package:com.tara.passenger/services/session_service.dart';
import 'package:com.tara.passenger/storages/get_storage.dart';
import 'package:com.tara.passenger/storages/save_storage.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

/// The password login the bypass signs in with: `AuthRepository.passwordLogin`.
/// Passed in rather than imported, so this file does not reach up into a
/// screen's data layer.
typedef DebugPasswordLogin = Future<Result<UserResponseModel>> Function({
  required String phone,
  required String password,
  required String deviceToken,
  required String platform,
});

/// Keeps a signed-in session. Replaced in tests, which have no storage.
typedef DebugSessionSaver = Future<void> Function(
  String token,
  UserResponseModel model,
);

/// A development-only shortcut past the phone and OTP steps, so the screens
/// *behind* login can be exercised on an emulator without a real SMS
/// round-trip.
///
/// The passenger counterpart of pu_driver's `DebugAuthBypass`.
/// **This cannot be switched on in a release build.** It requires both:
///
/// 1. `kDebugMode` — the constant is `false` in profile/release, so the whole
///    branch is tree-shaken out of a shipped binary.
/// 2. `--dart-define=DEBUG_OTP_BYPASS=true` — off unless a build explicitly
///    asks for it. Deliberately **not** in `dart_defines.example.json`.
///
/// It has two doors: the login page's button ([loginLabel]), and typing
/// [bypassCode] on the OTP screen.
///
/// Either one performs a **real** password login against
/// `POST /taxi-passenger/login` — an endpoint the passenger app does not
/// otherwise use — and keeps the result the way a verified OTP is kept.
/// Credentials come from `--dart-define`, never from source;
/// `dart_defines.json` is gitignored, which is where they belong.
///
/// One difference from the driver's version: the passenger app resolves its
/// **socket identity** from the legacy auth blob (`AppLogic.initSocket()`
/// reads `getJsonToken` for `data.user.id`), not from [SessionService].
/// Seeding only the token would authenticate REST calls and leave the socket
/// unconnected. So this writes both.
class DebugAuthBypass {
  DebugAuthBypass._();

  static const bypassCode = '0000';

  static const _enabledByDefine = AppConfig.debugOtpBypass;
  static const _phone = AppConfig.debugLoginPhone;
  static const _password = AppConfig.debugLoginPassword;

  /// Sent as `device_token` when the phone has no FCM token yet. The app
  /// registers the real one after sign-in, through `push-device-token`.
  static const noDeviceToken = 'debug-login';

  static bool get isEnabled => kDebugMode && _enabledByDefine;

  static bool accepts(String otpCode) => isEnabled && otpCode == bypassCode;

  /// The login page's debug button. Kept here, not in the translation files:
  /// it is developer tooling and no passenger ever sees it.
  static const loginLabel = 'Debug login';

  /// Which account the button signs in as, so nobody has to open
  /// `dart_defines.json` to find out.
  static String get loginCaption => _phone.isEmpty
      ? 'Debug build only. DEBUG_LOGIN_PHONE is not set.'
      : 'Debug build only. Signs in as $_phone.';

  /// Why the last [seedSession] failed, for the screen that asked; the log
  /// has the same text. Null after a success.
  static String? lastError;

  /// Signs in for real through [login] and keeps the user and the token as a
  /// verified OTP does. Returns true when a session was obtained; false (with
  /// [lastError] and a log line saying why) otherwise.
  static Future<bool> seedSession(DebugPasswordLogin login) async {
    if (!isEnabled) return false;

    final String? fcmToken = await GetStoragePref().getFcmTokenLocal();
    lastError = await debugPasswordSignIn(
      phone: _phone,
      password: _password,
      deviceToken: fcmToken,
      platform: Platform.isAndroid ? 'android' : 'ios',
      login: login,
      save: _saveSession,
    );
    return lastError == null;
  }

  static Future<void> _saveSession(
    String token,
    UserResponseModel model,
  ) async {
    await SessionService.instance.saveToken(token);
    // The same blob the OTP screen stores: `initSocket()` and the legacy
    // token bridge in `SessionService` both read it.
    SaveStoragePref().saveJsonToken(authModel: jsonEncode(model));
  }
}

/// The sign-in behind [DebugAuthBypass.seedSession], without the build gate:
/// that gate is a compile-time constant no test can switch on, and this part
/// is the one worth testing.
///
/// Returns null when [save] was given a session, otherwise the reason.
Future<String?> debugPasswordSignIn({
  required String phone,
  required String password,
  required String? deviceToken,
  required String platform,
  required DebugPasswordLogin login,
  required DebugSessionSaver save,
}) async {
  if (phone.isEmpty || password.isEmpty) {
    return _noSession('DEBUG_LOGIN_PHONE / DEBUG_LOGIN_PASSWORD are unset. '
        'Add them to dart_defines.json (gitignored).');
  }

  final result = await login(
    phone: phone,
    password: password,
    deviceToken: deviceToken == null || deviceToken.isEmpty
        ? DebugAuthBypass.noDeviceToken
        : deviceToken,
    platform: platform,
  );

  return result.when(
    ok: (UserResponseModel model) async {
      final String? token = model.data?.token;
      final User? user = model.data?.user;
      // A session is a user and a token together: the token signs the REST
      // calls, the user id opens the socket.
      if (token == null || token.isEmpty || user?.id == null) {
        return _noSession(model.message ?? 'Login returned no user session.');
      }
      await save(token, model);
      debugPrint(
        '[DebugAuthBypass] signed in as ${user?.name} (id=${user?.id}, '
        'role_id=${user?.roleId}).',
      );
      return null;
    },
    err: (error) async => _noSession(error.message),
  );
}

String _noSession(String reason) {
  debugPrint('[DebugAuthBypass] no session: $reason');
  return reason;
}
