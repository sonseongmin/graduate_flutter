import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:body_log/util/file_adapter.dart';
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
    return 'http://13.125.208.240';
  }

  // ============================================================
  // 업로드 처리
  // ============================================================
  Future<void> _pickAndUpload(BuildContext context, String exercise) async {
    final adapter = FileAdapter();

    try {
      _showProgressDialog(context);

      final result = await adapter.pickAndUpload(context, exercise);
      Navigator.pop(context); // 로딩 닫기

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TodayWorkoutScreen(
            name: result['exercise_type'] ?? '알 수 없음',
            count: result['rep_count'] ?? 0,
            calories: result['calories'] ?? 0,
            accuracy: (result['avg_accuracy'] ?? 90).toInt(),
            date: DateTime.now().toString(),
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업로드 실패: $e')),
      );
    }
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
                  onPressed: () {
                    if (kIsWeb) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('웹에서는 실시간 촬영을 지원하지 않습니다.'),
                        ),
                      );
                    } else {
                      FileAdapter().openCamera(context, exercise);
                    }
                  },
                  icon: const Icon(Icons.videocam, color: Colors.black),
                  label: const Text(
                    '실시간 촬영',
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
                const SizedBox(height: 20),
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

      // ✅ 하단 네비게이션 바 추가
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // 현재 페이지는 '영상'
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          final currentRoute = ModalRoute.of(context)?.settings.name;
          if (index == 0 && currentRoute != '/home') {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1 && currentRoute != '/video_upload') {
            Navigator.pushNamed(context, '/video_upload');
          } else if (index == 2 && currentRoute != '/history') {
            Navigator.pushNamed(context, '/history');
          } else if (index == 3 && currentRoute != '/settings') {
            Navigator.pushNamed(context, '/settings');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.ondemand_video), label: '영상'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '기록'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }
}
