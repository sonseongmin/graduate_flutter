import 'package:flutter/material.dart';
import '../../../UI/login_style.dart';

class FindAccountScreen extends StatelessWidget {
  const FindAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ 배경색 변경
      backgroundColor: const Color(0xFF20221E),
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

              // ✅ 버튼 크기 & 색상 변경
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/find_id'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E4E4E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '아이디 찾기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/verify_identity'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E4E4E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '비밀번호 찾기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
