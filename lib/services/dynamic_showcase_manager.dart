import '../models/world_model.dart';
import 'storage_service.dart';

enum ShowcasePriority {
  continueLevel,
  dailyChallenge,
  newWorldUnlocked,
  achievementAvailable,
  streakActive,
  nextLevel,
}

class ShowcaseCardData {
  final ShowcasePriority priority;
  final String title;
  final String subtitle;
  final String badgeText;
  final String ctaText;

  const ShowcaseCardData({
    required this.priority,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.ctaText,
  });
}

class DynamicShowcaseManager {
  static ShowcaseCardData resolveCurrentShowcase(StorageService storageService) {
    final currentLvl = storageService.getCurrentLevel();
    final highestUnlocked = storageService.getHighestUnlockedLevel();
    final streak = storageService.getDailyStreak();
    final lastDaily = storageService.getLastDailyDate();
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final currentWorld = WorldModel.getWorldForLevel(currentLvl);

    // 1. Unfinished current level
    if (currentLvl <= highestUnlocked) {
      return ShowcaseCardData(
        priority: ShowcasePriority.continueLevel,
        title: 'Level $currentLvl',
        subtitle: '${currentWorld.name} • ${currentWorld.description}',
        badgeText: 'JOURNEY PROGRESS',
        ctaText: 'CONTINUE LEVEL',
      );
    }

    // 2. Daily Challenge ready
    if (lastDaily != todayStr) {
      return const ShowcaseCardData(
        priority: ShowcasePriority.dailyChallenge,
        title: "Today's Daily Challenge",
        subtitle: 'Solve today\'s puzzle to extend your daily streak!',
        badgeText: 'DAILY PUZZLE',
        ctaText: 'PLAY DAILY',
      );
    }

    // 3. Active Streak
    if (streak > 0) {
      return ShowcaseCardData(
        priority: ShowcasePriority.streakActive,
        title: '$streak Day Streak 🔥',
        subtitle: 'You are on a roll! Keep playing daily puzzles.',
        badgeText: 'STREAK ACTIVE',
        ctaText: 'PLAY NOW',
      );
    }

    // Default: Next Level
    return ShowcaseCardData(
      priority: ShowcasePriority.nextLevel,
      title: 'Level $highestUnlocked Ready',
      subtitle: 'Unlock new puzzles and test your strategic mind.',
      badgeText: 'NEXT LEVEL',
      ctaText: 'START PUZZLE',
    );
  }
}
