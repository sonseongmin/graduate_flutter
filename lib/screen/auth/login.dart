import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../UI/login_style.dart';
import '../../../UI/input_field.dart';
import '../../../UI/green_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  static const String baseUrl = 'http://3.39.194.20:3000/api';

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
                  onPressed: () async {
                    final username = idController.text.trim();
                    final password = pwController.text;

                    final response = await http.post(
                      Uri.parse('http://3.39.194.20:3000/api/login'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({'username': username, 'password': password}),
                    );

                    if (response.statusCode == 200) {
                      final data = jsonDecode(response.body);
                      final accessToken = data['access_token'];
                      final userName = data['name']?.toString() ?? '';

                      final prefs = await SharedPreferences.getInstance();

                      // 기본 사용자 정보 저장
                      await prefs.setString('access_token', accessToken);
                      await prefs.setString('user_name', userName);

                      // 1) 이전 계정 잔여 인바디 표시값 초기화
                      await prefs.remove('inbody_sex');
                      await prefs.remove('inbody_birth');

                      // 2) 현재 계정의 인바디를 즉시 1회 동기화하여 캐시 채움
                      try {
                        final resp = await http.get(
                          Uri.parse('http://3.39.194.20:3000/api/v1/inbody'),
                          headers: {'Authorization': 'Bearer $accessToken'},
                        );

                        if (resp.statusCode == 200) {
                          final d = jsonDecode(utf8.decode(resp.bodyBytes));
                          final sexApi = (d['sex'] as String?)?.toLowerCase();
                          final birthApi = d['birth_date']?.toString();

                          // 서버 표기 → 로컬 표기로 매핑
                          final sexLocal = sexApi == 'male'
                              ? '남'
                              : (sexApi == 'female' ? '여' : null);

                          if (sexLocal == null) {
                            await prefs.remove('inbody_sex');
                          } else {
                            await prefs.setString('inbody_sex', sexLocal);
                          }

                          if (birthApi == null || birthApi.isEmpty) {
                            await prefs.remove('inbody_birth');
                          } else {
                            await prefs.setString('inbody_birth', birthApi.split('T').first);
                          }
                        } else {
                          // 조회 실패 → 표시값 비워둠(신규/무데이터 계정 보호)
                          await prefs.remove('inbody_sex');
                          await prefs.remove('inbody_birth');
                        }
                      } catch (_) {
                        // 네트워크 오류 시에도 표시값 비움 유지
                        await prefs.remove('inbody_sex');
                        await prefs.remove('inbody_birth');
                      }

                      // 홈으로 이동
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      debugPrint('❌ 로그인 실패: ${response.statusCode} ${response.body}');
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('로그인 실패'),
                          content: Text('서버 응답: ${response.body}'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('확인'),
                            ),
                          ],
                        ),
                      );
                    }
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
