import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Base text style using WorkSans font with all required weights
  static TextStyle get _baseTextStyle => GoogleFonts.workSans(
        // Explicitly specify the weights you need
        fontWeight: FontWeight.w400, // Default weight
        // Load additional weights
        textStyle: const TextStyle(
          fontWeight: FontWeight.w400,
        ),
      );

  // Create a method to load WorkSans with specific weights
  static TextStyle _workSansWithWeight(FontWeight weight) {
    return GoogleFonts.workSans(
      fontWeight: weight,
    );
  }

  // Headings
  static TextStyle get heading1 => _workSansWithWeight(FontWeight.w900).copyWith(
        fontSize: 24,
        letterSpacing: 0.2,
      );

  static TextStyle get heading2 => _workSansWithWeight(FontWeight.w900).copyWith(
        fontSize: 19,
        letterSpacing: 0.2,
      );

  static TextStyle get heading3 => _workSansWithWeight(FontWeight.w700).copyWith(
        fontSize: 16,
        letterSpacing: 0.2,
      );

  // Body Text
  static TextStyle get bodyLarge => _workSansWithWeight(FontWeight.w600).copyWith(
        fontSize: 20,
        letterSpacing: 0.1,
      );

  static TextStyle get bodyMedium => _workSansWithWeight(FontWeight.w400).copyWith(
        fontSize: 16,
        letterSpacing: 0.3,
      );

  static TextStyle get bodySmall => _workSansWithWeight(FontWeight.w600).copyWith(
        fontSize: 12,
        letterSpacing: 0.1,
      );

  // Captions
  static TextStyle get caption => _workSansWithWeight(FontWeight.w500).copyWith(
        fontSize: 13,
        letterSpacing: 0.4,
      );

  // Labels (e.g., buttons, tags)
  static TextStyle get labelLarge => _workSansWithWeight(FontWeight.w600).copyWith(
        fontSize: 16,
        letterSpacing: 0.5,
      );

  static TextStyle get labelMedium => _workSansWithWeight(FontWeight.w600).copyWith(
        fontSize: 14,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => _workSansWithWeight(FontWeight.w600).copyWith(
        fontSize: 12,
        letterSpacing: 0.5,
      );
}