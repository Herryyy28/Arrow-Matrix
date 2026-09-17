import 'package:flutter/material.dart';

/// Centralized Design System for Amaze GO!
/// Controls design tokens: Spacing, Radii, Typography, Shadows, Colors.
class AppDesignSystem {
  // Spacing Scale
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;

  // Corner Radii
  static const double radiusSm = 8.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;
  static const double radiusFull = 999.0;

  // Elevation & Shadows
  static List<BoxShadow> softShadow(bool isDark) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> buttonShadow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.35),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  // Primary Color Tokens
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color secondaryCyan = Color(0xFF06B6D4);
  static const Color accentGold = Color(0xFFF59E0B);
  static const Color successGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444);

  // Surface Tokens
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF334155);

  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F5F9);

  // Typography Styles
  static TextStyle titleStyle(BuildContext context, {double size = 22}) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.2,
    );
  }

  static TextStyle bodyStyle(BuildContext context, {double size = 14}) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle subtitleStyle(BuildContext context, {double size = 12}) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade600,
      letterSpacing: 0.8,
    );
  }
}
