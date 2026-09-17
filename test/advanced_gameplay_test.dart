import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_escape/game/generator/level_generator.dart';
import 'package:arrow_escape/game/solver/puzzle_solver.dart';
import 'package:arrow_escape/game/solver/puzzle_validator.dart';
import 'package:arrow_escape/game/solver/difficulty_analyzer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Advanced Gameplay Engine & Validation Suite', () {
    test('All 20 curated hand-crafted levels are 100% valid and solvable', () {
      for (int i = 1; i <= 20; i++) {
        final level = LevelGenerator.generateLevel(i);
        final board = level.createInitialBoard();
        final result = PuzzleValidator.validate(board);

        expect(result.isValid, isTrue,
            reason: 'Level $i failed validation: ${result.reason}');
        expect(result.stepCount, greaterThan(0),
            reason: 'Level $i should require at least 1 move');
      }
    });

    test('Moving Wall level 18 resolves dynamically', () {
      final level18 = LevelGenerator.generateLevel(18);
      final board = level18.createInitialBoard();
      expect(board.movingWalls.isNotEmpty, isTrue);

      final result = PuzzleValidator.validate(board);
      expect(result.isValid, isTrue);
    });

    test('Level 20 Showcase Master Puzzle validates 100% solvable', () {
      final level20 = LevelGenerator.generateLevel(20);
      final board = level20.createInitialBoard();

      expect(board.switches.isNotEmpty, isTrue);
      expect(board.gates.isNotEmpty, isTrue);
      expect(board.keys.isNotEmpty, isTrue);
      expect(board.movingWalls.isNotEmpty, isTrue);

      final result = PuzzleValidator.validate(board);
      expect(result.isValid, isTrue);
      expect(result.difficulty, equals(PuzzleDifficulty.master));
    });

    test('PuzzleValidator detects invalid boards', () {
      final emptyLevel = LevelGenerator.generateLevel(1);
      final emptyBoard = emptyLevel.createInitialBoard().copyWith(arrows: []);
      final result = PuzzleValidator.validate(emptyBoard);

      expect(result.isValid, isFalse);
      expect(result.reason, contains('no arrows'));
    });

    test('PuzzleSolver smart hints return valid target arrows and explanations', () {
      final level = LevelGenerator.generateLevel(12); // Switch & Gate level
      final board = level.createInitialBoard();

      final hint1 = PuzzleSolver.getSmartHint(board, tier: 1);
      expect(hint1, isNotNull);
      expect(hint1!.targetArrowId, isNotEmpty);

      final hint2 = PuzzleSolver.getSmartHint(board, tier: 2);
      expect(hint2, isNotNull);
      expect(hint2!.explanation, isNotEmpty);
    });

    test('DifficultyAnalyzer correctly classifies level difficulties', () {
      final easyLevel = LevelGenerator.generateLevel(1);
      final easyBoard = easyLevel.createInitialBoard();
      final easySolution = PuzzleSolver.findSolution(easyBoard)!;
      final easyDiff = DifficultyAnalyzer.analyze(easyBoard, easySolution);
      expect(easyDiff, equals(PuzzleDifficulty.easy));

      final masterLevel = LevelGenerator.generateLevel(20);
      final masterBoard = masterLevel.createInitialBoard();
      final masterSolution = PuzzleSolver.findSolution(masterBoard)!;
      final masterDiff = DifficultyAnalyzer.analyze(masterBoard, masterSolution);
      expect(masterDiff, equals(PuzzleDifficulty.master));
    });
  });
}
