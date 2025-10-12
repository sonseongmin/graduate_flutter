import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'file_adapter.dart';
import 'package:camera/camera.dart';

class MobileFileAdapter {
  /// 갤러리에서 영상 선택 후 업로드
  Future<void> pickAndUpload(BuildContext context, String exercise) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    // ✅ 토큰 불러오기
    final token = await getAccessToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://13.125.219.3/api/v1/exercise/analyze'),
    );

    // ✅ Authorization 헤더 추가
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'multipart/form-data';

    // ✅ 파일 추가
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    // ✅ 운동 이름 전달 (필요 시)
    request.fields['exercise'] = exercise;

    // ✅ 요청 보내기
    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 업로드 성공! 분석 중입니다.')),
      );
    } else if (response.statusCode == 403) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ 인증 실패: 로그인 정보가 만료되었습니다.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 업로드 실패 (${response.statusCode})')),
      );
    }
  }

  /// 카메라로 촬영 후 업로드
  Future<void> recordAndUpload(BuildContext context, String exercise) async {
    final picker = ImagePicker();
    final XFile? recordedFile = await picker.pickVideo(source: ImageSource.camera);
    if (recordedFile == null) return;

    final file = File(recordedFile.path);

    final token = await getAccessToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://13.125.219.3/api/v1/exercise/analyze'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'multipart/form-data';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    request.fields['exercise'] = exercise;

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 업로드 성공! 분석 중입니다.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 업로드 실패 (${response.statusCode})')),
      );
    }
  }
}