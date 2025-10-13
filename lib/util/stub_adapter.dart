import 'package:flutter/material.dart';
import 'file_adapter.dart'; // ✅ 이걸 꼭 넣어야 IFileAdapter 인식됨

class StubFileAdapter implements IFileAdapter {
  @override
  Future<void> pickAndUpload(BuildContext context, String exercise) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('이 환경에서는 업로드를 지원하지 않습니다.')),
    );
  }

  @override
  Future<void> openCamera(BuildContext context, String exercise) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('이 환경에서는 카메라를 지원하지 않습니다.')),
    );
  }
}

// ✅ 팩토리 함수 구현
IFileAdapter createFileAdapter() => StubFileAdapter();
