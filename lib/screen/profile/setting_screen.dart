import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // 빈 값은 화면에 '-' 로 보이게 통일
  String _displayOrDash(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty || s.toLowerCase() == 'null') return '-';
    return s;
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    final sex = prefs.getString('inbody_sex');   // 인바디에서 저장된 성별
    final birth = prefs.getString('inbody_birth'); // 인바디에서 저장된 생년월일(YYYY-MM-DD 등)

    setState(() {
      userName = name;
      selectedGender = sex ?? '';
      birthDate = birth ?? '';
    });

    debugPrint('🟢 이름: $name, 성별: $selectedGender, 생년월일: $birthDate');
  }

  void resetWorkoutRecords() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('운동 기록 초기화'),
        content: const Text('정말 모든 운동 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('운동 기록이 초기화되었습니다')),
                );
              },
              child: const Text('확인')),
        ],
      ),
    );
  }

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
                child: Text('설정',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
              ),
              const SizedBox(height: 24),
              const Center(child: Icon(Icons.account_circle, size: 60)),
              const SizedBox(height: 8),
              Center(child: Text(userName, style: const TextStyle(fontSize: 18))),
              Divider(height: 40, thickness: 2, color: Colors.green[700]),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('이름'),
                Text(userName),
              ]),
              const SizedBox(height: 12),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('생년월일'),
                //인바디 입력 없으면 '-' 표시
                Text(_displayOrDash(birthDate)),
              ]),
              const SizedBox(height: 12),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('성별'),
                //인바디 입력 없으면 '-' 표시
                Text(_displayOrDash(selectedGender)),
              ]),

              Divider(height: 40, thickness: 2, color: Colors.green[700]),

              ListTile(
                leading: const Icon(Icons.monitor_weight_outlined),
                title: const Text('인바디 정보 입력 및 수정'),
                onTap: () async {
                  // 인바디 화면에서 돌아오면 데이터 새로고침
                  await Navigator.pushNamed(context, '/inbody');
                  if (!mounted) return;
                  await _loadUserData();
                },
              ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: const Text('운동 기록 초기화'),
                onTap: resetWorkoutRecords,
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
