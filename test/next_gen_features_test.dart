import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_escape/models/game_mode.dart';
import 'package:arrow_escape/models/world_model.dart';
import 'package:arrow_escape/models/achievement_model.dart';
import 'package:arrow_escape/services/storage_service.dart';
import 'package:arrow_escape/game/board/board_controller.dart';
import 'package:arrow_escape/services/audio_service.dart';
import 'package:arrow_escape/services/haptic_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Next-Gen Feature Verification Suite', () {
    test('GameMode enum extensions resolve correctly', () {
      expect(GameMode.classic.displayName, 'CLASSIC');
      expect(GameMode.zen.hasHearts, false);
      expect(GameMode.timed.hasTimer, true);
    });

    test('WorldModel maps level numbers to correct worlds', () {
      final w1 = WorldModel.getWorldForLevel(5);
      expect(w1.name, 'WORLD 1: BASIC ARROWS');

      final w3 = WorldModel.getWorldForLevel(30);
      expect(w3.name, 'WORLD 3: LOCKED ARROWS');

      final w6 = WorldModel.getWorldForLevel(120);
      expect(w6.name, 'WORLD 10: MASTER PUZZLES');
    });

    test('AchievementModel contains all required trophies', () {
      final ids = AchievementModel.allAchievements.map((a) => a.id).toList();
      expect(ids.contains('first_step'), true);
      expect(ids.contains('levels_100'), true);
      expect(ids.contains('perfect_run'), true);
      expect(ids.contains('master_world'), true);
    });

    test('StorageService persists statistics and achievement unlocks', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();

      await storage.incrementGamesPlayed();
      expect(storage.getTotalGamesPlayed(), 1);

      await storage.addArrowsCleared(15);
      expect(storage.getTotalArrowsCleared(), 15);

      await storage.unlockAchievement('first_step');
      expect(storage.getUnlockedAchievements().contains('first_step'), true);
    });

    test('BoardController handles guidance long-press state', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final audio = AudioService(storage);
      final haptic = HapticService(storage);

      final controller = BoardController(
        storageService: storage,
        audioService: audio,
        hapticService: haptic,
      );

      controller.loadLevel(1);
      final firstArrow = controller.board!.arrows.first;

      controller.showGuidance(firstArrow);
      expect(controller.guidanceArrowId, firstArrow.id);
      expect(controller.guidancePathClear, isNotNull);

      controller.clearGuidance();
      expect(controller.guidanceArrowId, isNull);
    });
  });
}
