import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'token_helper.dart';
import 'file_adapter.dart'; // ✅ 추가해야 IFileAdapter 인식됨

class WebFileAdapter implements IFileAdapter {
  @override
  Future<void> pickAndUpload(BuildContext context, String exercise) async {
    final input = html.FileUploadInputElement()..accept = 'video/*';
    input.click();
    input.onChange.listen((event) async {
      final file = input.files?.first;
      if (file == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ 파일이 선택되지 않았습니다.')),
        );
        return;
      }

      final token = await TokenHelper.getToken();
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ 로그인 토큰이 없습니다. 다시 로그인해주세요.')),
        );
        return;
      }

      final form = html.FormData();
      form.appendBlob('file', file);

      final req = html.HttpRequest();
      req
        ..open('POST', 'http://13.125.219.3/api/v1/exercise/analyze')
        ..setRequestHeader('Authorization', 'Bearer $token')
        ..onLoadEnd.listen((_) {
          if (req.status == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ 업로드 성공')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('❌ 업로드 실패 (${req.status})')),
            );
          }
        });
      req.send(form);
    });
  }

  @override
  Future<void> openCamera(BuildContext context, String exercise) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('웹에서는 카메라 촬영이 지원되지 않습니다.')),
    );
  }
}

IFileAdapter createFileAdapter() => WebFileAdapter();
