import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'video_analysis_screen.dart';

class ExerciseCategoryScreen extends StatelessWidget {
  const ExerciseCategoryScreen({super.key});

  Future<void> _uploadVideo(BuildContext context, String exerciseName) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null || result.files.single.path == null) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final videoFile = File(result.files.single.path!);
    final uri = Uri.parse('http://127.0.0.1:8000/upload');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', videoFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoAnalysisScreen(
            videoFile: videoFile,
            exercise: exerciseName,
            count: 10,
            duration: '00:02',
            calories: 20,
            issues: ['무릎이 너무 앞으로 나감'],
            goodForm: ['좋은 자세 입니다'],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업로드 실패 (코드: ${response.statusCode})')),
      );
    }
  }

  Widget _buildCategoryButton(BuildContext context, String title) {
    return ElevatedButton(
      onPressed: () => _uploadVideo(context, title),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade200,
        minimumSize: const Size(140, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      child: Text(title, style: const TextStyle(fontSize: 16, color: Colors.black)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('운동 카테고리 선택')),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildCategoryButton(context, '스쿼트'),
              _buildCategoryButton(context, '싯업'),
              _buildCategoryButton(context, '푸쉬업'),
              _buildCategoryButton(context, '점핑잭'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.green[800],
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
