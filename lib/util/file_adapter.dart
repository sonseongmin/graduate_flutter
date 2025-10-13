import 'package:flutter/material.dart';

// ✅ 조건부 import: 웹일 때만 web_file_adapter.dart가 포함되도록!
import 'stub_adapter.dart'
    if (dart.library.io) 'mobile_file_adapter.dart'
    if (dart.library.html) 'web_file_adapter.dart';

abstract class IFileAdapter {
  Future<void> pickAndUpload(BuildContext context, String exercise);
  Future<void> openCamera(BuildContext context, String exercise);
}

// 각 플랫폼에서 구현하는 팩토리 함수
IFileAdapter createFileAdapter();

final IFileAdapter _impl = createFileAdapter();

class FileAdapter {
  Future<void> pickAndUpload(BuildContext context, String exercise) =>
      _impl.pickAndUpload(context, exercise);

  Future<void> openCamera(BuildContext context, String exercise) =>
      _impl.openCamera(context, exercise);
}
