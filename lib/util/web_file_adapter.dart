import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'file_adapter.dart';

class WebFileAdapter {
  Future<void> pickAndUpload(BuildContext context, String exercise) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null) throw Exception('파일 선택 취소됨');

    final fileBytes = result.files.first.bytes;
    final fileName = result.files.first.name;
    if (fileBytes == null) throw Exception('파일을 읽을 수 없음');

    final token = await getAccessToken();

    final req = http.MultipartRequest(
      'POST',
      Uri.parse('http://13.125.219.3/api/v1/exercise/analyze'),
    );

    if (token != null && token.isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $token';
    }

    req.files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode != 202) {
      throw Exception('서버 오류: ${res.statusCode} ${res.body}');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('서버 업로드 완료! 분석이 곧 시작됩니다.')),
    );
  }
}
