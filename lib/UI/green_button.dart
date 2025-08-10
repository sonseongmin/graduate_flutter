import 'package:flutter/material.dart';
import 'login_style.dart';

class GreenButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GreenButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: onPressed,
        style: LoginStyle.greenButtonStyle,
        child: Text(text),
      ),
    );
  }
}