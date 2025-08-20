import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

// 초(int)를 "mm:ss"로 포맷
String formatDuration(int seconds) {
  final minutes = seconds ~/ 60;           // 몫: 분
  final remainingSeconds = seconds % 60;   // 나머지: 초
  final mm = minutes.toString().padLeft(2, '0');
  final ss = remainingSeconds.toString().padLeft(2, '0');
  return '$mm:$ss';
}

class TodayWorkoutScreen extends StatelessWidget {
  final String name;
  final int? count;     // 플랭크: null, 그 외: 횟수
  final int calories;
  final int? time;      // 플랭크: 초 단위(예: 125), 그 외: null
  final int accuracy;   // 0~100
  final String date;
  final List<String> issues;

  const TodayWorkoutScreen({
    super.key,
    required this.name,
    this.count,
    required this.calories,
    this.time,
    required this.accuracy,
    required this.date,
    required this.issues,
  });

  String getImagePath(String exercise) {
    switch (exercise) {
      case '스쿼트':
        return 'assets/squat.png';
      case '푸쉬업':
        return 'assets/pushup.png';
      case '풀업':
        return 'assets/pullup.png';
      case '레그레이즈':
        return 'assets/leg_raise.png';
      case '점핑잭':
        return 'assets/jumping_jack.png';
      case '플랭크':
        return 'assets/plank.png';
      default:
        return 'assets/default.png';
    }
  }

  bool get _isPlank => name == '플랭크';

  String _countLabel() {
    if (_isPlank) return '-';
    if (count == null) return '-';
    return '${count}회';
  }

  String _timeLabel() {
    if (_isPlank) {
      if (time == null) return '-';
      return formatDuration(time!);
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = getImagePath(name);
    final percent = (accuracy.clamp(0, 100)) / 100.0;

    return Scaffold(
      backgroundColor: const Color(0xFFAED9A5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('오늘의 운동', style: TextStyle(color: Colors.black)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          } else if (index == 1) {
            Navigator.pushNamedAndRemoveUntil(context, '/exercise_category', (route) => false);
          } else if (index == 2) {
            Navigator.pushNamedAndRemoveUntil(context, '/history', (route) => false);
          } else if (index == 3) {
            Navigator.pushNamedAndRemoveUntil(context, '/settings', (route) => false);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.ondemand_video), label: '영상'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '기록'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ), // ← 여기 쉼표 후 Scaffold의 다음 파라미터로 계속
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 상단 요약 카드
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Image.asset(imagePath, width: 60, height: 60),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 예: "스쿼트 20회" / "플랭크 -"
                          Text(
                            '$name ${_countLabel()}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text('🔥 칼로리 소모: $calories kcal'),
                          // 예: 스쿼트는 '-', 플랭크는 'mm:ss'
                          Text('⏱ 운동 시간: ${_timeLabel()}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 분석 카드
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$name 분석 결과', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 동일 규칙 사용
                                Text('$name ${_countLabel()}'),
                                Text('🔥 칼로리 소모: $calories kcal'),
                                Text('⏱ 운동 시간: ${_timeLabel()}'),
                              ],
                            ),
                          ),
                          CircularPercentIndicator(
                            radius: 35.0,
                            lineWidth: 6.0,
                            percent: percent,
                            center: Text('$accuracy%', style: const TextStyle(fontWeight: FontWeight.bold)),
                            progressColor: Colors.green,
                            backgroundColor: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 8),
                          const Text('올바른 자세 비율'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('잘못된 자세: ${issues.length}건'),
                      ...issues.map((issue) => Text('- $issue')),
                      const Spacer(),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('저장하기', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
