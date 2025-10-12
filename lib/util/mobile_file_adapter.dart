import 'dart:io';
import 'package:file_picker/file_picker.dart';

class MobileFileAdapter {
  Future<File?> pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null || result.files.isEmpty) return null;

    final path = result.files.first.path;
    if (path == null) return null;

    print('[MOBILE] Selected file: $path');
    return File(path);
  }
}
