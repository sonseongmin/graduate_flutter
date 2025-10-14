import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'token_helper.dart';
import 'file_adapter.dart';

class FileAdapterImpl implements IFileAdapter {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<void> pickAndUpload(BuildContext context, String exercise) async {
    final token = await TokenHelper.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ 로그인 토큰이 없습니다. 다시 로그인해주세요.')),
      );
      return;
    }

    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;

    final uri = Uri.parse('http://13.125.208.240/api/v1/exercise/analyze');
    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final res = await req.send();

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 업로드 성공')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 업로드 실패 (${res.statusCode})')),
      );
    }
  }

  @override
  Future<void> openCamera(BuildContext context, String exercise) async {
    final token = await TokenHelper.getToken();
    final file = await _picker.pickVideo(source: ImageSource.camera);
    if (file == null) return;

    final uri = Uri.parse('http://13.125.208.240/api/v1/exercise/analyze');
    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    await req.send();
  }
}
