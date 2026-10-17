import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors (Fitbit-inspired energetic Teal & Cyan)
  static const Color primary = Color(0xFF00B0B9);
  static const Color primaryDark = Color(0xFF007A87);
  static const Color primaryLight = Color(0xFF4DD0E1);
  static const Color accent = Color(0xFF00E5C8);
  static const Color energyOrange = Color(0xFFFF6F59);

  // Backgrounds & Surface (Modern Dark Theme with deep sleek navy/slate)
  static const Color background = Color(0xFF0B132B);
  static const Color surface = Color(0xFF1C2541);
  static const Color surfaceLight = Color(0xFF263252);
  static const Color surfaceElevated = Color(0xFF2E3D67);

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Status & Feedback Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  // Borders & Dividers
  static const Color border = Color(0xFF334155);
  static const Color borderFocused = Color(0xFF00B0B9);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00B0B9), Color(0xFF00E5C8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0B132B), Color(0xFF1C2541)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1C2541), Color(0xFF243054)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient stepsGradient = LinearGradient(
    colors: [Color(0xFF00B0B9), Color(0xFF3A86FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
