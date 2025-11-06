import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'token_helper.dart';
import 'file_adapter.dart';

class FileAdapterImpl implements IFileAdapter {
  final ImagePicker _picker = ImagePicker();

  // ✅ 공통 서버 URL (필요하면 const로 빼도 됨)
  static const String _baseUrl = 'http://13.125.251.91/api/v1/exercise/analyze';

  // ✅ 파일 업로드 (갤러리)
  @override
  Future<Map<String, dynamic>> pickAndUpload(BuildContext context, String exercise) async {
    final token = await TokenHelper.getToken();

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ 로그인 토큰이 없습니다. 다시 로그인해주세요.')),
      );
      return {'success': false, 'message': 'No token'};
    }

    // 🔸 비디오 선택
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) {
      return {'success': false, 'message': 'No file selected'};
    }

    try {
      final uri = Uri.parse(_baseUrl);
      final req = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      debugPrint('📡 [DEBUG] 업로드 요청 전송중... token=${token.substring(0, 10)}...');

      final res = await req.send();
      final body = await res.stream.bytesToString();

      debugPrint('📩 [DEBUG] 서버 응답 코드: ${res.statusCode}');
      debugPrint('📩 [DEBUG] 서버 응답 본문: $body');

      if (res.statusCode == 200 || res.statusCode == 202) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 업로드 성공')),
        );
        return {
          'success': true,
          'status': res.statusCode,
          'data': _tryParseJson(body),
        };
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

  // ✅ 카메라 촬영 업로드
  @override
  Future<Map<String, dynamic>> openCamera(BuildContext context, String exercise) async {
    final token = await TokenHelper.getToken();

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ 로그인 토큰이 없습니다. 다시 로그인해주세요.')),
      );
      return {'success': false, 'message': 'No token'};
    }

    final file = await _picker.pickVideo(source: ImageSource.camera);
    if (file == null) {
      return {'success': false, 'message': 'No video captured'};
    }

    try {
      final uri = Uri.parse(_baseUrl);
      final req = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      debugPrint('📡 [DEBUG] 카메라 업로드 요청 전송중... token=${token.substring(0, 10)}...');

      final res = await req.send();
      final body = await res.stream.bytesToString();

      debugPrint('📩 [DEBUG] 서버 응답 코드: ${res.statusCode}');
      debugPrint('📩 [DEBUG] 서버 응답 본문: $body');

      if (res.statusCode == 200 || res.statusCode == 202) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 업로드 성공')),
        );
        return {
          'success': true,
          'status': res.statusCode,
          'data': _tryParseJson(body),
        };
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

  // ✅ JSON 파싱 안전하게 처리
  dynamic _tryParseJson(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return raw;
    }
  }
}
