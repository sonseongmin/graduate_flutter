import 'package:flutter/material.dart';

// ✅ 플랫폼별 adapter를 조건부 import
import 'stub_adapter.dart'
    if (dart.library.io) 'mobile_file_adapter.dart'
    if (dart.library.html) 'web_file_adapter.dart';

// ✅ 인터페이스 정의
abstract class IFileAdapter {
  Future<void> pickAndUpload(BuildContext context, String exercise);
  Future<void> openCamera(BuildContext context, String exercise);
}

// ✅ 각 플랫폼에서 이 함수를 구현함
IFileAdapter createFileAdapter(); // ⚠️ 세미콜론 끝, 바디 없음 (정상)

// ✅ 내부 인스턴스
final IFileAdapter _impl = createFileAdapter();

class FileAdapter {
  Future<void> pickAndUpload(BuildContext context, String exercise) =>
      _impl.pickAndUpload(context, exercise);

  Future<void> openCamera(BuildContext context, String exercise) =>
      _impl.openCamera(context, exercise);
}
