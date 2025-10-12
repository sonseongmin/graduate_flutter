import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;

class TokenHelper {
  // 저장
  static Future<void> saveToken(String accessToken, String userName) async {
    if (kIsWeb) {
      html.window.localStorage['access_token'] = accessToken;
      html.window.localStorage['user_name'] = userName;
    } else {
      final prefs = await SharedPreferences.getInstance();
        await TokenHelper.saveToken(accessToken, userName);
    }
  }

  // 가져오기
  static Future<String?> getToken() async {
    if (kIsWeb) {
      return html.window.localStorage['access_token'];
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('access_token');
    }
  }

  // 삭제
  static Future<void> clearToken() async {
    if (kIsWeb) {
      html.window.localStorage.remove('access_token');
      html.window.localStorage.remove('user_name');
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('user_name');
    }
  }
}
