import 'package:flutter/material.dart';
import 'file_adapter.dart';

class MobileFileAdapter implements IFileAdapter {
  @override
  Future<void> pickAndUpload(BuildContext context, String exercise) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📱 모바일 환경에서만 업로드 기능을 지원합니다.')),
    );
  }

  @override
  Future<void> openCamera(BuildContext context, String exercise) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📸 카메라 촬영 기능은 추후 지원 예정입니다.')),
    );
  }
}

IFileAdapter createFileAdapter() => MobileFileAdapter();
