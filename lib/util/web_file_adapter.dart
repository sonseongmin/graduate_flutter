import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'stub_adapter.dart';
import 'token_helper.dart';

IFileAdapter createFileAdapter() => WebFileAdapter();

class WebFileAdapter implements IFileAdapter {
  @override
  Future<void> pickAndUpload(BuildContext context, String exercise) async {
    final token = await TokenHelper.getToken();
    if (token == null) return;

    final input = html.FileUploadInputElement()..accept = 'video/*';
    input.click();
    await input.onChange.first;
    final file = input.files?.first;
    if (file == null) return;

    final form = html.FormData();
    form.appendBlob('file', file);

    final req = html.HttpRequest();
    req
      ..open('POST', 'http://13.125.219.3/api/v1/exercise/analyze')
      ..setRequestHeader('Authorization', 'Bearer $token')
      ..onLoadEnd.listen((_) {
        if (req.status == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ 업로드 성공!')),
          );
        } else if (req.status == 0 && (req.responseText?.isEmpty ?? true)) {
          debugPrint('사용자가 파일 선택을 취소함');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            SnackBar(content: Text('❌ 업로드 실패 (${req.status})')),
          ),
        );
      });
    req.send(form);
  }

  @override
  Future<void> openCamera(BuildContext context, String exercise) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('웹에서는 카메라 촬영이 지원되지 않습니다.')),
    );
  }
}
