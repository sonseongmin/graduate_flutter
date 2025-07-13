import 'package:flutter/material.dart';
import '../../../UI/login_style.dart';
import '../../../UI/input_field.dart';
import '../../../UI/green_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final idController = TextEditingController();
    final pwController = TextEditingController();

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
                const Text('body log', style: LoginStyle.logoStyle),
                const SizedBox(height: 20),

                InputField(controller: idController, hint: '아이디'),
                InputField(controller: pwController, hint: '비밀번호', obscure: true),

                GreenButton(
                  text: '로그인',
                  onPressed: () {
                    // TODO: 실제 로그인 로직
                    Navigator.pushReplacementNamed(context, '/home'); // 홈 화면으로 이동
                  },
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  color: Colors.white,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('계정이 없으신가요?'),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/signup'),
                        child: const Text(
                          '가입하기',
                          style: TextStyle(color: Color(0xFF4A774F)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/find_account'),
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
