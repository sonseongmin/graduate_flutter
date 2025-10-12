import 'dart:typed_data';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

class FileAdapter {
  Future<void> pickAndUpload(context, String exercise) async {
    final uploadInput = html.FileUploadInputElement()..accept = 'video/*';
    uploadInput.click();
    await uploadInput.onChange.first;
    final file = uploadInput.files?.first;
    if (file == null) return;

    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    final bytes = reader.result as Uint8List;

    final uri = Uri.parse('http://13.125.219.3/api/v1/exercise/analyze');
    final req = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: file.name));
    await req.send();
  }
}
