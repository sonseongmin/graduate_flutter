import 'package:flutter/material.dart';

class HomeStyle {
  static final TextStyle mainTitleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static final TextStyle sectionTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static final TextStyle sectionContentStyle = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );

  static final BoxDecoration boxDecoration = BoxDecoration(
    color: Colors.green.shade100,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2),
        spreadRadius: 2,
        blurRadius: 5,
        offset: Offset(0, 3),
      )
    ],
  );
}
