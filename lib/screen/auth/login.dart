import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../UI/login_style.dart';
import '../../../UI/input_field.dart';
import '../../../util/token_helper.dart'; // ✅ 추가

const baseUrl = 'http://13.125.219.3';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final idController = TextEditingController();
    final pwController = TextEditingController();

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
                Image.asset(
                  'assets/logo2.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),

                InputField(controller: idController, hint: '아이디'),
                InputField(controller: pwController, hint: '비밀번호', obscure: true),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      final username = idController.text.trim();
                      final password = pwController.text;

                      if (username.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('아이디와 비밀번호를 입력해주세요.')),
                        );
                        return;
                      }

                      final response = await http.post(
                        Uri.parse('$baseUrl/api/login'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({'username': username, 'password': password}),
                      );

                      if (response.statusCode == 200) {
                        final data = jsonDecode(response.body);
                        final accessToken = data['access_token'];
                        final userName = data['name']?.toString() ?? '';

                        // ✅ TokenHelper로 통합 관리 (FlutterSecureStorage + 캐시)
                        await TokenHelper.saveToken(accessToken);

                        // ✅ SharedPreferences는 부가 데이터만 저장
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('user_name', userName);

                        // 기존 인바디 데이터 초기화
                        await prefs.remove('inbody_sex');
                        await prefs.remove('inbody_birth');

                        try {
                          final resp = await http.get(
                            Uri.parse('$baseUrl/api/v1/inbody'),
                            headers: {'Authorization': 'Bearer $accessToken'},
                          );

                          if (resp.statusCode == 200) {
                            final d = jsonDecode(utf8.decode(resp.bodyBytes));
                            final sexApi = (d['sex'] as String?)?.toLowerCase();
                            final birthApi = d['birth_date']?.toString();

                            // 서버 표기 → 로컬 표기 변환
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
                              await prefs.setString(
                                'inbody_birth',
                                birthApi.split('T').first,
                              );
                            }
                          } else {
                            await prefs.remove('inbody_sex');
                            await prefs.remove('inbody_birth');
                          }
                        } catch (_) {
                          await prefs.remove('inbody_sex');
                          await prefs.remove('inbody_birth');
                        }

                        // ✅ 저장 안정화를 위한 짧은 대기 (쓰기 완료 보장)
                        await Future.delayed(const Duration(milliseconds: 300));

                        // 홈으로 이동
                        // ignore: use_build_context_synchronously
                        Navigator.pushReplacementNamed(context, '/home');
                      } else {
                        debugPrint('❌ 로그인 실패: ${response.statusCode} ${response.body}');
                        // ignore: use_build_context_synchronously
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4E4E4E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
                          style: TextStyle(color: Color(0xFF000000)),
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
