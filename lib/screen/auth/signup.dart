import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../UI/login_style.dart';
import '../../../UI/input_field.dart';
import '../../../UI/green_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  static const String baseUrl = 'http://127.0.0.1:8000';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final idController = TextEditingController();
  final pwController = TextEditingController();
  final emailController = TextEditingController();

  bool isUsernameAvailable = false;

  Future<void> checkUsernameAvailability() async {
    final username = idController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디를 입력해주세요.')),
      );
      return;
    }

    final url = Uri.parse('${SignupScreen.baseUrl}/auth/check-username?username=$username');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          isUsernameAvailable = data['available'] == true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isUsernameAvailable ? '사용 가능한 아이디입니다.' : '이미 사용 중인 아이디입니다.'),
            backgroundColor: isUsernameAvailable ? Colors.green : Colors.redAccent,
          ),
        );
      } else {
        throw Exception('서버 오류');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류 발생: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> signupRequest({
    required String name,
    required String username,
    required String password,
    required String email,
  }) async {
    final url = Uri.parse('${SignupScreen.baseUrl}/users');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'username': username,
          'password': password,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ 회원가입 성공');
        return true;
      } else {
        debugPrint('❌ 회원가입 실패: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ 네트워크 오류: $e');
      return false;
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
                      onPressed: checkUsernameAvailability,
                      style: LoginStyle.greenButtonStyle,
                      child: const Text('중복확인'),
                    ),
                  ],
                ),
                InputField(controller: pwController, hint: '비밀번호', obscure: true),
                InputField(controller: emailController, hint: '이메일'),
                GreenButton(
                  text: '가입',
                  onPressed: () async {
                    if (!isUsernameAvailable) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('아이디 중복확인을 먼저 해주세요.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    final success = await signupRequest(
                      name: nameController.text.trim(),
                      username: idController.text.trim(),
                      password: pwController.text.trim(),
                      email: emailController.text.trim(),
                    );

                    if (success) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('user_name', nameController.text.trim());
                      Navigator.pushNamed(context, '/signup_success');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('회원가입 실패. 정보를 확인해주세요.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                ),
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
