import 'package:flutter/material.dart';
import '../../../UI/login_style.dart';
import '../../../UI/input_field.dart';
import '../../../UI/green_button.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final idController = TextEditingController();
    final pwController = TextEditingController();
    final emailController = TextEditingController();

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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('body log', style: LoginStyle.logoStyle),
                const SizedBox(height: 20),
                InputField(controller: nameController, hint: '이름'),
                Row(
                  children: [
                    Expanded(
                      child: InputField(controller: idController, hint: '아이디'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {},
                      style: LoginStyle.greenButtonStyle,
                      child: const Text('중복확인'),
                    ),
                  ],
                ),
                InputField(controller: pwController, hint: '비밀번호', obscure: true),
                InputField(controller: emailController, hint: '이메일'),
                GreenButton(
                  text: '가입',
                  onPressed: () {
                    // TODO: 실제 가입 로직 구현
                    Navigator.pushNamed(context, '/signup_success');
                  },
                ),
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