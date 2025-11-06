import 'package:flutter/material.dart';

import 'screen/auth/splash_screen.dart';
import 'screen/auth/login.dart';
import 'screen/auth/signup.dart';
import 'screen/auth/find_account.dart';
import 'screen/auth/find_id.dart';
import 'screen/auth/verify_identity.dart';
import 'screen/auth/signup_success.dart';
import 'screen/auth/reset_password.dart';

import 'screen/home/home_screen.dart';
import 'screen/home/today_workout_screen.dart';
import 'screen/home/workout_list_screen.dart';

import 'screen/history/history_screen.dart';
import 'screen/profile/setting_screen.dart';
import 'screen/Inbody/inbody_screen.dart';

import 'screen/video/video_upload_screen.dart';

import 'screen/home/recommend_workout_screen.dart';

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
        '/home': (context) => const HomeScreen(),
        '/history': (context) => const HistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/inbody': (context) => const InbodyScreen(),
        '/workoutList': (_) => const WorkoutListScreen(date: '', workouts: []),
        '/video_upload': (context) => const VideoUploadScreen(),
        '/recommend': (context) => RecommendWorkoutScreen(),
        '/verify_identity': (context) => const VerifyIdentityScreen(),
        '/exercise_category': (context) => TodayWorkoutScreen(
          name: '스쿼트',
          calories: 0,
          date: '',
          ),
      },
    );
  }
}
