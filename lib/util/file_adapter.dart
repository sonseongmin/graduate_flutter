import 'package:flutter/material.dart';

// ✅ 조건부 import (환경별)
import 'stub_adapter.dart'
    if (dart.library.io) 'mobile_file_adapter.dart'
    if (dart.library.html) 'web_file_adapter.dart';

// ✅ 인터페이스 정의
abstract class IFileAdapter {
  Future<void> pickAndUpload(BuildContext context, String exercise);
  Future<void> openCamera(BuildContext context, String exercise);
}

// ✅ 플랫폼별 구현 선택 (세미콜론만, 절대 바디 넣지 말 것!)
IFileAdapter createFileAdapter();

// ✅ 실제 인스턴스 생성
final IFileAdapter _impl = createFileAdapter();

class FileAdapter {
  Future<void> pickAndUpload(BuildContext context, String exercise) =>
      _impl.pickAndUpload(context, exercise);

  Future<void> openCamera(BuildContext context, String exercise) =>
      _impl.openCamera(context, exercise);

  // static 버전도 병행 가능 (필요 시)
  static Future<void> pick(BuildContext context, String exercise) =>
      _impl.pickAndUpload(context, exercise);

  static Future<void> camera(BuildContext context, String exercise) =>
      _impl.openCamera(context, exercise);
}
