import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../UI/login_style.dart';
import '../../../UI/input_field.dart';
import '../../../UI/green_button.dart';
import 'reset_password.dart';

class VerifyIdentityScreen extends StatefulWidget {
  const VerifyIdentityScreen({super.key});

  @override
  State<VerifyIdentityScreen> createState() => _VerifyIdentityScreenState();
}

class _VerifyIdentityScreenState extends State<VerifyIdentityScreen> {
  final nameController = TextEditingController();
  final idController = TextEditingController();
  final emailController = TextEditingController();

  bool isLoading = false;

  void verifyIdentity() async {
    final username = idController.text.trim();
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (username.isEmpty || name.isEmpty || email.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('입력 오류'),
          content: Text('모든 필드를 입력해주세요.'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/auth/verify-identity'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        'username': username,
        'name': name,
        'email': email,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(username: username),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('인증 실패'),
          content: Text('입력한 정보가 일치하지 않습니다.\n\n서버 응답: ${response.body}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
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
                InputField(controller: emailController, hint: '이메일'),
                const SizedBox(height: 10),
                isLoading
                    ? const CircularProgressIndicator()
                    : GreenButton(text: '본인 확인', onPressed: verifyIdentity),
                const SizedBox(height: 20),
                Row(
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
