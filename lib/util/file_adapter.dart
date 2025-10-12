import 'package:flutter/material.dart';
import 'stub_adapter.dart'
    if (dart.library.html) 'web_file_adapter.dart'
    if (dart.library.io) 'mobile_file_adapter.dart';
import 'stub_adapter.dart';
class FileAdapter {
  final IFileAdapter _impl = createFileAdapter();

  Future<void> pickAndUpload(BuildContext context, String exercise) async {
    await _impl.pickAndUpload(context, exercise);
  }

  Future<void> openCamera(BuildContext context, String exercise) async {
    await _impl.openCamera(context, exercise);
  }
}
