import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'file_adapter.dart';

class WebFileAdapter {
  Future<void> pickAndUpload(BuildContext context, String exercise) async {
    // ✅ 토큰 불러오기
    final token = await getAccessToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final input = html.FileUploadInputElement()..accept = 'video/*';
    input.click();

    await input.onChange.first;
    final file = input.files?.first;
    if (file == null) return;

    final formData = html.FormData();
    formData.appendBlob('file', file);
    formData.append('exercise', exercise);

    final request = html.HttpRequest();
    request
      ..open('POST', 'http://13.125.219.3/api/v1/exercise/analyze')
      ..setRequestHeader('Authorization', 'Bearer $token') // ✅ 핵심!
      ..onLoadEnd.listen((event) {
        if (request.status == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ 업로드 성공! 분석 중입니다.')),
          );
        } else if (request.status == 403) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ 인증 실패: 로그인 정보가 만료되었습니다.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ 업로드 실패 (${request.status})')),
          );
        }
      });

    request.send(formData);
  }
}
