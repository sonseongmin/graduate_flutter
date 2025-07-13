import 'package:flutter/material.dart';
import '../../../UI/login_style.dart';
import '../../../UI/input_field.dart';
import '../../../UI/green_button.dart';

class FindPasswordScreen extends StatefulWidget {
  const FindPasswordScreen({super.key});

  @override
  State<FindPasswordScreen> createState() => _FindPasswordScreenState();
}

class _FindPasswordScreenState extends State<FindPasswordScreen> {
  final nameController = TextEditingController();
  final idController = TextEditingController();
  String? passwordResult;

  void findPassword() {
    // 비밀번호 찾기 로직: 백엔드 연결 시 수정 예정
    setState(() {
      passwordResult = 'qwer1234'; // 임시 표시
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginStyle.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('비밀번호 찾기', style: LoginStyle.logoStyle),
                const SizedBox(height: 20),
                InputField(controller: nameController, hint: '이름'),
                InputField(controller: idController, hint: '아이디'),
                GreenButton(text: '확인', onPressed: findPassword),
                if (passwordResult != null) ...[
                  const SizedBox(height: 20),
                  Text('비밀번호는 $passwordResult 입니다.', style: LoginStyle.resultStyle),
                  const SizedBox(height: 10),
                  GreenButton(
                    text: '로그인하러 가기',
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                  ),
                ],
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  color: Colors.white,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('계정이 이미 있으신가요?'),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        child: const Text(
                          '로그인하기',
                          style: TextStyle(color: Color(0xFF4A774F)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/find_account'),
                  child: const Text(
                    '아이디/비밀번호 찾기',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}