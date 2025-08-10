import 'dart:io';
import 'package:flutter/material.dart';

class VideoAnalysisScreen extends StatelessWidget {
  final File videoFile;
  final String exercise;
  final int count;
  final String duration;
  final int calories;
  final List<String> issues;
  final List<String> goodForm;

  const VideoAnalysisScreen({
    super.key,
    required this.videoFile,
    required this.exercise,
    required this.count,
    required this.duration,
    required this.calories,
    required this.issues,
    required this.goodForm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('분석 결과')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              color: Colors.black12,
              child: const Center(child: Text('영상 미리보기 (더미)')),
            ),
            const SizedBox(height: 16),
            Text('$exercise $count회'),
            Text('⏱ $duration분'),
            Text('🔥 약 $calories kcal'),
            const SizedBox(height: 16),
            const Divider(),
            const Text('분석 결과', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...issues.map((e) => Row(
              children: [
                const Icon(Icons.close, color: Colors.red),
                Text(' $e'),
              ],
            )),
            ...goodForm.map((e) => Row(
              children: [
                const Icon(Icons.check, color: Colors.green),
                Text(' $e'),
              ],
            )),
            const Spacer(),
            ElevatedButton(
              onPressed: () {

              },
              child: const Text('저장하기',  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                minimumSize: const Size.fromHeight(50),
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
