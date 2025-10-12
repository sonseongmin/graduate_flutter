import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'file_adapter.dart';
import 'package:camera/camera.dart';

class MobileFileAdapter {
  Future<void> pickAndUpload(BuildContext context, String exercise) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null) throw Exception('파일 선택 취소됨');

    final path = result.files.first.path;
    if (path == null) throw Exception('파일 경로 없음');

    final file = File(path);
    final token = await getAccessToken();

    final req = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2/api/v1/exercise/analyze'),
    );

    if (token != null && token.isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $token';
    }

    req.files.add(await http.MultipartFile.fromPath('file', file.path));
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode != 202) {
      throw Exception('서버 오류: ${res.statusCode} ${res.body}');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('업로드 완료! 분석 대기 중...')),
    );
  }

  // 📸 카메라 녹화용
  Future<void> recordAndUpload(BuildContext context, String exercise) async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    final controller = CameraController(backCamera, ResolutionPreset.medium);
    await controller.initialize();

    final video = await controller.startVideoRecording();
    await Future.delayed(const Duration(seconds: 5)); // 5초만 테스트 촬영
    await controller.stopVideoRecording();

    controller.dispose();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('촬영 완료! (아직 서버 업로드 미구현)')),
    );
  }
}
