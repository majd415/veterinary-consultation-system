import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2ECC71); // Medical Green
  static const Color secondary = Color(0xFF3498DB); // Light Blue
  static const Color background = Color(0xFFF8F9FA);
  static const Color text = Color(0xFF2C3E50);
  static const Color white = Colors.white;
  static const Color error = Color(0xFFE74C3C);
  static const Color success = Color(0xFF2ECC71);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkAppBar = Color(0xFF1A1A1A);
  static const Color darkText = Color(0xFFE0E0E0);
  static const Color darkSubtext = Color(0xFFB0B0B0);

  // Neon/Glow accents
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonBlue = Color(0xFF00FFFF);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF27AE60)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
