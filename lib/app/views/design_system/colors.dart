import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFFF3008); // Vibrant Orange
  static const Color primarySub = Color(0xFFFF5722); // Slightly darker orange

  // Positive Colors (e.g., for success, veg indicators)
  static const Color positive = Color(0xFF4CAF50); // Green
  static const Color positiveSub = Color(0xFF81C784); // Lighter Green

  // Background Colors
  static const Color backgroundPrimary = Color(0xFFFFFFFF); // White
  static const Color backgroundSecondary = Color(0xFFF0F0F5); // Light Grey

  // Text Colors (Emphasis Levels)
  static const Color textHighestEmphasis = Color(0xFF212121); // Darkest Grey
  static const Color textHighEmphasis = Color(0xFF424242); // Dark Grey
  static const Color textMedEmphasis = Color(0xFF757575); // Medium Grey
  static const Color textLowEmphasis = Color(0xFFB0BEC5); // Light Grey

  // Additional Colors
  static const Color accent = Color(0xFFFFF3E0); // Light Orange for accents
  static const Color error = Color(0xFFD32F2F); // Red for errors
  static const Color warning = Color(0xFFFFA000);

  static var negative; // Amber for warnings
}