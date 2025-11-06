import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'token_helper.dart';
import 'file_adapter.dart';

class FileAdapterImpl implements IFileAdapter {
  final ImagePicker _picker = ImagePicker();

  // ✅ 공통 서버 URL (EC2 IP 유지)
  static const String _baseUrl = 'http://13.125.251.91/api/v1/exercise/analyze';

  // ============================================================
  // 🔹 갤러리에서 영상 선택 후 업로드
  // ============================================================
  @override
  Future<Map<String, dynamic>> pickAndUpload(BuildContext context, String exercise) async {
    try {
      final token = await TokenHelper.getToken();

      if (token == null || token.isEmpty) {
        _showSnack(context, '⚠️ 로그인 토큰이 없습니다. 다시 로그인해주세요.');
        return {'success': false, 'message': 'No token'};
      }

      final file = await _picker.pickVideo(source: ImageSource.gallery);
      if (file == null) {
        return {'success': false, 'message': 'No file selected'};
      }

      final uri = Uri.parse(_baseUrl);
      final req = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      debugPrint('📡 [DEBUG] 업로드 시작 - ${file.name}');
      final res = await req.send();
      final body = await res.stream.bytesToString();

      debugPrint('📩 [DEBUG] 응답코드: ${res.statusCode}');
      debugPrint('📩 [DEBUG] 응답내용: $body');

      if (res.statusCode == 200 || res.statusCode == 202) {
        final data = _tryParseJson(body);
        _showSnack(context, '✅ 업로드 성공');
        return {
          'success': true,
          'status': res.statusCode,
          'data': data,
        };
      } else {
        _showSnack(context, '❌ 업로드 실패 (${res.statusCode})');
        return {'success': false, 'status': res.statusCode, 'response': body};
      }
    } catch (e, st) {
      debugPrint('❌ [ERROR] pickAndUpload: $e\n$st');
      _showSnack(context, '⚠️ 업로드 중 오류 발생: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ============================================================
  // 🔹 카메라로 촬영 후 업로드
  // ============================================================
  @override
  Future<Map<String, dynamic>> openCamera(BuildContext context, String exercise) async {
    try {
      final token = await TokenHelper.getToken();

      if (token == null || token.isEmpty) {
        _showSnack(context, '⚠️ 로그인 토큰이 없습니다. 다시 로그인해주세요.');
        return {'success': false, 'message': 'No token'};
      }

      final file = await _picker.pickVideo(source: ImageSource.camera);
      if (file == null) {
        return {'success': false, 'message': 'No video captured'};
      }

      final uri = Uri.parse(_baseUrl);
      final req = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      debugPrint('📡 [DEBUG] 카메라 업로드 시작 - ${file.name}');
      final res = await req.send();
      final body = await res.stream.bytesToString();

      debugPrint('📩 [DEBUG] 응답코드: ${res.statusCode}');
      debugPrint('📩 [DEBUG] 응답내용: $body');

      if (res.statusCode == 200 || res.statusCode == 202) {
        final data = _tryParseJson(body);
        _showSnack(context, '✅ 업로드 성공');
        return {
          'success': true,
          'status': res.statusCode,
          'data': data,
        };
      } else {
        _showSnack(context, '❌ 업로드 실패 (${res.statusCode})');
        return {'success': false, 'status': res.statusCode, 'response': body};
      }
    } catch (e, st) {
      debugPrint('❌ [ERROR] openCamera: $e\n$st');
      _showSnack(context, '⚠️ 업로드 중 오류 발생: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ============================================================
  // 🔹 JSON 파싱 (안전하게)
  // ============================================================
  dynamic _tryParseJson(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return {'raw': raw};
    }
  }

  // ============================================================
  // 🔹 스낵바 헬퍼
  // ============================================================
  void _showSnack(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
