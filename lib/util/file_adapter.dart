import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'file_adapter_stub.dart';

// 조건부 import: Web / Mobile / Stub
import 'web_file_adapter.dart'
  if (dart.library.io) 'mobile_file_adapter.dart'
  if (dart.library.html) 'web_file_adapter.dart'
  if (dart.library.js) 'web_file_adapter.dart'
  if (dart.library.io) 'mobile_file_adapter.dart'
  if (dart.library.io) 'mobile_file_adapter.dart'
  if (dart.library.html) 'web_file_adapter.dart';
import 'stub_adapter.dart' if (dart.library.io) 'mobile_file_adapter.dart';

final IFileAdapter _impl = createFileAdapter();

class FileAdapter {
  static Future<void> pickAndUpload(BuildContext context, String exercise) =>
      _impl.pickAndUpload(context, exercise);

  static Future<void> openCamera(BuildContext context, String exercise) =>
      _impl.openCamera(context, exercise);
}
