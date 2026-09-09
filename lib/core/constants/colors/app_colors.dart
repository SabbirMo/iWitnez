import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF5A32FA); //#5A32FA
  static const Color primaryPurple = Color(0xFF8E24AA); //#8E24AA
  static const Color primaryBlue = Color(0xFF1A73E8); //1A73E8
  static const Color accentRed = Color(0xFFFF2424);
  static const Color grayWhite = Color(0xFFE5E7EB); //#E5E7EB
  static const Color textDark = Color(0xFF111827); //#111827
  static const Color textMuted = Color(0xFF505050); //505050
  static const Color white = Colors.white;
  static const Color buttonPrimaryLight = Color(0xFF7C3AED); //#7C3AED

  static const Color onboardingDesc = Color(0xFF6B7280); //#6B7280

  //Gradient Color
  static const Gradient onboardingGradient = LinearGradient(
    colors: [Color(0xFF9124FF), primaryBlue],
  );
}
