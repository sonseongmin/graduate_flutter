import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenHelper {
  static const _storage = FlutterSecureStorage();
  static String? _cachedToken; // ✅ 메모리 캐시

  /// ✅ 토큰 읽기 (캐시 우선)
  static Future<String?> getToken() async {
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      return _cachedToken;
    }
    final token = await _storage.read(key: 'access_token');
    _cachedToken = token;
    return token;
  }

  /// ✅ 토큰 저장 (캐시 즉시 반영)
  static Future<void> saveToken(String token) async {
    _cachedToken = token;
    await _storage.write(key: 'access_token', value: token);
  }

  /// ✅ 토큰 삭제
  static Future<void> deleteToken() async {
    _cachedToken = null;
    await _storage.delete(key: 'access_token');
  }

  /// ✅ 유효성 확인
  static Future<bool> hasValidToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
