import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'file_adapter_stub.dart';
import 'file_adapter.dart';

class BaseFileAdapter implements BaseFileAdapter {
  @override
  Future<void> pickAndUpload(BuildContext context, String exercise) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;

    final token = await getAccessToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://13.125.219.3/api/v1/exercise/analyze'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.statusCode == 200
            ? '✅ 업로드 성공!'
            : '❌ 실패: ${response.statusCode}'),
      ),
    );
  }

  @override
  Future<void> openCamera(BuildContext context, String exercise) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickVideo(source: ImageSource.camera);
    if (file == null) return;

    final token = await getAccessToken();
    if (token == null) return;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://13.125.219.3/api/v1/exercise/analyze'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    await request.send();
  }
}
