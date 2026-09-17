import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_escape/models/arrow_direction.dart';
import 'package:arrow_escape/models/arrow_piece.dart';
import 'package:arrow_escape/models/board.dart';
import 'package:arrow_escape/models/puzzle_element.dart';
import 'package:arrow_escape/game/solver/puzzle_solver.dart';
import 'package:arrow_escape/game/generator/level_generator.dart';

void main() {
  group('PuzzleSolver Multi-Element Tests', () {
    test('Identifies solvable board with simple arrows', () {
      final arrows = [
        const ArrowPiece(id: 'a1', row: 0, column: 0, direction: ArrowDirection.up),
        const ArrowPiece(id: 'a2', row: 4, column: 4, direction: ArrowDirection.down),
      ];
      final board = Board(rows: 5, cols: 5, arrows: arrows);

      expect(PuzzleSolver.isSolvable(board), isTrue);
      expect(PuzzleSolver.findSolution(board), isNotNull);
    });

    test('Solves board with Switch opening Gate', () {
      final arrows = [
        const ArrowPiece(id: 'a1', row: 0, column: 0, direction: ArrowDirection.down),
        const ArrowPiece(id: 'a2', row: 2, column: 0, direction: ArrowDirection.down),
      ];
      final switches = [
        const SwitchElement(id: 'sw1', row: 1, col: 0, targetGateId: 'g1'),
      ];
      final gates = [
        const GateElement(id: 'g1', row: 3, col: 0, isOpen: false, linkedSwitchId: 'sw1'),
      ];

      final board = Board(
        rows: 5,
        cols: 5,
        arrows: arrows,
        switches: switches,
        gates: gates,
      );

      final solution = PuzzleSolver.findSolution(board);
      expect(solution, isNotNull);
      expect(solution!.first, equals('a1'));
    });

    test('Hint arrow selection', () {
      final arrows = [
        const ArrowPiece(id: 'a1', row: 0, column: 0, direction: ArrowDirection.up),
      ];
      final board = Board(rows: 5, cols: 5, arrows: arrows);

      final hintId = PuzzleSolver.getHintArrowId(board);
      expect(hintId, equals('a1'));
    });
  });

  group('Hand-Crafted 20 Levels Solvability Tests', () {
    test('All initial 20 levels pass 100% solver validation', () {
      for (int i = 1; i <= 20; i++) {
        final level = LevelGenerator.generateLevel(i);
        expect(level.levelNumber, i);
        final board = level.createInitialBoard();
        expect(PuzzleSolver.isSolvable(board), isTrue, reason: 'Level $i must be solvable');
      }
    });

    test('Generates solvable level for World 7 Master puzzles', () {
      final level95 = LevelGenerator.generateLevel(95);
      expect(level95.levelNumber, 95);
      expect(level95.worldNumber, 7);
      expect(level95.difficultyLabel, equals('MASTER'));
      expect(PuzzleSolver.isSolvable(level95.createInitialBoard()), isTrue);
    });
  });
}
