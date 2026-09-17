class GameConstants {
  static const Duration arrowAnimationDuration = Duration(milliseconds: 350);
  static const Duration invalidMoveDuration = Duration(milliseconds: 300);
  
  static int getGridSizeForLevel(int level) {
    if (level <= 25) return 5;
    if (level <= 50) return 6;
    if (level <= 75) return 7;
    return 8;
  }
}
