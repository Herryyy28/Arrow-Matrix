import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_escape/game/generator/grid_level_generator.dart';
import 'package:arrow_escape/game/solver/puzzle_solver.dart';

void main() {
  group('GridLevelGenerator Tests (Reverse Trajectory Inter-Blocking Puzzle System)', () {
    test('Level 1 Beginner 5x5 Grid Level Generation', () {
      final level = GridLevelGenerator.generateGridLevel(1);
      final board = level.createInitialBoard();

      expect(board.rows, equals(5));
      expect(board.cols, equals(5));
      expect(board.arrows.length, greaterThanOrEqualTo(6));
      expect(PuzzleSolver.isSolvable(board), isTrue);
    });

    test('Level 15 Intermediate 6x6 Grid Level Generation', () {
      final level = GridLevelGenerator.generateGridLevel(15);
      final board = level.createInitialBoard();

      expect(board.rows, equals(6));
      expect(board.cols, equals(6));
      expect(board.arrows.length, greaterThanOrEqualTo(12));
      expect(PuzzleSolver.isSolvable(board), isTrue);
    });

    test('Level 35 Advanced 7x7 Grid Level Generation', () {
      final level = GridLevelGenerator.generateGridLevel(35);
      final board = level.createInitialBoard();

      expect(board.rows, equals(7));
      expect(board.cols, equals(7));
      expect(board.arrows.length, greaterThanOrEqualTo(18));
      expect(PuzzleSolver.isSolvable(board), isTrue);
    });

    test('Level 100 Master 8x8 Grid Level Generation', () {
      final level = GridLevelGenerator.generateGridLevel(100);
      final board = level.createInitialBoard();

      expect(board.rows, equals(8));
      expect(board.cols, equals(8));
      expect(board.arrows.length, greaterThanOrEqualTo(24));
      expect(PuzzleSolver.isSolvable(board), isTrue);
    });

    test('Each level number generates a distinctly different puzzle layout', () {
      final level1 = GridLevelGenerator.generateGridLevel(1);
      final level2 = GridLevelGenerator.generateGridLevel(2);
      final level3 = GridLevelGenerator.generateGridLevel(3);

      expect(level1.title, isNot(equals(level2.title)));
      expect(level1.initialArrows.first.row != level2.initialArrows.first.row ||
             level1.initialArrows.first.column != level2.initialArrows.first.column ||
             level1.initialArrows.first.direction != level2.initialArrows.first.direction, isTrue);
      expect(level2.initialArrows.first.row != level3.initialArrows.first.row ||
             level2.initialArrows.first.column != level3.initialArrows.first.column ||
             level2.initialArrows.first.direction != level3.initialArrows.first.direction, isTrue);
    });

    test('Deterministic Seed Reproducibility Across Restarts', () {
      final levelA = GridLevelGenerator.generateGridLevel(75, customSeed: 12345);
      final levelB = GridLevelGenerator.generateGridLevel(75, customSeed: 12345);

      expect(levelA.rows, equals(levelB.rows));
      expect(levelA.cols, equals(levelB.cols));
      expect(levelA.initialArrows.length, equals(levelB.initialArrows.length));
      expect(levelA.initialArrows.first.direction, equals(levelB.initialArrows.first.direction));
    });
  });
}

