import 'package:flutter/foundation.dart' show kIsWeb;
import 'mobile_file_adapter.dart' if (dart.library.html) 'web_file_adapter.dart';
import 'stub_file_adapter.dart';

/// 플랫폼별 파일 선택기 (자동 감지)
class FileAdapter {
  Future<dynamic> pickVideo() async {
    try {
      if (kIsWeb) {
        final webAdapter = WebFileAdapter();
        return await webAdapter.pickVideo();
      } else {
        final mobileAdapter = MobileFileAdapter();
        return await mobileAdapter.pickVideo();
      }
    } catch (e) {
      // 혹시 플랫폼 인식 실패 시 stub로 fallback
      final stub = StubFileAdapter();
      return await stub.pickVideo();
    }
  }
}
