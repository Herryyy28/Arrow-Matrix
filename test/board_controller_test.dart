import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_escape/core/constants/app_constants.dart';
import 'package:arrow_escape/models/arrow_direction.dart';
import 'package:arrow_escape/models/arrow_piece.dart';
import 'package:arrow_escape/models/game_state.dart';
import 'package:arrow_escape/models/level_data.dart';
import 'package:arrow_escape/game/board/board_controller.dart';
import 'package:arrow_escape/game/scoring/score_calculator.dart';
import 'package:arrow_escape/services/storage_service.dart';
import 'package:arrow_escape/services/audio_service.dart';
import 'package:arrow_escape/services/haptic_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;
  late AudioService audioService;
  late HapticService hapticService;
  late BoardController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storageService = StorageService(prefs);
    audioService = AudioService(storageService);
    hapticService = HapticService(storageService);

    controller = BoardController(
      storageService: storageService,
      audioService: audioService,
      hapticService: hapticService,
    );
  });

  tearDown(() {
    controller.dispose();
  });

  group('BoardController Logic Tests', () {
    test('Load level initializes state', () {
      controller.loadLevel(1);
      expect(controller.state, GameStateEnum.playing);
      expect(controller.hearts, AppConstants.maxHearts);
      expect(controller.score, 0);
      expect(controller.undoCount, AppConstants.maxUndos);
      expect(controller.hintCount, AppConstants.maxHints);
      expect(controller.board, isNotNull);
    });

    test('Invalid move reduces heart', () async {
      // Set up a custom level with 2 arrows where arrow1 is blocked by arrow2
      const arrow1 = ArrowPiece(id: 'a1', row: 0, column: 0, direction: ArrowDirection.right);
      const arrow2 = ArrowPiece(id: 'a2', row: 0, column: 1, direction: ArrowDirection.down);
      const customLevel = LevelData(
        levelNumber: 1,
        rows: 5,
        cols: 5,
        initialArrows: [arrow1, arrow2],
      );

      controller.loadLevel(1, customLevel: customLevel);

      // Tap blocked arrow1
      await controller.onArrowTapped(arrow1);

      expect(controller.hearts, 2);
      expect(controller.mistakesCount, 1);
    });

    test('Valid move updates score and supports Undo', () async {
      const arrow1 = ArrowPiece(id: 'a1', row: 0, column: 0, direction: ArrowDirection.up);
      const arrow2 = ArrowPiece(id: 'a2', row: 4, column: 4, direction: ArrowDirection.down);
      const customLevel = LevelData(
        levelNumber: 1,
        rows: 5,
        cols: 5,
        initialArrows: [arrow1, arrow2],
      );

      controller.loadLevel(1, customLevel: customLevel);

      // Tap valid arrow1
      await controller.onArrowTapped(arrow1);

      expect(controller.movesCount, 1);
      expect(controller.score, AppConstants.scorePerArrow);
      expect(controller.canUndo, isTrue);

      // Perform Undo
      controller.performUndo();

      expect(controller.movesCount, 0);
      expect(controller.score, 0);
      expect(controller.undoCount, AppConstants.maxUndos - 1);
    });

    test('ScoreCalculator logic', () {
      final score = ScoreCalculator.calculateFinalScore(
        arrowCount: 5,
        mistakes: 0,
        remainingHearts: 3,
      );
      expect(score, 5 * 10 + 100 + 50 + 50);

      final stars = ScoreCalculator.calculateStars(remainingHearts: 3, mistakes: 0);
      expect(stars, 3);
    });
  });
}
