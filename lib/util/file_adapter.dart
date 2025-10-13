import 'package:flutter/material.dart';

// 조건부 import
import 'stub_adapter.dart'
    if (dart.library.io) 'mobile_file_adapter.dart'
    if (dart.library.html) 'web_file_adapter.dart';

// ✅ 인터페이스 정의
abstract class IFileAdapter {
  Future<void> pickAndUpload(BuildContext context, String exercise);
  Future<void> openCamera(BuildContext context, String exercise);
}

// ✅ 팩토리 함수 선언 (본문 없이 선언만!)
IFileAdapter createFileAdapter(); // ← 선언은 맞지만, 반드시 함수 선언 위치 주의!

// ✅ 내부 구현 인스턴스
final IFileAdapter _impl = createFileAdapter();

class FileAdapter {
  Future<void> pickAndUpload(BuildContext context, String exercise) =>
      _impl.pickAndUpload(context, exercise);

  Future<void> openCamera(BuildContext context, String exercise) =>
      _impl.openCamera(context, exercise);
}
