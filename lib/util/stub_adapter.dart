import 'package:flutter/material.dart';
import 'file_adapter.dart';

class StubFileAdapter implements IFileAdapter {
  @override
  Future<void> pickAndUpload(BuildContext context, String exercise) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⚙️ 현재 환경에서는 업로드 기능이 비활성화되어 있습니다.')),
    );
  }

  @override
  Future<void> openCamera(BuildContext context, String exercise) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⚙️ 현재 환경에서는 카메라 기능이 비활성화되어 있습니다.')),
    );
  }
}

IFileAdapter createFileAdapter() => StubFileAdapter();
