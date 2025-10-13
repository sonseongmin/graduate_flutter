import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class TokenHelper {
  static Future<String?> getToken() async {
    if (kIsWeb) {
      try {
        final value = _getTokenFromWeb();
        return value.isEmpty ? null : value;
      } catch (_) {
        return null;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static String _getTokenFromWeb() {
    // ⚠️ null은 const 문맥에서 허용 안됨 → 빈 문자열로 대체
    return const String.fromEnvironment('ACCESS_TOKEN', defaultValue: '');
  }
}