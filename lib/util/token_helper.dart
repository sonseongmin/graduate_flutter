import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class TokenHelper {
  static Future<String?> getToken() async {
    if (kIsWeb) {
      // ✅ wasm 빌드 호환용: html import 대신 JS interop 사용
      try {
        final value = _getTokenFromWeb();
        return value;
      } catch (_) {
        return null;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // ✅ JS interop을 사용해 localStorage 접근
  static String? _getTokenFromWeb() {
    // ignore: undefined_prefixed_name
    return const String.fromEnvironment('ACCESS_TOKEN', defaultValue: null);
  }
}
