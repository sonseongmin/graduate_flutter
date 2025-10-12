// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class WebFileAdapter {
  Future<html.File?> pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null || result.files.isEmpty) return null;

    final fileBytes = result.files.first.bytes;
    final fileName = result.files.first.name;
    if (fileBytes == null) return null;

    final blob = html.Blob([Uint8List.fromList(fileBytes)]);
    final file = html.File([blob], fileName, {'type': 'video/mp4'});

    print('[WEB] Selected file: $fileName (${fileBytes.lengthInBytes} bytes)');
    return file;
  }
}
