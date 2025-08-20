import 'package:flutter/material.dart';

class ExerciseCategoryScreen extends StatelessWidget {
  const ExerciseCategoryScreen({super.key});

  void _goToUpload(BuildContext context, String exerciseName) {
    Navigator.pushNamed(
      context,
      '/video_upload',
      arguments: {'exerciseName': exerciseName},
    );
  }

  Widget _buildCategoryButton(BuildContext context, String title) {
    return ElevatedButton(
      onPressed: () => _goToUpload(context, title),
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
              _buildCategoryButton(context, '푸쉬업'),
              _buildCategoryButton(context, '풀업'),
              _buildCategoryButton(context, '레그레이즈'),
              _buildCategoryButton(context, '점핑잭'),
              _buildCategoryButton(context, '플랭크'),
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
          } else if (index == 1 && currentRoute != '/exercise_category') {
            Navigator.pushNamed(context, '/exercise_category');
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
