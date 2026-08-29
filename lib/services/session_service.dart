import 'package:com.tara.passenger/core/storage/token_store.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/storages/get_storage.dart';
import 'package:get/get.dart';

class SessionService {
  SessionService._(this._tokenStore);

  static SessionService? _instance;
  static SessionService get instance => _instance ??= SessionService._(TokenStore());

  final TokenStore _tokenStore;
  String? _cachedToken;

  /// In-memory first; secure storage second; legacy plaintext blob last —
  /// a one-time migration bridge that moves the token into secure storage
  /// on first use post-upgrade, without touching any auth screen.
  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;

    final stored = await _tokenStore.read();
    if (stored != null) {
      _cachedToken = stored;
      return stored;
    }

    final legacy = await _readLegacyToken();
    if (legacy != null) {
      await saveToken(legacy);
      return legacy;
    }
    return null;
  }

  Future<void> saveToken(String token) async {
    _cachedToken = token;
    await _tokenStore.write(token);
  }

  Future<void> clear() async {
    _cachedToken = null;
    await _tokenStore.clear();
  }

  Future<void> handleUnauthorized() async {
    await clear();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  Future<String?> _readLegacyToken() async {
    final userData = await GetStoragePref().getJsonToken;
    return userData.data?.token;
  }
}
