import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'today_workout_screen.dart';

// 초(int)를 "mm:ss"로 포맷
String formatDuration(int seconds) {
  final minutes = seconds ~/ 60;           // 몫: 분
  final remainingSeconds = seconds % 60;   // 나머지: 초
  final mm = minutes.toString().padLeft(2, '0');
  final ss = remainingSeconds.toString().padLeft(2, '0');
  return '$mm:$ss';
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';
  bool _greeted = false;
  final DateTime now = DateTime.now();
  late final String today = DateFormat('yyyy.MM.dd').format(now);

  // NOTE: 플랭크 시간은 "초" 단위로 내려온다고 가정하면 UI가 mm:ss로 표시됨.
  final exerciseData = {
    'name': '스쿼트',
    'count': 20,
    'calories': 80,
    'time': 10, // 플랭크일 때 초 단위 값 사용 권장(예: 125)
    'accuracy': 85,
    'issues': ['무릎이 너무 튀어나옴', '자세가 불안정함'],
  };

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      debugPrint('❌ 토큰 없음');
      return;
    }

    final response = await http.get(
      Uri.parse('http://3.39.194.20:3000/api/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (mounted) {
        setState(() {
          userName = data['name'];
        });

        if (!_greeted && userName.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showGreeting();
          });
          _greeted = true;
        }
      }
      debugPrint('✅ 사용자 정보: $data');
    } else {
      debugPrint('❌ 사용자 정보 불러오기 실패: ${response.statusCode}');
    }
  }

  // 팝업 UI
  void _showGreeting() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'greeting',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                '안녕하세요, $userName 님',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: child,
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAED9A5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: const Text(
                  'Main Home', // 고정 타이틀
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final String exName = exerciseData['name'] as String;
                  final bool isPlank = exName == '플랭크';

                  final int? countVal = (exerciseData['count'] as int?);
                  final int? timeVal  = (exerciseData['time'] as int?);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TodayWorkoutScreen(
                        name: exName,
                        count: isPlank ? null : countVal, // 플랭크면 횟수 null
                        calories: exerciseData['calories'] as int,
                        time: isPlank ? timeVal : null,   // 플랭크는 초 단위 전달, 그 외 null
                        accuracy: exerciseData['accuracy'] as int,
                        date: today,
                        issues: List<String>.from(exerciseData['issues'] as List),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFF0D8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Builder(
                    builder: (context) {
                      final String exName = exerciseData['name'] as String;
                      final bool isPlank = exName == '플랭크';

                      final int? countVal = (exerciseData['count'] as int?);
                      final int? timeVal  = (exerciseData['time'] as int?);

                      final String countLabel = isPlank
                          ? '-'                         // 플랭크는 횟수 '-'
                          : (countVal != null ? '${countVal}회' : '-');

                      // 플랭크: 초 → mm:ss, 그 외: '-'
                      final String timeLabel = isPlank
                          ? (timeVal != null ? formatDuration(timeVal) : '-')
                          : '-';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            '오늘의 운동',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('🏋️ $exName $countLabel'),
                          Text('🔥 칼로리 소모: ${exerciseData['calories']} kcal'),
                          Text('⏱ 운동 시간: $timeLabel'),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF0D8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      '오늘의 추천 운동',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('하체 집중 → 런지 20회'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/recommend');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        '운동하러 가기',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/history');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFF0D8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '최근 운동 히스토리',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('하체 근육량 높음'),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
