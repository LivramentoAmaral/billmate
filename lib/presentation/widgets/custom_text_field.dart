import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final int maxLines;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black,
        height: 1.4,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText ?? label,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        labelStyle: TextStyle(
          fontSize: 17,
          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          fontSize: 17,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF1B5E20),
            width: 3,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        // Adicionando suporte para tema escuro
        iconColor: isDark ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32),
        prefixIconColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        suffixIconColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
      ),
    );
  }
}
