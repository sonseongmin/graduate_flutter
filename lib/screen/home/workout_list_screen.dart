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

  // ✅ 영어 → 한글 + 이미지 매핑
  static const Map<String, Map<String, String>> exerciseMap = {
    'pushup': {'name': '푸쉬업', 'image': 'assets/pushup.png'},
    'pullup': {'name': '풀업', 'image': 'assets/pullup.png'},
    'squat': {'name': '스쿼트', 'image': 'assets/squat.png'},
    'jumpingjack': {'name': '점핑잭', 'image': 'assets/jumping_jack.png'},
    'front_raise': {'name': '프론트레이즈', 'image': 'assets/front_raise.png'},
    'bench_press': {'name': '벤치프레스', 'image': 'assets/bench_press.png'},
    'sit_up': {'name': '싯업', 'image': 'assets/sit_up.png'},
  };

  // ✅ 한글 이름 변환
  String getExerciseName(String exercise) {
    return exerciseMap[exercise.toLowerCase()]?['name'] ?? exercise;
  }

  // ✅ 이미지 경로 변환
  String getImagePath(String exercise) {
    return exerciseMap[exercise.toLowerCase()]?['image'] ?? 'assets/default.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF20221E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '운동 목록',
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

            // ✅ exercise_type → name → fallback 순서로 안전하게 처리
            final exerciseKey = workout['exercise_type'] ?? workout['name'] ?? 'unknown';
            final displayName = getExerciseName(exerciseKey);
            final imagePath = getImagePath(exerciseKey);

            // ✅ rep_count 또는 count 키 모두 커버
            final int? rawCount = (workout['rep_count'] ?? workout['count']) as int?;
            final String countLabel = (rawCount != null ? '${rawCount}회' : '-');

            // ✅ double 변환 안전 처리
            final double calories =
                (workout['calories'] is num) ? (workout['calories'] as num).toDouble() : 0.0;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TodayWorkoutScreen(
                      name: displayName,
                      count: rawCount,
                      calories: calories,
                      date: date,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEAEA),
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
                            '$displayName $countLabel',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('🔥 칼로리 소모: ${calories.toStringAsFixed(2)} kcal'),
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
