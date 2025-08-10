import 'package:flutter/material.dart';
import '../../../UI/login_style.dart';

class FindAccountScreen extends StatelessWidget {
  const FindAccountScreen({super.key});

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
                '무엇을 찾으시겠어요?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/find_id'),
                style: LoginStyle.greenButtonStyle,
                child: const Text('아이디 찾기'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/verify_identity'),
                style: LoginStyle.greenButtonStyle,
                child: const Text('비밀번호 찾기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}