// lib/util/file_adapter.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'web_file_adapter.dart';
import 'mobile_file_adapter.dart';
import 'stub_adapter.dart';

// ✅ 웹 전용 import (조건부 import)
import 'dart:html' as html
    if (dart.library.io) 'dart:io' show Platform;

// ✅ 토큰 불러오기 (웹/모바일 대응)
Future<String?> getAccessToken() async {
  try {
    if (kIsWeb) {
      return html.window.localStorage['access_token'];
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('access_token');
    }
  } catch (e) {
    print('Token fetch error: $e');
    return null;
  }
}

class FileAdapter {
  Future<void> pickAndUpload(BuildContext context, String exercise) async {
    if (kIsWeb) {
      return WebFileAdapter().pickAndUpload(context, exercise);
    } else {
      return MobileFileAdapter().pickAndUpload(context, exercise);
    }
  }

  // 🎥 카메라 열기 (웹은 안내 메시지, 모바일만 실행)
  Future<void> openCamera(BuildContext context, String exercise) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('웹에서는 카메라 촬영이 지원되지 않습니다.')),
      );
      return;
    } else {
      return MobileFileAdapter().recordAndUpload(context, exercise);
    }
  }
}
