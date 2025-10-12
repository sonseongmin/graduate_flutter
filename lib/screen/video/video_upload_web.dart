import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class VideoUploadScreen extends StatelessWidget {
  const VideoUploadScreen({super.key});

  Future<void> _uploadFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null || result.files.single.bytes == null) return;

    final uri = Uri.parse('http://3.39.194.20:3000/api/v1/exercise/analyze');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        result.files.single.bytes!,
        filename: result.files.single.name,
      ));

    final response = await request.send();
    if (response.statusCode == 202) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('분석 요청이 전송되었습니다. (웹 업로드 완료)')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업로드 실패: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF20221E),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => _uploadFile(context),
          icon: const Icon(Icons.upload_file),
          label: const Text('웹에서 영상 업로드'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEAEAEA),
            foregroundColor: Colors.black,
            minimumSize: const Size(220, 60),
          ),
        ),
      ),
    );
  }
}
