import 'package:flutter/material.dart';

class AppSpacing {
  // Extra Small (XS)
  static const double xs = 4.0;
  // Small (S)
  static const double s = 8.0;
  // Medium (M)
  static const double m = 12.0;
  // Large (L)
  static const double l = 16.0;
  // Extra Large (XL)
  static const double xl = 24.0;
  // Double Extra Large (XXL)
  static const double xxl = 32.0;

  // Predefined EdgeInsets for padding and margins
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingS = EdgeInsets.all(s);
  static const EdgeInsets paddingM = EdgeInsets.all(m);
  static const EdgeInsets paddingL = EdgeInsets.all(l);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);

  // Horizontal padding
  static EdgeInsets paddingHorizontalXS = const EdgeInsets.symmetric(horizontal: xs);
  static EdgeInsets paddingHorizontalS = const EdgeInsets.symmetric(horizontal: s);
  static EdgeInsets paddingHorizontalM = const EdgeInsets.symmetric(horizontal: m);
  static EdgeInsets paddingHorizontalL = const EdgeInsets.symmetric(horizontal: l);
  static EdgeInsets paddingHorizontalXL = const EdgeInsets.symmetric(horizontal: xl);

  // Vertical padding
  static EdgeInsets paddingVerticalXS = const EdgeInsets.symmetric(vertical: xs);
  static EdgeInsets paddingVerticalS = const EdgeInsets.symmetric(vertical: s);
  static EdgeInsets paddingVerticalM = const EdgeInsets.symmetric(vertical: m);
  static EdgeInsets paddingVerticalL = const EdgeInsets.symmetric(vertical: l);
  static EdgeInsets paddingVerticalXL = const EdgeInsets.symmetric(vertical: xl);

  // Gaps (SizedBox for spacing between widgets)
  static const SizedBox gapXS = SizedBox(height: xs, width: xs);
  static const SizedBox gapS = SizedBox(height: s, width: s);
  static const SizedBox gapM = SizedBox(height: m, width: m);
  static const SizedBox gapL = SizedBox(height: l, width: l);
  static const SizedBox gapXL = SizedBox(height: xl, width: xl);
  static const SizedBox gapXXL = SizedBox(height: xxl, width: xxl);
}