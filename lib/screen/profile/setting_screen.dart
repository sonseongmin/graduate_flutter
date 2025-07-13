import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final String userName; // 회원가입 시 받아온 이름
  const SettingsScreen({super.key, required this.userName});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController ageController = TextEditingController();
  String selectedGender = '남';

  void resetWorkoutRecords() {
    // 실제 기록 초기화 로직 (임시로 팝업만)
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('운동 기록 초기화'),
        content: const Text('정말 모든 운동 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소')),
          TextButton(
              onPressed: () {
                // TODO: 기록 초기화 로직
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
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        centerTitle: true,
        title: const Text('설정', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.account_circle, size: 60),
            const SizedBox(height: 8),
            Text(widget.userName, style: const TextStyle(fontSize: 18)),

            Divider(height: 40, thickness: 2, color: Colors.green[700]),
            // 기본 정보
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('이름'),
              Text(widget.userName),
            ]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('나이'),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: '만 나이'),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('성별'),
              DropdownButton<String>(
                value: selectedGender,
                items: ['남', '여']
                    .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedGender = value);
                  }
                },
              ),
            ]),
            Divider(height: 40, thickness: 2, color: Colors.green[700]),

            ListTile(
              leading: const Icon(Icons.monitor_weight_outlined),
              title: const Text('인바디 정보 입력 및 수정'),
              onTap: () {
                Navigator.pushNamed(context, '/inbody');
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/history');
          } else if (index == 3) {
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
