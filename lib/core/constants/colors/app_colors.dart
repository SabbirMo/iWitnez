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
  static const Color black = Colors.black;
  static const Color buttonPrimaryLight = Color(0xFF7C3AED); //#7C3AED
  static const Color forgotPass = Color(0xFFFF9900); //#FF9900
  static const Color onboardingDesc = Color(0xFF6B7280); //#6B7280
  static const Color gray = Color(0xFF4C4C4C); //#4C4C4C
  static const Color fieldColor = Color(0xffDADADA); //#DADADA
  static const Color fieldText = Color(0xff4B4B4B); //#4B4B4B

  static const Color buttonGradientStart = Color(0xFF9124FF); //#9124FF

  //Gradient Color
  static const Gradient onboardingGradient = LinearGradient(
    colors: [buttonGradientStart, primaryBlue],
  );
}
