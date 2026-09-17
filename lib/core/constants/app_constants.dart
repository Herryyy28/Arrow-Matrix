class AppConstants {
  static const String appName = 'Amaze GO!';
  static const int totalLevels = 1000;
  static const int maxHearts = 3;
  static const int maxUndos = 3;
  static const int maxHints = 3;

  // Storage Keys
  static const String keyCurrentLevel = 'current_level';
  static const String keyHighestLevel = 'highest_level';
  static const String keyBestScore = 'best_score';
  static const String keyLevelStarsPrefix = 'level_stars_';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyMusicEnabled = 'music_enabled';
  static const String keyHapticEnabled = 'haptic_enabled';
  static const String keyDarkMode = 'dark_mode';
  static const String keyDailyStreak = 'daily_streak';
  static const String keyLastDailyDate = 'last_daily_date';

  // Scoring
  static const int scorePerArrow = 10;
  static const int scoreLevelComplete = 100;
  static const int scoreNoMistakesBonus = 50;
  static const int scoreFullHeartsBonus = 50;
}
