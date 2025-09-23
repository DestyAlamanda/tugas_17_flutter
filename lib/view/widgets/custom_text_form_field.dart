import 'package:flutter/material.dart';
import 'package:tugas_17_flutter/utils/app_color.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? prefixIcon; // opsional
  final Widget? suffixIcon; // untuk password

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: prefixIcon, // ditambahkan
        suffixIcon: suffixIcon, // ditambahkan
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.teal),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.teal),
        ),
      ),
      validator: validator,
    );
  }
}
