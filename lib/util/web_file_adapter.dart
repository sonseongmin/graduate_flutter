import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'token_helper.dart';

class WebFileAdapter {
  Future<void> pickAndUpload(BuildContext context, String exercise) async {
    // ✅ 먼저 업로드 창을 띄운다 (동기적으로)
    final input = html.FileUploadInputElement()..accept = 'video/*';
    input.click();

    // ✅ change 이벤트 리스너 내부에서 토큰 체크 + 업로드
    input.onChange.listen((event) async {
      final file = input.files?.first;
      if (file == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ 파일이 선택되지 않았습니다.')),
        );
        return;
      }

      // ✅ 이제 비동기 호출 (이제는 사용자가 직접 클릭했으니 안전)
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
}
IFileAdapter createFileAdapter() => WebFileAdapter();