import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecommendWorkoutScreen extends StatelessWidget {
  RecommendWorkoutScreen({super.key});

  final Map<String, List<Map<String, dynamic>>> weeklyWorkouts = {
    '2025-07-26': [
      {'name': '풀업', 'count': 20, 'calories': 80},
      {'name': '스쿼트', 'count': 30, 'calories': 90},
    ],
    '2025-07-27': [
      {'name': '점핑잭', 'count': 20, 'calories': 80},
      {'name': '푸쉬업', 'count': 20, 'calories': 80},
    ],
  };

  String formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final weekday = ['월', '화', '수', '목', '금', '토', '일'][date.weekday - 1];
    return DateFormat('MM/dd').format(date) + ' ($weekday)';
  }
  String getImagePath(String name) {
    final n = name.replaceAll(' ', ''); 
    if (n.contains('스쿼트')) return 'assets/squat.png';
    if (n.contains('풀업')) return 'assets/pullup.png';
    if (n.contains('푸쉬업')) return 'assets/pushup.png';
    if (n.contains('점핑잭')) return 'assets/jumping_jack.png';

    return 'assets/logo2.png';
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFF20221E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '주간 운동 루틴 추천',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Gamwulchi',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                                color: Colors.white, // ✅ 날짜 글씨 흰색
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...entry.value.map((workout) {
                          final imagePath = getImagePath(workout['name']);
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
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
                                      final n = workout['name'].toString();
                                      final isPlank = n.contains('플랭크'); // 기존 로직 유지
                                      final countLabel =
                                      isPlank ? '-' : '${workout['count']}회';
                                      return '$n $countLabel';
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
