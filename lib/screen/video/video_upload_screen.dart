import 'dart:async';
import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:body_log/util/file_adapter.dart'; // ✅ 어댑터 통합 import
import 'package:body_log/screen/home/today_workout_screen.dart';

class VideoUploadScreen extends StatelessWidget {
  final String? exerciseName;
  const VideoUploadScreen({super.key, this.exerciseName = '스쿼트'});

  String _resolveExerciseName(BuildContext context) {
    String effective = exerciseName ?? '스쿼트';
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map &&
        args['exerciseName'] is String &&
        (args['exerciseName'] as String).isNotEmpty) {
      effective = args['exerciseName'] as String;
    }
    return effective;
  }

  String _baseHost() {
    if (kIsWeb) return 'http://13.125.219.3';
    if (Platform.isAndroid) return 'http://10.0.2.2';
    return 'http://13.125.219.3';
  }

  // ============================================================
  // 파일 선택 및 업로드 (어댑터 사용)
  // ============================================================
  Future<void> _pickAndUpload(BuildContext context, String exercise) async {
    final adapter = FileAdapter();
    final picked = await adapter.pickVideo(); // ✅ 플랫폼 자동 구분
    if (picked == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('파일 선택이 취소되었습니다.')),
      );
      return;
    }

    await _uploadFile(context, picked, exercise);
  }

  // ============================================================
  // 업로드 처리 (웹/모바일 통합)
  // ============================================================
  Future<void> _uploadFile(
      BuildContext context, dynamic fileInput, String exercise) async {
    final host = _baseHost();
    final uri = Uri.parse('$host/api/v1/exercise/analyze');
    final request = http.MultipartRequest('POST', uri);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    try {
      if (kIsWeb) {
        // 🌐 웹: web_file_adapter.dart에서 html.File을 리턴받음
        import 'dart:html' as html; // 필요 시 web_adapter 내부에서만 import됨
        final htmlFile = fileInput;
        final reader = html.FileReader();
        reader.readAsArrayBuffer(htmlFile);
        await reader.onLoad.first;
        final bytes = reader.result as List<int>;
        request.files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: htmlFile.name),
        );
      } else {
        // 📱 모바일
        final file = fileInput as File;
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      }

      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);
      print('UPLOAD RESPONSE: ${resp.statusCode} - ${resp.body}');

      if (resp.statusCode == 202) {
        final body = jsonDecode(resp.body);
        final jobId = body['job_id'];
        if (jobId == null || jobId.toString().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('job_id가 없습니다. 다시 시도해주세요.')),
          );
          return;
        }

        _showProgressDialog(context);
        await _pollJobUntilDone(
          context,
          jobId,
          exercise,
          localFile: kIsWeb ? File('dummy') : fileInput,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('업로드 실패: ${resp.statusCode}')),
        );
      }
    } catch (e) {
      print('UPLOAD ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업로드 중 오류 발생: $e')),
      );
    }
  }

  // ============================================================
  // 분석 상태 폴링
  // ============================================================
  Future<void> _pollJobUntilDone(
      BuildContext context, String jobId, String exercise,
      {required File localFile}) async {
    final host = _baseHost();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    Timer? timer;
    bool finished = false;

    Future<void> closeDialogAnd(void Function() then) async {
      if (!finished) {
        finished = true;
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          then();
        }
      }
    }

    timer = Timer.periodic(const Duration(milliseconds: 900), (t) async {
      if (!context.mounted) return;

      final uri = Uri.parse('$host/api/v1/exercise/status/$jobId');
      final headers = <String, String>{};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final res = await http.get(uri, headers: headers);
      if (res.statusCode != 200) {
        timer?.cancel();
        await closeDialogAnd(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('상태 조회 실패: ${res.statusCode}')),
          );
        });
        return;
      }

      final j = jsonDecode(res.body) as Map<String, dynamic>;
      final status = (j['status'] as String?) ?? 'queued';

      if (status == 'done') {
        timer?.cancel();
        final result = j['result'] as Map<String, dynamic>?;

        await closeDialogAnd(() async {
          if (result == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('결과가 비어있습니다.')),
            );
            return;
          }

          final count = (result['rep_count'] ?? 0).toString();
          final calories = (result['calories'] ?? 0).toString();
          final accuracy = (result['accuracy'] ?? 0).toString();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TodayWorkoutScreen(
                name: exercise,
                count: int.tryParse(count) ?? 0,
                calories: int.tryParse(calories) ?? 0,
                accuracy: int.tryParse(accuracy) ?? 0,
                date: DateTime.now().toString().split(' ').first,
              ),
            ),
          );
        });
      }
    });
  }

  // ============================================================
  // 로딩 다이얼로그
  // ============================================================
  void _showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Dialog(
        backgroundColor: Colors.black87,
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('분석 중입니다...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _resolveExerciseName(context);

    return Scaffold(
      backgroundColor: const Color(0xFF20221E),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickAndUpload(context, exercise),
                  icon: const Icon(Icons.upload_file, color: Colors.black),
                  label: const Text(
                    '운동 영상 업로드',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEAEAEA),
                    minimumSize: const Size.fromHeight(60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
