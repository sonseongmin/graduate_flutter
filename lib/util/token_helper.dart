import 'package:flutter/foundation.dart';
import 'dart:html' as html; // 웹 토큰용
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenHelper {
  static const _storage = FlutterSecureStorage();

  static Future<String?> getToken() async {
    try {
      if (kIsWeb) {
        // ✅ 웹에서는 localStorage 사용
        return html.window.localStorage['access_token'];
      } else {
        // ✅ 모바일에서는 secure storage 사용
        return await _storage.read(key: 'access_token');
      }
    } catch (e) {
      if (kDebugMode) print('토큰 가져오기 오류: $e');
      return null;
    }
  }
}