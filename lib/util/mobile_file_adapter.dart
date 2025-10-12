import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'token_helper.dart';
import 'file_adapter_stub.dart';

IFileAdapter createFileAdapter() => MobileFileAdapter();

class MobileFileAdapter implements IFileAdapter {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<void> pickAndUpload(BuildContext context, String exercise) async {
    final token = await TokenHelper.getToken();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ 로그인 토큰이 없습니다. 다시 로그인해주세요.')),
      );
      return;
    }

    final XFile? pickedFile = await _picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ 파일이 선택되지 않았습니다.')),
      );
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://13.125.219.3/api/v1/exercise/analyze'),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', pickedFile.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 업로드 성공')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 업로드 실패 (${response.statusCode})')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ 업로드 중 오류 발생: $e')),
      );
    }
  }

  @override
  Future<void> openCamera(BuildContext context, String exercise) async {
    final token = await TokenHelper.getToken();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ 로그인 토큰이 없습니다. 다시 로그인해주세요.')),
      );
      return;
    }

    final XFile? recordedFile = await _picker.pickVideo(source: ImageSource.camera);

    if (recordedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ 촬영된 영상이 없습니다.')),
      );
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://13.125.219.3/api/v1/exercise/analyze'),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', recordedFile.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 업로드 성공')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 업로드 실패 (${response.statusCode})')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ 업로드 중 오류 발생: $e')),
      );
    }
  }
}
