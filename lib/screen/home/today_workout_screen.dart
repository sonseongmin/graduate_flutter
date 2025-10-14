import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart'; // JWT 저장용
import '../../../util/token_helper.dart';

class TodayWorkoutScreen extends StatefulWidget {
  final String name;
  final int? count;
  final int calories;
  final int accuracy;
  final String date;

  const TodayWorkoutScreen({
    super.key,
    required this.name,
    this.count,
    required this.calories,
    required this.accuracy,
    required this.date,
  });

  @override
  State<TodayWorkoutScreen> createState() => _TodayWorkoutScreenState();
}

class _TodayWorkoutScreenState extends State<TodayWorkoutScreen> {
  bool _isLoading = false;

  // ✅ JWT 토큰 불러오기
  Future<String?> getToken() async {
    return await TokenHelper.getToken(); // ✅ 여기만 수정
    }

  // ✅ 운동 결과 저장 API 호출
  Future<void> saveWorkout() async {
    setState(() => _isLoading = true);

    final url = Uri.parse('http://13.125.208.240/workouts'); // 🔥 실제 서버 주소로 변경
    final token = await getToken();

    if (token == null) {
      Fluttertoast.showToast(msg: "로그인이 필요합니다.");
      setState(() => _isLoading = false);
      return;
    }

    final now = DateTime.now();
    final body = jsonEncode({
      "exercise_type": widget.name,
      "started_at": now.subtract(const Duration(minutes: 10)).toIso8601String(),
      "ended_at": now.toIso8601String(),
      "rep_count": widget.count ?? 0,
      "avg_accuracy": widget.accuracy
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Fluttertoast.showToast(msg: "✅ 운동 기록이 저장되었습니다!");
        Navigator.pushNamed(context, '/history'); // 기록 페이지로 이동
      } else {
        print("응답 바디: ${response.body}");
        Fluttertoast.showToast(
          msg: "저장 실패 (${response.statusCode})",
          backgroundColor: Colors.redAccent,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "네트워크 오류: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ✅ 운동 이미지 선택
  String getImagePath(String exercise) {
    switch (exercise) {
      case 'squat':
        return 'assets/squat.png';
      case 'pullup':
        return 'assets/pullup.png';
      case 'pushup':
        return 'assets/pushup.png';
      case 'jumpingjack':
        return 'assets/jumping_jack.png';
      default:
        return 'assets/default.png';
    }
  }

  String _countLabel() {
    if (widget.count == null) return '-';
    return '${widget.count}회';
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = getImagePath(widget.name);
    final percent = (widget.accuracy.clamp(0, 100)) / 100.0;

    return Scaffold(
      backgroundColor: const Color(0xFF20221E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          } else if (index == 1) {
            Navigator.pushNamedAndRemoveUntil(context, '/video_upload', (route) => false);
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
      ),
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
                            '${widget.name} ${_countLabel()}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontFamily: 'Gamwulchi',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('🔥 칼로리 소모: ${widget.calories} kcal'),
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
                    color: const Color(0xFFEAEAEA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.name} 분석 결과',
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
                                Text('${widget.name} ${_countLabel()}'),
                                Text('칼로리 소모: ${widget.calories} kcal'),
                              ],
                            ),
                          ),
                          CircularPercentIndicator(
                            radius: 35.0,
                            lineWidth: 6.0,
                            percent: percent,
                            center: Text(
                              '${widget.accuracy}%',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            progressColor: const Color(0xFF20221E),
                            backgroundColor: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 8),
                          const Text('올바른 자세 비율'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : ElevatedButton(
                                onPressed: saveWorkout,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4E4E4E),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 32),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                                child: const Text('저장하기',
                                    style: TextStyle(color: Colors.white)),
                              ),
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
