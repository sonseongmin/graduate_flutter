import 'package:flutter/material.dart';

import 'screen/auth/splash_screen.dart';
import 'screen/auth/login.dart';
import 'screen/auth/signup.dart';
import 'screen/auth/find_account.dart';
import 'screen/auth/find_id.dart';
import 'screen/auth/find_password.dart';
import 'screen/auth/signup_success.dart';

import 'screen/home/home_screen.dart';
import 'screen/home/today_workout_screen.dart';
import 'screen/history/history_screen.dart';
import 'screen/profile/setting_screen.dart';
import 'screen/Inbody/inbody_screen.dart';

void main() {
  runApp(const BodyLogApp());
}

class BodyLogApp extends StatelessWidget {
  const BodyLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BodyLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Pretendard',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/signup_success': (context) => const SignupSuccessScreen(),
        '/find_account': (context) => const FindAccountScreen(),
        '/find_id': (context) => const FindIdScreen(),
        '/find_pw': (context) => const FindPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/history': (context) => const HistoryScreen(),
        '/settings': (context) => const SettingsScreen(userName: '홍길동'), // 임시 이름
        '/inbody': (context) => const InbodyScreen(),
      },
    );
  }
}
