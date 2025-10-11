import 'package:flutter/material.dart';
import '../home/today_workout_screen.dart';

class WorkoutListScreen extends StatelessWidget {
  final String date;
  final List<Map<String, dynamic>> workouts;

  const WorkoutListScreen({
    super.key,
    required this.date,
    required this.workouts,
  });

  String getImagePath(String exercise) {
    switch (exercise) {
      case '스쿼트':
        return 'assets/squat.png';
      case '푸쉬업':
        return 'assets/pushup.png';
      case '풀업':
        return 'assets/pullup.png';
      case '점핑잭':
        return 'assets/jumping_jack.png';
      default:
        return 'assets/default.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF20221E), // 배경색
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '오늘의 운동',
          style: TextStyle(color: Colors.white, fontFamily: 'Gamwulchi'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final workout = workouts[index];
            final imagePath = getImagePath(workout['name']);
            final int? rawCount = workout['count'] as int?;
            final String countLabel = (rawCount != null ? '${rawCount}회' : '-');

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TodayWorkoutScreen(
                      name: workout['name'] as String,
                      count: rawCount,
                      calories: workout['calories'] as int,
                      accuracy: ((workout['accuracy'] as double) * 100).toInt(),
                      date: date,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEAEA), // 박스 색
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Image.asset(imagePath, width: 50, height: 50),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${workout['name']} $countLabel',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('🔥 칼로리 소모: ${workout['calories']}kcal'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
