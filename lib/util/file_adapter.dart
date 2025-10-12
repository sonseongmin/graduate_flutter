import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

// ✅ 조건부 import 사용 (웹 / 모바일 / 스텁 자동 분기)
import 'file_adapter_stub.dart'
    if (dart.library.html) 'web_file_adapter.dart'
    if (dart.library.io) 'mobile_file_adapter.dart';

// ✅ getAccessToken 통합
Future<String?> getAccessToken() async {
  try {
    if (kIsWeb) {
      // 웹 로컬 스토리지
      // ignore: avoid_web_libraries_in_flutter
      import 'dart:html' as html;
      return html.window.localStorage['access_token'];
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('access_token');
    }
  } catch (e) {
    debugPrint('Token fetch error: $e');
    return null;
  }
}

class FileAdapter {
  final BaseFileAdapter _adapter = BaseFileAdapter();

  Future<void> pickAndUpload(BuildContext context, String exercise) async {
    await _adapter.pickAndUpload(context, exercise);
  }

  Future<void> openCamera(BuildContext context, String exercise) async {
    await _adapter.openCamera(context, exercise);
  }
}
