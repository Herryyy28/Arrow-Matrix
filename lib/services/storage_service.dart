import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Level Progression
  int getCurrentLevel() => (_prefs.getInt(AppConstants.keyCurrentLevel) ?? 1).clamp(1, AppConstants.totalLevels);
  Future<bool> setCurrentLevel(int level) => _prefs.setInt(AppConstants.keyCurrentLevel, level.clamp(1, AppConstants.totalLevels));

  int getHighestUnlockedLevel() => (_prefs.getInt(AppConstants.keyHighestLevel) ?? 1).clamp(1, AppConstants.totalLevels);
  Future<bool> setHighestUnlockedLevel(int level) async {
    final clampedLevel = level.clamp(1, AppConstants.totalLevels);
    final currentHighest = getHighestUnlockedLevel();
    if (clampedLevel > currentHighest) {
      return await _prefs.setInt(AppConstants.keyHighestLevel, clampedLevel);
    }
    return false;
  }

  int getBestScore() => (_prefs.getInt(AppConstants.keyBestScore) ?? 0).clamp(0, 9999999);
  Future<bool> setBestScore(int score) async {
    final clampedScore = score.clamp(0, 9999999);
    final currentBest = getBestScore();
    if (clampedScore > currentBest) {
      return await _prefs.setInt(AppConstants.keyBestScore, clampedScore);
    }
    return false;
  }

  int getLevelStars(int level) => (_prefs.getInt('${AppConstants.keyLevelStarsPrefix}$level') ?? 0).clamp(0, 3);
  Future<bool> setLevelStars(int level, int stars) async {
    final clampedStars = stars.clamp(0, 3);
    final currentStars = getLevelStars(level);
    if (clampedStars > currentStars) {
      return await _prefs.setInt('${AppConstants.keyLevelStarsPrefix}$level', clampedStars);
    }
    return false;
  }

  // Persistent Puzzle Local Cache
  String? getCachedLevelJson(int levelNumber) => _prefs.getString('cached_level_json_$levelNumber');
  Future<bool> saveCachedLevelJson(int levelNumber, String jsonStr) => _prefs.setString('cached_level_json_$levelNumber', jsonStr);
  bool hasCachedLevelJson(int levelNumber) => _prefs.containsKey('cached_level_json_$levelNumber');

  // Settings
  bool isSoundEnabled() => _prefs.getBool(AppConstants.keySoundEnabled) ?? true;
  Future<bool> setSoundEnabled(bool enabled) => _prefs.setBool(AppConstants.keySoundEnabled, enabled);

  bool isMusicEnabled() => _prefs.getBool(AppConstants.keyMusicEnabled) ?? true;
  Future<bool> setMusicEnabled(bool enabled) => _prefs.setBool(AppConstants.keyMusicEnabled, enabled);

  bool isHapticEnabled() => _prefs.getBool(AppConstants.keyHapticEnabled) ?? true;
  Future<bool> setHapticEnabled(bool enabled) => _prefs.setBool(AppConstants.keyHapticEnabled, enabled);

  bool isDarkMode() => _prefs.getBool(AppConstants.keyDarkMode) ?? false;
  Future<bool> setDarkMode(bool enabled) => _prefs.setBool(AppConstants.keyDarkMode, enabled);

  /// Returns the persisted ThemeMode (system / light / dark).
  ThemeMode getThemeMode() {
    final stored = _prefs.getString('theme_mode') ?? 'system';
    switch (stored) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Persists [mode] and also keeps the legacy dark_mode bool in sync.
  Future<void> setThemeMode(ThemeMode mode) async {
    String stored;
    switch (mode) {
      case ThemeMode.light:
        stored = 'light';
        await setDarkMode(false);
        break;
      case ThemeMode.dark:
        stored = 'dark';
        await setDarkMode(true);
        break;
      default:
        stored = 'system';
        await setDarkMode(false);
    }
    await _prefs.setString('theme_mode', stored);
  }

  String getSelectedTheme() => _prefs.getString('selected_theme_preset') ?? 'classic';
  Future<bool> setSelectedTheme(String themeKey) => _prefs.setString('selected_theme_preset', themeKey);

  bool isReduceMotion() => _prefs.getBool('reduce_motion') ?? false;
  Future<bool> setReduceMotion(bool enabled) => _prefs.setBool('reduce_motion', enabled);

  // Daily Challenge & Streaks
  int getDailyStreak() => _prefs.getInt(AppConstants.keyDailyStreak) ?? 0;
  Future<bool> setDailyStreak(int streak) => _prefs.setInt(AppConstants.keyDailyStreak, streak);

  String getLastDailyDate() => _prefs.getString(AppConstants.keyLastDailyDate) ?? '';
  Future<bool> setLastDailyDate(String dateStr) => _prefs.setString(AppConstants.keyLastDailyDate, dateStr);

  // Detailed Player Statistics
  int getTotalGamesPlayed() => _prefs.getInt('stat_games_played') ?? 0;
  Future<bool> incrementGamesPlayed() => _prefs.setInt('stat_games_played', getTotalGamesPlayed() + 1);

  int getTotalArrowsCleared() => _prefs.getInt('stat_arrows_cleared') ?? 0;
  Future<bool> addArrowsCleared(int count) => _prefs.setInt('stat_arrows_cleared', getTotalArrowsCleared() + count);

  int getPerfectRunsCount() => _prefs.getInt('stat_perfect_runs') ?? 0;
  Future<bool> incrementPerfectRuns() => _prefs.setInt('stat_perfect_runs', getPerfectRunsCount() + 1);

  int getTotalMistakes() => _prefs.getInt('stat_total_mistakes') ?? 0;
  Future<bool> addMistakes(int count) => _prefs.setInt('stat_total_mistakes', getTotalMistakes() + count);

  // Achievements
  List<String> getUnlockedAchievements() => _prefs.getStringList('unlocked_achievements') ?? [];
  Future<bool> unlockAchievement(String achievementId) async {
    final current = getUnlockedAchievements();
    if (!current.contains(achievementId)) {
      current.add(achievementId);
      return await _prefs.setStringList('unlocked_achievements', current);
    }
    return false;
  }

  // Reset Progress
  Future<bool> resetProgress() async {
    await _prefs.clear();
    return true;
  }
}
