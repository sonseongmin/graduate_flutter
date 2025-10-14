import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenHelper {
  static const _secureStorage = FlutterSecureStorage();

  /// ✅ 토큰 저장
  static Future<void> saveToken(String token) async {
    if (kIsWeb) {
      // 🌐 웹 환경 → SharedPreferences 사용
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
    } else {
      // 📱 모바일 환경 → SecureStorage 사용
      await _secureStorage.write(key: 'access_token', value: token);
    }
  }

  /// ✅ 토큰 조회
  static Future<String?> getToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('access_token');
    } else {
      return await _secureStorage.read(key: 'access_token');
    }
  }

  /// ✅ 토큰 삭제
  static Future<void> deleteToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
    } else {
      await _secureStorage.delete(key: 'access_token');
    }
  }
}
