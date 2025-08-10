import 'package:flutter/material.dart';
import '../../../UI/login_style.dart';
import '../../../UI/green_button.dart';

class SignupSuccessScreen extends StatelessWidget {
  const SignupSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginStyle.backgroundColor,
      body: Center(
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
              const Text(
                '🎉 회원가입이 완료되었습니다!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              GreenButton(
                text: '로그인하러 가기',
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
