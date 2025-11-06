import 'package:flutter/material.dart';
import 'stub_adapter.dart'
    if (dart.library.io) 'mobile_file_adapter.dart'
    if (dart.library.html) 'web_file_adapter.dart';

/// 공통 인터페이스
abstract class IFileAdapter {
  Future<Map<String, dynamic>> pickAndUpload(BuildContext context, String exercise);
  Future<Map<String, dynamic>> openCamera(BuildContext context, String exercise);
}

/// 플랫폼별 구현체 주입
IFileAdapter createFileAdapter() => FileAdapterImpl();

final IFileAdapter _impl = createFileAdapter();

/// 퍼사드 클래스 (외부에서 이걸 사용)
class FileAdapter {
  Future<Map<String, dynamic>> pickAndUpload(BuildContext context, String exercise) =>
      _impl.pickAndUpload(context, exercise);

  Futureap<String, dynamic>>(BuildContext context, String exercise) =>
      _impl.openCamera(context, exercise);
}
