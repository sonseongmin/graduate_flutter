import 'package:flutter/material.dart';
import 'file_adapter.dart';

class MobileFileAdapter implements IFileAdapter {
  @override
  Future<void> pickAndUpload(BuildContext context, String exercise) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('모바일 업로드는 아직 구현되지 않았습니다.')),
    );
  }

  @override
  Future<void> openCamera(BuildContext context, String exercise) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('모바일 카메라 로직을 추가하세요.')),
    );
  }
}

IFileAdapter createFileAdapter() => MobileFileAdapter();
