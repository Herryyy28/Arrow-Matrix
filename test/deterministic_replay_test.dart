import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_escape/game/generator/grid_level_generator.dart';
import 'package:arrow_escape/game/solver/puzzle_solver.dart';
import 'package:arrow_escape/models/arrow_piece.dart';
import 'package:arrow_escape/models/board.dart';

void main() {
  group('Deterministic Input Replay & State Comparison Test Suite', () {
    test('Deterministic Level Generation by Seed', () {
      final levelA = GridLevelGenerator.generateGridLevel(5, customSeed: 424242);
      final levelB = GridLevelGenerator.generateGridLevel(5, customSeed: 424242);

      expect(levelA.initialArrows.length, equals(levelB.initialArrows.length));
      for (int i = 0; i < levelA.initialArrows.length; i++) {
        expect(levelA.initialArrows[i].id, equals(levelB.initialArrows[i].id));
        expect(levelA.initialArrows[i].row, equals(levelB.initialArrows[i].row));
        expect(levelA.initialArrows[i].column, equals(levelB.initialArrows[i].column));
        expect(levelA.initialArrows[i].direction, equals(levelB.initialArrows[i].direction));
      }
    });

    test('Deterministic Replay Sequence Execution', () {
      final level = GridLevelGenerator.generateGridLevel(1, customSeed: 9999);
      var board = level.createInitialBoard();

      final solution = PuzzleSolver.findSolution(board);
      expect(solution, isNotNull);

      // Replay the exact solution step sequence
      int movesCount = 0;
      for (final arrowId in solution!) {
        final arrow = board.arrows.firstWhere((a) => a.id == arrowId);
        expect(board.canArrowExit(arrow), isTrue);

        board = PuzzleSolver.simulateMove(board, arrow);
        movesCount++;
      }

      expect(movesCount, equals(solution.length));
      expect(board.isCleared, isTrue);
    });
  });
}
