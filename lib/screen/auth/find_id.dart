import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../UI/login_style.dart';
import '../../../UI/input_field.dart';
import '../../../UI/green_button.dart';

class FindIdScreen extends StatefulWidget {
  const FindIdScreen({super.key});

  @override
  State<FindIdScreen> createState() => _FindIdScreenState();
}

class _FindIdScreenState extends State<FindIdScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  void sendEmail() async {
    final email = emailController.text.trim();

    final url = Uri.parse('/api//auth/find-username?email=$email');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final username = data['username'];

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('아이디 찾기 성공'),
          content: Text('가입하신 아이디는 "$username" 입니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      final data = jsonDecode(response.body);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('찾을 수 없음'),
          content: Text(data['detail'] ?? '아이디를 찾을 수 없습니다.'),
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
                const Text('아이디 찾기', style: LoginStyle.logoStyle),
                const SizedBox(height: 20),
                InputField(controller: nameController, hint: '이름'),
                InputField(controller: emailController, hint: '가입시 작성한 이메일'),
                GreenButton(text: '아이디 찾기', onPressed: sendEmail),
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
