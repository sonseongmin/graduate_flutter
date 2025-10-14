import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recommend_workout_screen.dart';
import 'today_workout_screen.dart';

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

  // ✅ 운동 데이터 (초기값)
  Map<String, dynamic> exerciseData = {
    'name': '-',
    'count': 0,
    'calories': 0,
    'accuracy': 0,
  };

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
    fetchWorkout(); // ✅ 운동 기록 불러오기
  }

  // ✅ 운동 이름 변환
  String translateExercise(String type) {
    switch (type) {
      case 'squat':
        return '스쿼트';
      case 'pushup':
        return '푸쉬업';
      case 'pullup':
        return '풀업';
      case 'jumping_jack':
      case 'jumpingjack':
        return '점핑잭';
      default:
        return type;
    }
  }

  // ✅ 사용자 정보 불러오기
  Future<void> fetchUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      debugPrint('❌ 토큰 없음');
      return;
    }

    final response = await http.get(
      Uri.parse('http://13.125.208.240/api/me'),
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

  // ✅ 운동 기록 불러오기
  Future<void> fetchWorkout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://13.125.208.240/api/v1/workouts'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> workouts = jsonDecode(utf8.decode(response.bodyBytes));

        if (workouts.isNotEmpty) {
          final latest = workouts.last; // ✅ 가장 최근 기록

          setState(() {
            exerciseData['name'] = translateExercise(latest['exercise_type']);
            exerciseData['count'] = latest['rep_count'] ?? 0;
            exerciseData['calories'] = latest['calories'] ?? 0;
            exerciseData['accuracy'] = (latest['avg_accuracy'] ?? 0).toInt();
          });

          debugPrint('✅ 최신 운동 기록: $latest');
        } else {
          debugPrint('⚠️ 운동 기록 없음');
        }
      } else {
        debugPrint('❌ 운동 기록 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ 네트워크 오류: $e');
    }
  }

  // ✅ 환영 팝업
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
      backgroundColor: const Color(0xFF20221E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Image.asset(
                  'assets/logo.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),

              // ✅ 오늘의 운동 카드
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEAEA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '오늘의 운동',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('🏋️ ${exerciseData['name']} ${exerciseData['count']}회'),
                    Text('🔥 칼로리 소모: ${exerciseData['calories']} kcal'),
                    Text('정확도: ${exerciseData['accuracy']}%'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        backgroundColor: const Color(0xFF4E4E4E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TodayWorkoutScreen(
                              name: exerciseData['name'],
                              count: exerciseData['count'],
                              calories: exerciseData['calories'],
                              accuracy: exerciseData['accuracy'],
                              date: today,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        '확인하기',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ 추천 운동 카드
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEAEA),
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
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        backgroundColor: const Color(0xFF4E4E4E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        '운동하러 가기',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecommendWorkoutScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ✅ 운동 히스토리
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/history');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEAEA),
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
                      Text('터치하면 기록 페이지로 이동합니다'),
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
