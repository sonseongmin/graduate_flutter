import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'token_helper.dart';
import 'file_adapter.dart';

class FileAdapterImpl implements IFileAdapter {
  final ImagePicker _picker = ImagePicker();

  // ✅ 파일 업로드 함수
  @override
  Future<Map<String, dynamic>> pickAndUpload(BuildContext context, String exercise) async {
    final token = await TokenHelper.getToken();

    // 🔸 로그인 토큰 확인
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ 로그인 토큰이 없습니다. 다시 로그인해주세요.')),
      );
      return {'success': false, 'message': 'No token'};
    }

    // 🔸 갤러리에서 비디오 선택
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) {
      return {'success': false, 'message': 'No file selected'};
    }

    final uri = Uri.parse('http://13.125.251.91/api/v1/exercise/analyze');
    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final res = await req.send();
      final body = await res.stream.bytesToString();

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 업로드 성공')),
        );

        // 🔸 서버 응답을 JSON으로 파싱해 반환
        try {
          return {
            'success': true,
            'status': 200,
            'data': jsonDecode(body),
          };
        } catch (_) {
          // JSON 파싱 실패 시 raw 응답 반환
          return {
            'success': true,
            'status': 200,
            'response': body,
          };
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 업로드 실패 (${res.statusCode})')),
        );
        return {'success': false, 'status': res.statusCode, 'response': body};
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ 업로드 중 오류 발생: $e')),
      );
      return {'success': false, 'error': e.toString()};
    }
  }

  // ✅ 카메라 업로드 함수
  @override
  Future<Map<String, dynamic>> openCamera(BuildContext context, String exercise) async {
    final token = await TokenHelper.getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ 로그인 토큰이 없습니다. 다시 로그인해주세요.')),
      );
      return {'success': false, 'message': 'No token'};
    }

    // 🔸 카메라로 비디오 촬영
    final file = await _picker.pickVideo(source: ImageSource.camera);
    if (file == null) {
      return {'success': false, 'message': 'No video captured'};
    }

    final uri = Uri.parse('http://13.125.251.91/api/v1/exercise/analyze');
    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final res = await req.send();
      final body = await res.stream.bytesToString();

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 업로드 성공')),
        );
        return {'success': true, 'status': 200, 'response': body};
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 업로드 실패 (${res.statusCode})')),
        );
        return {'success': false, 'status': res.statusCode, 'response': body};
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ 업로드 중 오류 발생: $e')),
      );
      return {'success': false, 'error': e.toString()};
    }
  }
}
