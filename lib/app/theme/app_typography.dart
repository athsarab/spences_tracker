import 'package:flutter/material.dart';

/// Typography tuned for fast financial scanning.
///
/// Design intent:
/// - Slightly larger body text for readability.
/// - Strong titles for “big numbers first”.
/// - Tight letterSpacing for headings to reduce width.
abstract final class AppTypography {
  static TextTheme applyTo(TextTheme base, {required Brightness brightness}) {
    // Ensure contrast; let ColorScheme handle actual colors.
    return base.copyWith(
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.8,
      ),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 16, height: 1.25),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 15, height: 1.25),
      bodySmall: base.bodySmall?.copyWith(fontSize: 13, height: 1.25),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }
}
