import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/circular_percent_indicator.dart';

class TodayWorkoutScreen extends StatefulWidget {
  const TodayWorkoutScreen({super.key});

  @override
  State<TodayWorkoutScreen> createState() => _TodayWorkoutScreenState();
}

class _TodayWorkoutScreenState extends State<TodayWorkoutScreen> {
  bool isLoading = true;
  String name = '';
  int count = 0;
  int calories = 0;
  int accuracy = 0;
  String date = '';

  @override
  void initState() {
    super.initState();
    fetchLatestWorkout();
  }

  Future<void> fetchLatestWorkout() async {
    const String baseUrl = 'http://13.125.219.3:5000/api/v1/workouts/latest'; // 🔥 백엔드 주소
    const String token = '<JWT_TOKEN>'; // 로그인 시 받아온 토큰 (SharedPreferences 등에서 불러오기)

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          name = _translateExercise(data['exercise_type']);
          count = data['rep_count'] ?? 0;
          calories = data['calories'] ?? 0;
          accuracy = data['avg_accuracy'] ?? 0;
          date = data['created_at']?.toString().split('T').first ?? '';
          isLoading = false;
        });
      } else {
        throw Exception('서버 응답 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ 운동 데이터 불러오기 실패: $e');
      setState(() => isLoading = false);
    }
  }

  String _translateExercise(String eng) {
    switch (eng) {
      case 'pushup': return '푸쉬업';
      case 'pullup': return '풀업';
      case 'squat': return '스쿼트';
      case 'jumpjack': return '점핑잭';
      default: return eng;
    }
  }

  String getImagePath(String exercise) {
    switch (exercise) {
      case '스쿼트': return 'assets/squat.png';
      case '풀업': return 'assets/pullup.png';
      case '푸쉬업': return 'assets/pushup.png';
      case '점핑잭': return 'assets/jumping_jack.png';
      default: return 'assets/default.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF20221E),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final imagePath = getImagePath(name);
    final percent = (accuracy.clamp(0, 100)) / 100.0;

    return Scaffold(
      backgroundColor: const Color(0xFF20221E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '오늘의 운동',
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'Gamwulchi',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEAEA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Image.asset(imagePath, width: 60, height: 60),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$name ${count}회',
                            style: const TextStyle(
                              fontSize: 24,
                              fontFamily: 'Gamwulchi',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('🔥 칼로리 소모: $calories kcal'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEAEA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$name 분석 결과',
                        style: const TextStyle(
                          fontSize: 24,
                          fontFamily: 'Gamwulchi',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$name ${count}회'),
                                Text('칼로리 소모: $calories kcal'),
                              ],
                            ),
                          ),
                          CircularPercentIndicator(
                            radius: 35.0,
                            lineWidth: 6.0,
                            percent: percent,
                            center: Text('$accuracy%',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            progressColor: const Color(0xFF20221E),
                            backgroundColor: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 8),
                          const Text('올바른 자세 비율'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
