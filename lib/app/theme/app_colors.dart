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

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B1220), Color(0xFF101B34), Color(0xFF0B1220)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x26FFFFFF), Color(0x0FFFFFFF)],
  );
}
