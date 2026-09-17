import 'package:flutter/material.dart';

enum ThemePreset {
  classic,
  midnight,
  ocean,
  forest,
  sunset,
  minimal,
  neon,
  giraffe,
}

class GameThemeData {
  final ThemePreset preset;
  final String name;
  final Color primary;
  final Color background;
  final Color surface;
  final Color cardColor;
  final Color gridBorder;
  final Color textPrimary;

  const GameThemeData({
    required this.preset,
    required this.name,
    required this.primary,
    required this.background,
    required this.surface,
    required this.cardColor,
    required this.gridBorder,
    required this.textPrimary,
  });

  static const Map<ThemePreset, GameThemeData> themes = {
    ThemePreset.classic: GameThemeData(
      preset: ThemePreset.classic,
      name: 'Classic Indigo',
      primary: Color(0xFF6366F1),
      background: Color(0xFF0F172A),
      surface: Color(0xFF1E293B),
      cardColor: Color(0xFF334155),
      gridBorder: Color(0xFF475569),
      textPrimary: Colors.white,
    ),
    ThemePreset.midnight: GameThemeData(
      preset: ThemePreset.midnight,
      name: 'Midnight Dark',
      primary: Color(0xFF8B5CF6),
      background: Color(0xFF090D16),
      surface: Color(0xFF131C2E),
      cardColor: Color(0xFF1E293B),
      gridBorder: Color(0xFF334155),
      textPrimary: Colors.white,
    ),
    ThemePreset.ocean: GameThemeData(
      preset: ThemePreset.ocean,
      name: 'Ocean Cyan',
      primary: Color(0xFF06B6D4),
      background: Color(0xFF082F49),
      surface: Color(0xFF0C4A6E),
      cardColor: Color(0xFF075985),
      gridBorder: Color(0xFF0284C7),
      textPrimary: Colors.white,
    ),
    ThemePreset.forest: GameThemeData(
      preset: ThemePreset.forest,
      name: 'Emerald Forest',
      primary: Color(0xFF10B981),
      background: Color(0xFF064E3B),
      surface: Color(0xFF047857),
      cardColor: Color(0xFF065F46),
      gridBorder: Color(0xFF059669),
      textPrimary: Colors.white,
    ),
    ThemePreset.sunset: GameThemeData(
      preset: ThemePreset.sunset,
      name: 'Sunset Amber',
      primary: Color(0xFFF59E0B),
      background: Color(0xFF451A03),
      surface: Color(0xFF78350F),
      cardColor: Color(0xFF92400E),
      gridBorder: Color(0xFFB45309),
      textPrimary: Colors.white,
    ),
    ThemePreset.minimal: GameThemeData(
      preset: ThemePreset.minimal,
      name: 'Minimal Light',
      primary: Color(0xFF2563EB),
      background: Color(0xFFF8FAFC),
      surface: Color(0xFFFFFFFF),
      cardColor: Color(0xFFF1F5F9),
      gridBorder: Color(0xFFCBD5E1),
      textPrimary: Color(0xFF0F172A),
    ),
    ThemePreset.neon: GameThemeData(
      preset: ThemePreset.neon,
      name: 'Cyber Neon',
      primary: Color(0xFFEC4899),
      background: Color(0xFF18021E),
      surface: Color(0xFF2E083A),
      cardColor: Color(0xFF4A0E5C),
      gridBorder: Color(0xFFBE185D),
      textPrimary: Colors.white,
    ),
    ThemePreset.giraffe: GameThemeData(
      preset: ThemePreset.giraffe,
      name: '3D Giraffe Obsidian',
      primary: Color(0xFFFFB000),
      background: Color(0xFF050508),
      surface: Color(0xFF12121A),
      cardColor: Color(0xFF1C1C28),
      gridBorder: Color(0xFFFFB000),
      textPrimary: Colors.white,
    ),
  };

  static GameThemeData getTheme(String themeKey) {
    for (final theme in themes.values) {
      if (theme.preset.name == themeKey) return theme;
    }
    return themes[ThemePreset.classic]!;
  }
}
