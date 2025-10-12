import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class FileAdapter {
  Future<void> pickAndUpload(context, String exercise) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final uri = Uri.parse('http://10.0.2.2/api/v1/exercise/analyze');
    final req = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));
    await req.send();
  }
}
