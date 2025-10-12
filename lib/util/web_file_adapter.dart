import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'stub_adapter.dart';
import 'file_adapter.dart';

class BaseFileAdapter implements BaseFileAdapter {
  @override
  Future<void> pickAndUpload(BuildContext context, String exercise) async {
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

    final request = html.HttpRequest();
    request
      ..open('POST', 'http://13.125.219.3/api/v1/exercise/analyze')
      ..setRequestHeader('Authorization', 'Bearer $token')
      ..onLoadEnd.listen((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(request.status == 200
                ? '✅ 업로드 성공!'
                : '❌ 실패: ${request.status}'),
          ),
        );
      });
    request.send(formData);
  }

  @override
  Future<void> openCamera(BuildContext context, String exercise) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('웹에서는 카메라 촬영이 지원되지 않습니다.')),
    );
  }
}
