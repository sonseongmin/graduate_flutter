import 'package:flutter/material.dart';
import 'login_style.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;

  const InputField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: LoginStyle.inputMargin,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: LoginStyle.inputDecoration.copyWith(hintText: hint),
      ),
    );
  }
}