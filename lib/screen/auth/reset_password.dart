import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../UI/login_style.dart';
import '../../../UI/input_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String username;

  const ResetPasswordScreen({super.key, required this.username});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  void resetPassword() async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showDialog('입력 오류', '모든 필드를 입력해주세요.');
      return;
    }

    if (newPassword != confirmPassword) {
      _showDialog('비밀번호 불일치', '비밀번호가 서로 일치하지 않습니다.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/auth/update-password'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'username': widget.username,
          'new_password': newPassword,
        }),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        _showSuccessDialog();
      } else {
        final data = jsonDecode(response.body);
        _showDialog('오류', data['detail'] ?? '알 수 없는 오류가 발생했습니다.');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showDialog('네트워크 오류', '서버와 연결할 수 없습니다.');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('비밀번호 변경 완료'),
        content: const Text('비밀번호가 성공적으로 변경되었습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('로그인하러 가기'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF20221E),
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
                const Text('비밀번호 재설정', style: LoginStyle.logoStyle),
                const SizedBox(height: 20),

                InputField(
                  controller: newPasswordController,
                  hint: '새 비밀번호',
                  obscure: true,
                ),
                InputField(
                  controller: confirmPasswordController,
                  hint: '비밀번호 확인',
                  obscure: true,
                ),

                const SizedBox(height: 10),

                isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4E4E4E), // 버튼색
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '비밀번호 변경',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
