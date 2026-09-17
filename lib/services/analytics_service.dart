import 'package:flutter/foundation.dart';

/// Offline-first Analytics Event Tracker.
class AnalyticsService {
  static void logEvent(String eventName, [Map<String, dynamic>? parameters]) {
    if (kDebugMode) {
      debugPrint('[Analytics Event] $eventName ${parameters ?? ""}');
    }
  }

  static void logLevelStarted(int levelNumber) {
    logEvent('level_started', {'level': levelNumber});
  }

  static void logLevelCompleted(int levelNumber, int score, int mistakes) {
    logEvent('level_completed', {
      'level': levelNumber,
      'score': score,
      'mistakes': mistakes,
    });
  }

  static void logLevelFailed(int levelNumber) {
    logEvent('level_failed', {'level': levelNumber});
  }

  static void logHintUsed(int levelNumber) {
    logEvent('hint_used', {'level': levelNumber});
  }

  static void logUndoUsed(int levelNumber) {
    logEvent('undo_used', {'level': levelNumber});
  }

  static void logAchievementUnlocked(String achievementId) {
    logEvent('achievement_unlocked', {'id': achievementId});
  }
}
