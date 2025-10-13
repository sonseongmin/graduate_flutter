import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenHelper {
  static const _storage = FlutterSecureStorage();

  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: 'access_token');
    } catch (e) {
      if (kDebugMode) {
        print('토큰 가져오기 오류: $e');
      }
      return null;
    }
  }
}
