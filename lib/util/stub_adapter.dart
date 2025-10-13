import 'package:flutter/material.dart';
import 'file_adapter.dart';

class FileAdapterImpl implements IFileAdapter {
  @override
  Future<void> pickAndUpload(BuildContext context, String exercise) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⚙️ 현재 플랫폼에서 파일 업로드가 지원되지 않습니다.')),
    );
  }

  @override
  Future<void> openCamera(BuildContext context, String exercise) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⚙️ 현재 플랫폼에서 카메라가 지원되지 않습니다.')),
    );
  }
}
