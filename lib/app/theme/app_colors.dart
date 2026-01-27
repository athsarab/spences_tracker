import 'package:flutter/material.dart';

/// Color meanings (emotionally friendly):
/// - savings/positive: green
/// - overspend/warning: red
/// - neutral/info: blue
/// - background: soft, low-contrast
abstract final class AppColors {
  static const Color savings = Color(0xFF2ECC71);
  static const Color overspend = Color(0xFFE74C3C);
  static const Color neutral = Color(0xFF2D9CDB);
  static const Color warning = Color(0xFFF2C94C);

  static const Color ink = Color(0xFF0B0F17);
  static const Color surface = Color(0xFFF7F7FB);

  static const Color backgroundDark = Color(0xFF0B1220);
  static const Color backgroundLight = Color(0xFFF7F7FB);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B1220), Color(0xFF101B34), Color(0xFF0B1220)],
  );

  static const LinearGradient backgroundGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF7F7FB), Color(0xFFF0F4FF), Color(0xFFF7F7FB)],
  );

  /// Low-opacity overlay gradient for onboarding/empty states.
  ///
  /// Keeps text readable and avoids busy visuals.
  static LinearGradient onboardingGlow({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        neutral.withValues(alpha: isDark ? 0.16 : 0.10),
        savings.withValues(alpha: isDark ? 0.10 : 0.06),
        warning.withValues(alpha: isDark ? 0.08 : 0.04),
      ],
    );
  }

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x26FFFFFF), Color(0x0FFFFFFF)],
  );
}
