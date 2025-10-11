// lib/UI/login_style.dart
import 'package:flutter/material.dart';

class LoginStyle {
  /// 배경 색상 (연녹색)
  static const backgroundColor = Color(0xFFA3C99C);

  /// 앱 타이틀 스타일 ("body log")
  static const logoStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  /// 입력 필드 여백
  static const inputMargin = EdgeInsets.symmetric(
    vertical: 6,
    horizontal: 40,
  );

  /// 입력 필드 기본 스타일
  static const inputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
  );

  /// 초록색 버튼 스타일
  static final greenButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF4A774F), // 짙은 녹색
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 12),
    textStyle: const TextStyle(fontSize: 16, color: Colors.white),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
  );
  static const TextStyle resultStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

}
