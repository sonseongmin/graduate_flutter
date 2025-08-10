import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'video_analysis_screen.dart';

class VideoUploadScreen extends StatelessWidget {
  const VideoUploadScreen({super.key});

  Future<void> _uploadVideoToFastAPI(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null || result.files.single.path == null) return;

    final videoFile = File(result.files.single.path!);

    final uri = Uri.parse('http://127.0.0.1:8000/upload');

    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', videoFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoAnalysisScreen(
            videoFile: videoFile,
            exercise: '스쿼트',
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

  void _navigateToAnalysis(BuildContext context) {
    final uploadedVideo = File(r'C:\bodylog-backend\media\sample_video.mp4');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoAnalysisScreen(
          videoFile: uploadedVideo,
          exercise: '스쿼트',
          count: 10,
          duration: '00:02',
          calories: 20,
          issues: ['무릎이 너무 앞으로 나감'],
          goodForm: ['좋은 자세 입니다'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('영상 업로드')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/exercise_category'),
              icon: const Icon(Icons.videocam, color: Colors.white),
              label: const Text('실시간 촬영', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade200,
                minimumSize: const Size.fromHeight(60),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/exercise_category'),
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: const Text('동영상 파일 업로드', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade200,
                minimumSize: const Size.fromHeight(60),
              ),
            ),
          ],
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