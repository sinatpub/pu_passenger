import 'package:com.tara.passenger/core/storage/token_store.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/storages/get_storage.dart';
import 'package:com.tara.passenger/storages/remove_storage.dart';
import 'package:com.tara.passenger/storages/save_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// The signed-in session: the token every request carries, and the sign-in
/// record it came with.
///
/// A session is kept in two places, and this class is the only thing that
/// writes either:
///
///  * the **sign-in record** — the sign-in response as JSON, in
///    `SharedPreferences`. It names the user, which is what the socket
///    registers with (`AppLogic.initSocket`), and it holds the token;
///  * the **token** on its own, in secure storage and in memory, so a request
///    does not decode that record each time.
///
/// They used to be written by different code and so drifted apart:
///
///  * signing in by OTP or by registering wrote the record only. A token
///    already in secure storage was read first and won, so the new sign-in
///    was never used;
///  * logging out removed the record only. The token stayed, and the next
///    launch opened Home as the account that had just logged out;
///  * a refused token (401) cleared the token only. The next request read the
///    same dead token back out of the record and stored it again.
///
/// Together: one dead token — for instance the mock build's, which shares
/// these stores — sent every launch to the login page, and no sign-in could
/// replace it.
class SessionService {
  SessionService._(this._tokenStore);

  /// A fresh, uncached instance over the test's own stores.
  @visibleForTesting
  SessionService.forTesting({TokenStore? tokenStore})
      : _tokenStore = tokenStore ?? TokenStore();

  static SessionService? _instance;
  static SessionService get instance =>
      _instance ??= SessionService._(TokenStore());

  final TokenStore _tokenStore;
  String? _cachedToken;

  /// Called when a session ends — a logout or a refused token — so whatever
  /// was opened for that user can be closed. `AppLogic` disconnects the
  /// socket here: left open, it stays registered as the previous user.
  VoidCallback? onSessionEnded;

  /// The token for requests, or null when nobody is signed in.
  ///
  /// The first read after a start, a sign-in or a sign-out settles the two
  /// stores against each other, with the sign-in record deciding: it is what
  /// the last sign-in wrote, and without it the app has no user to register
  /// on the socket. So a record with a different token replaces the stored
  /// one, and a missing record means signed out, whatever secure storage
  /// still holds. That also repairs an install left in one of the states
  /// described on the class.
  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;

    final stored = await _tokenStore.read();
    final String? recorded;
    try {
      recorded = await _readRecordedToken();
    } catch (_) {
      // A record that cannot be read is not proof of a sign-out. The stored
      // token is kept, as it was before the stores were reconciled.
      _cachedToken = stored;
      return stored;
    }

    if (recorded == null || recorded.isEmpty) {
      if (stored != null) await _tokenStore.clear();
      return null;
    }
    if (stored != recorded) await _tokenStore.write(recorded);
    _cachedToken = recorded;
    return recorded;
  }

  /// Keeps what a sign-in returned: [signInRecord] is the response as JSON,
  /// [token] the token inside it. Every way of signing in ends here, so the
  /// record and the token cannot disagree.
  Future<void> startSession({
    required String? token,
    required String signInRecord,
  }) async {
    await SaveStoragePref().saveJsonToken(authModel: signInRecord);
    if (token == null || token.isEmpty) {
      _cachedToken = null;
      await _tokenStore.clear();
    } else {
      await saveToken(token);
    }
  }

  Future<void> saveToken(String token) async {
    _cachedToken = token;
    await _tokenStore.write(token);
  }

  /// Ends the session: the token and the sign-in record both go.
  Future<void> clear() async {
    _cachedToken = null;
    await _tokenStore.clear();
    await RemoveStoragePref().removeToken();
    onSessionEnded?.call();
  }

  Future<void> handleUnauthorized() async {
    await clear();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  Future<String?> _readRecordedToken() async {
    final userData = await GetStoragePref().getJsonToken;
    return userData.data?.token;
  }
}
