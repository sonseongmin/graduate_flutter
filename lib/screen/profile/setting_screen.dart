import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:body_log/util/token_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController ageController = TextEditingController();
  String selectedGender = '';
  String userName = '';
  String birthDate = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ✅ 공백이나 null일 때 "-" 로 표시
  String _displayOrDash(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty || s.toLowerCase() == 'null') return '-';
    return s;
  }

  // ✅ 유저 정보 로드
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    final sex = prefs.getString('inbody_sex');
    final birth = prefs.getString('inbody_birth');

    setState(() {
      userName = name;
      selectedGender = sex ?? '';
      birthDate = birth ?? '';
    });

    debugPrint('🟢 이름: $name, 성별: $selectedGender, 생년월일: $birthDate');
  }

  // ✅ 운동 기록 초기화 API 호출
  Future<void> resetWorkoutRecords() async {
    final token = await TokenHelper.getToken();

    if (token == null) {
      Fluttertoast.showToast(msg: "로그인이 필요합니다.");
      return;
    }

    final url = Uri.parse('http://13.125.208.240/api/v1/workouts/reset');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "✅ 운동 기록이 모두 삭제되었습니다.");
      } else if (response.statusCode == 204) {
        Fluttertoast.showToast(msg: "✅ 운동 기록이 초기화되었습니다.");
      } else {
        Fluttertoast.showToast(msg: "삭제 실패: ${response.statusCode}");
        debugPrint("Response body: ${response.body}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "네트워크 오류: $e");
    }
  }

  // ✅ 확인 다이얼로그
  void showResetConfirmDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('운동 기록 초기화'),
        content: const Text('정말 모든 운동 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await resetWorkoutRecords();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // ✅ 로그아웃
  void logout() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  '설정',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Gamwulchi',
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(child: Icon(Icons.account_circle, size: 60)),
              const SizedBox(height: 8),
              Center(child: Text(userName, style: const TextStyle(fontSize: 18))),
              const Divider(height: 40, thickness: 2, color: Color(0xFF20221E)),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('이름'),
                Text(userName),
              ]),
              const SizedBox(height: 12),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('생년월일'),
                Text(_displayOrDash(birthDate)),
              ]),
              const SizedBox(height: 12),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('성별'),
                Text(_displayOrDash(selectedGender)),
              ]),

              const Divider(height: 40, thickness: 2, color: Color(0xFF20221E)),

              ListTile(
                leading: const Icon(Icons.monitor_weight_outlined),
                title: const Text('인바디 정보 입력 및 수정'),
                onTap: () async {
                  await Navigator.pushNamed(context, '/inbody');
                  if (!mounted) return;
                  await _loadUserData();
                },
              ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: const Text('운동 기록 초기화'),
                onTap: showResetConfirmDialog, // ✅ 다이얼로그 연결
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('로그아웃'),
                onTap: logout,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: Colors.black,
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