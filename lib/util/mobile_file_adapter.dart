import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'stub_adapter.dart';
import 'token_helper.dart';

IFileAdapter createFileAdapter() => MobileFileAdapter();

class MobileFileAdapter implements IFileAdapter {
  @override
  Future<void> pickAndUpload(BuildContext context, String exercise) async {
    final picker = ImagePicker();
    final file = await picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;

    final token = await TokenHelper.getToken();
    if (token == null) return;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://13.125.219.3/api/v1/exercise/analyze'),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final res = await request.send();
    if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ 업로드 성공')),
            );
        } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('❌ 실패 (코드: ${res.statusCode})')),
        );
    }

  @override
  Future<void> openCamera(BuildContext context, String exercise) async {
    final picker = ImagePicker();
    final file = await picker.pickVideo(source: ImageSource.camera);
    if (file == null) return;
    await pickAndUpload(context, exercise);
  }
}