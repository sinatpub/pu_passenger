import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:com.tara.passenger/core/network/api_client.dart';
import 'package:com.tara.passenger/services/session_service.dart';
import 'package:com.tara.passenger/storages/save_storage.dart';

/// A development-only shortcut past OTP verification, so the screens *behind*
/// login can be exercised on an emulator without a real SMS round-trip.
///
/// The passenger counterpart of pu_driver's `DebugAuthBypass`, added so a
/// driver↔passenger trip can be driven end to end on two emulators. It keeps
/// the driver version's three independent gates — **this cannot be switched on
/// in a release build**:
///
/// 1. `kDebugMode` — the constant is `false` in profile/release, so the whole
///    branch is tree-shaken out of a shipped binary.
/// 2. `--dart-define=DEBUG_OTP_BYPASS=true` — off unless a build explicitly
///    asks for it. Deliberately **not** in `dart_defines.example.json`.
/// 3. The typed code matching [bypassCode].
///
/// On a match it performs a **real** password login against `POST /taxi/login`
/// — an endpoint the passenger app does not otherwise use — and persists what
/// it returns. Credentials come from `--dart-define`, never from source;
/// `dart_defines.json` is gitignored, which is where they belong.
///
/// One difference from the driver's version, and the reason this is not a
/// copy: the passenger app resolves its **socket identity** from the legacy
/// auth blob (`AppLogic.initSocket()` reads `getJsonToken` for
/// `data.user.id`), not from [SessionService]. Seeding only the token would
/// authenticate REST calls and leave the socket unconnected — which is exactly
/// the half being tested. So this writes both.
class DebugAuthBypass {
  DebugAuthBypass._();

  static const bypassCode = '0000';

  static const _enabledByDefine =
      bool.fromEnvironment('DEBUG_OTP_BYPASS', defaultValue: false);
  static const _phone = String.fromEnvironment('DEBUG_LOGIN_PHONE');
  static const _password = String.fromEnvironment('DEBUG_LOGIN_PASSWORD');

  static bool get isEnabled => kDebugMode && _enabledByDefine;

  static bool accepts(String otpCode) => isEnabled && otpCode == bypassCode;

  static Map<String, dynamic>? _cachedUser;

  /// The user object from the bypass login, once [seedSession] has run.
  static Map<String, dynamic>? get cachedUser => _cachedUser;

  /// Logs in for real and persists the result. Returns true when a session was
  /// established; false (with a log line saying why) otherwise.
  static Future<bool> seedSession() async {
    if (!isEnabled) return false;
    if (_phone.isEmpty || _password.isEmpty) {
      debugPrint(
        '[DebugAuthBypass] OTP bypassed, but DEBUG_LOGIN_PHONE / '
        'DEBUG_LOGIN_PASSWORD are unset — no session. Add them to '
        'dart_defines.json (gitignored).',
      );
      return false;
    }

    final result = await ApiClient().request<Map<String, dynamic>>(
      path: '/taxi/login',
      method: 'POST',
      requiresToken: false,
      body: {'phone': _phone, 'password': _password},
      decode: (response) => Map<String, dynamic>.from(response.data as Map),
    );

    return await result.when(
      ok: (json) async {
        final data = json['data'] as Map<String, dynamic>?;
        final token = data?['token'] as String?;
        if (token == null || token.isEmpty) {
          debugPrint('[DebugAuthBypass] login returned no token: $json');
          return false;
        }

        await SessionService.instance.saveToken(token);

        // The login response is already `UserResponseModel`-shaped
        // (`{data: {user, token}, status, message}`), so it can be stored
        // verbatim — this is what `initSocket()` and the legacy token bridge
        // in `SessionService` both read.
        SaveStoragePref().saveJsonToken(authModel: jsonEncode(json));

        final user = data?['user'];
        if (user is Map) _cachedUser = Map<String, dynamic>.from(user);
        debugPrint(
          '[DebugAuthBypass] logged in as '
          '${_cachedUser?['name']} (id=${_cachedUser?['id']}, '
          'role_id=${_cachedUser?['role_id']}); token + auth blob cached.',
        );
        return true;
      },
      err: (error) async {
        debugPrint('[DebugAuthBypass] login failed: ${error.message}');
        return false;
      },
    );
  }
}
