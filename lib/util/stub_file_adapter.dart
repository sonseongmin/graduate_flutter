import 'package:flutter/material.dart';

class StubAdapter {
  Future<void> pickAndUpload(BuildContext context, String exercise) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('이 플랫폼에서는 업로드를 지원하지 않습니다.')),
    );
  }
}
