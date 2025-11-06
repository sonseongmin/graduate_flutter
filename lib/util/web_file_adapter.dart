import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'dart:async';
import 'token_helper.dart';
import 'file_adapter.dart';

class FileAdapterImpl implements IFileAdapter {
  @override
  Future<Map<String, dynamic>> pickAndUpload(BuildContext context, String exercise) async {
    final token = await TokenHelper.getToken();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ 로그인 토큰이 없습니다. 다시 로그인해주세요.')),
      );
      throw Exception("토큰 없음");
    }

    // ✅ 파일 업로드 창 생성
    final input = html.FileUploadInputElement()..accept = 'video/*';
    input.click();

    await input.onChange.first;
    final file = input.files?.first;
    if (file == null) throw Exception("파일이 선택되지 않았습니다.");

    final form = html.FormData();
    form.appendBlob('file', file, file.name);

    final completer = Completer<Map<String, dynamic>>();
    final req = html.HttpRequest();

    req
      ..open('POST', 'http://13.125.251.91/api/v1/exercise/analyze')
      ..setRequestHeader('Authorization', 'Bearer $token')
      ..onLoadEnd.listen((_) {
        try {
          if (req.status == 200 || req.status == 202) {
            final decoded = jsonDecode(req.responseText ?? '{}');
            print("[DEBUG] ✅ 서버 응답 수신 (웹): $decoded");
            completer.complete(decoded);
          } else {
            completer.completeError("업로드 실패 (${req.status})");
          }
        } catch (e) {
          completer.completeError("응답 파싱 실패: $e");
        }
      });

    req.send(form);
    return completer.future;
  }

  @override
  Future<Map<String, dynamic>> openCamera(BuildContext context, String exercise) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📷 웹에서는 카메라 촬영이 지원되지 않습니다.')),
    );

    return {
      'status': 'error',
      'message': 'Camera not supported on web.'
    };
  }
}
