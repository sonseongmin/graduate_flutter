// lib/util/file_adapter.dart
import 'package:flutter/material.dart';
import 'stub_adapter.dart'
    if (dart.library.io) 'mobile_file_adapter.dart'
    if (dart.library.html) 'web_file_adapter.dart';

/// 공통 인터페이스
abstract class IFileAdapter {
  Future<void> pickAndUpload(BuildContext context, String exercise);
  Future<void> openCamera(BuildContext context, String exercise);
}

/// 플랫폼별 구현 팩토리 선언 (클래스 밖 전역)
IFileAdapter createFileAdapter(); // ✅ 여기 세미콜론으로 끝내야 함

final IFileAdapter _adapter = createFileAdapter();

/// FileAdapter 진입점
class FileAdapter {
  Future<void> pickAndUpload(BuildContext context, String exercise) async {
    await _adapter.pickAndUpload(context, exercise);
  }

  Future<void> openCamera(BuildContext context, String exercise) async {
    await _adapter.openCamera(context, exercise);
  }
}
