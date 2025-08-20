import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// 초(int)를 "mm:ss"로 포맷
String formatDuration(int seconds) {
  final minutes = seconds ~/ 60;           // 몫: 분
  final remainingSeconds = seconds % 60;   // 나머지: 초
  final mm = minutes.toString().padLeft(2, '0');
  final ss = remainingSeconds.toString().padLeft(2, '0');
  return '$mm:$ss';
}

class RecommendWorkoutScreen extends StatelessWidget {
  RecommendWorkoutScreen({super.key});

  final Map<String, List<Map<String, dynamic>>> weeklyWorkouts = {
    '2025-07-26': [
      {'name': '런지', 'count': 20, 'calories': 80},
      {'name': '스쿼트', 'count': 30, 'calories': 90},
    ],
    '2025-07-27': [
      {'name': '풀 업', 'count': 20, 'calories': 80},
      {'name': '푸쉬 업', 'count': 20, 'calories': 80},
    ],
  };

  String formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final weekday = ['월', '화', '수', '목', '금', '토', '일'][date.weekday - 1];
    return DateFormat('MM/dd').format(date) + ' ($weekday)';
  }

  String getImagePath(String name) {
    if (name.contains('런지')) return 'assets/lunge.png';
    if (name.contains('스쿼트')) return 'assets/squat.png';
    if (name.contains('푸쉬')) return 'assets/pushup.png';
    if (name.contains('풀')) return 'assets/pushup.png';
    return 'assets/default.png';
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xfff0f8ee),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                '주간 운동 루틴 추천',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: weeklyWorkouts.entries.map((entry) {
                  final isToday = entry.key == today;
                  final dateLabel = formatDate(entry.key);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 10,
                              color: isToday ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              dateLabel,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...entry.value.map((workout) {
                          final imagePath = getImagePath(workout['name']);
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(imagePath, width: 28, height: 28),
                                    const SizedBox(width: 8),
                                    Text(() {
                                      final isPlank = workout['name'].toString().contains('플랭크');
                                      final countLabel = isPlank ? '-' : '${workout['count']}회';
                                      return '${workout['name']} $countLabel';
                                    }()),
                                  ],
                                ),
                                Text('약 ${workout['calories']} kcal'),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
