import 'package:flutter/material.dart';
import '../home/today_workout_screen.dart';

// 초(int)를 "mm:ss"로 포맷
String formatDuration(int seconds) {
  final minutes = seconds ~/ 60;           // 몫: 분
  final remainingSeconds = seconds % 60;   // 나머지: 초
  final mm = minutes.toString().padLeft(2, '0');
  final ss = remainingSeconds.toString().padLeft(2, '0');
  return '$mm:$ss';
}

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
      case '런지':
        return 'assets/lunge.png';
      default:
        return 'assets/default.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAED9A5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '오늘의 운동',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
            final bool isPlank = workout['name'] == '플랭크';

            // 원시 값
            final int? rawCount = workout['count'] as int?;
            // 서버가 플랭크 시간을 "초"로 내려준다고 가정
            final int? rawSeconds = workout['time'] as int?;

            // 표시 라벨
            final String countLabel =
            isPlank ? '-' : (rawCount != null ? '${rawCount}회' : '-');

            // 플랭크는 mm:ss, 그 외는 '-'
            final String timeLabel = isPlank
                ? (rawSeconds != null ? formatDuration(rawSeconds) : '-')
                : '-';

            // 상세 전달값 (nullable 규칙)
            final int? countForDetail = isPlank ? null : rawCount;

            // 상세 화면은 기존대로 "분(int)"을 기대하므로 초 → 분 변환하여 전달
            final int? timeForDetail =
            isPlank ? (rawSeconds != null ? (rawSeconds ~/ 60) : null) : null;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TodayWorkoutScreen(
                      name: workout['name'],
                      count: countForDetail,                       // 규칙 적용
                      calories: workout['calories'],
                      time: timeForDetail,                         // 초→분 변환 후 전달
                      accuracy: (workout['accuracy'] * 100).toInt(),
                      date: date,
                      issues: (workout['issues'] as List<dynamic>?)
                          ?.map((e) => e.toString())
                          .toList() ??
                          ['기록된 이슈 없음'],
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                          // 이름 + 횟수 라벨
                          Text(
                            '${workout['name']} $countLabel',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('🔥 칼로리 소모: ${workout['calories']}kcal'),
                          // 시간 라벨 (mm:ss 또는 '-')
                          Text('⏱ 운동 시간: $timeLabel'),
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
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          final currentRoute = ModalRoute.of(context)?.settings.name;

          if (index == 0 && currentRoute != '/home') {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1 && currentRoute != '/exercise_categorys') {
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
