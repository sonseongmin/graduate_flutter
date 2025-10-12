import 'package:flutter/material.dart';

/// 공통 인터페이스 정의 (웹/모바일 공용)
abstract class IFileAdapter {
  Future<void> pickAndUpload(BuildContext context, String exercise);
  Future<void> openCamera(BuildContext context, String exercise);
}

/// 스텁 (예외용)
class StubFileAdapter implements IFileAdapter {
  @override
  Future<void> pickAndUpload(BuildContext context, String exercise) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('현재 플랫폼에서는 업로드가 지원되지 않습니다.')),
    );
  }

  @override
  Future<void> openCamera(BuildContext context, String exercise) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('현재 플랫폼에서는 카메라 촬영이 지원되지 않습니다.')),
    );
  }
}
