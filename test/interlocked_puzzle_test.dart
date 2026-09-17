import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_escape/models/arrow_direction.dart';
import 'package:arrow_escape/models/arrow_piece.dart';
import 'package:arrow_escape/models/board.dart';
import 'package:arrow_escape/models/shape_definition.dart';
import 'package:arrow_escape/game/generator/grid_level_generator.dart';
import 'package:arrow_escape/game/solver/puzzle_solver.dart';

void main() {
  group('Interlocked Directional Puzzle System Test Suite', () {
    test('Scenario 1: Two facing arrows blocking each other', () {
      final arrows = [
        ArrowPiece(
          id: 'a1',
          row: 2,
          column: 0,
          direction: ArrowDirection.right,
        ),
        ArrowPiece(
          id: 'a2',
          row: 2,
          column: 4,
          direction: ArrowDirection.left,
        ),
      ];

      final board = Board(rows: 5, cols: 5, arrows: arrows);
      expect(board.canArrowExit(arrows[0]), isFalse);
      expect(board.canArrowExit(arrows[1]), isFalse);
    });

    test('Scenario 2: 3-arrow sequential dependency chain (A -> B -> C)', () {
      final arrows = [
        ArrowPiece(id: 'c', row: 0, column: 2, direction: ArrowDirection.up),
        ArrowPiece(id: 'b', row: 2, column: 2, direction: ArrowDirection.up),
        ArrowPiece(id: 'a', row: 4, column: 2, direction: ArrowDirection.up),
      ];

      final board = Board(rows: 5, cols: 5, arrows: arrows);

      // C is at row 0 facing UP -> Can exit!
      expect(board.canArrowExit(arrows[0]), isTrue);
      // B is at row 2 blocked by C -> Cannot exit!
      expect(board.canArrowExit(arrows[1]), isFalse);
      // A is at row 4 blocked by B -> Cannot exit!
      expect(board.canArrowExit(arrows[2]), isFalse);

      final solution = PuzzleSolver.findSolution(board);
      expect(solution, isNotNull);
      expect(solution, equals(['c', 'b', 'a']));
    });

    test('Scenario 3: Nested path enclosure', () {
      final arrows = [
        ArrowPiece(id: 'inner', row: 2, column: 2, direction: ArrowDirection.right),
        ArrowPiece(id: 'outer', row: 2, column: 4, direction: ArrowDirection.down),
      ];

      final board = Board(rows: 5, cols: 5, arrows: arrows);

      // Inner is blocked by outer
      expect(board.canArrowExit(arrows[0]), isFalse);
      // Outer is free to exit downwards
      expect(board.canArrowExit(arrows[1]), isTrue);
    });

    test('Scenario 4: Crossing paths (orthogonal intersection)', () {
      final arrows = [
        ArrowPiece(id: 'h_arrow', row: 2, column: 0, direction: ArrowDirection.right),
        ArrowPiece(id: 'v_arrow', row: 0, column: 2, direction: ArrowDirection.down),
      ];

      final board = Board(rows: 5, cols: 5, arrows: arrows);

      // Vertical arrow at (0, 2) blocks horizontal arrow at (2, 0)
      expect(board.canArrowExit(arrows[0]), isFalse);
      // Vertical arrow at (0, 2) has clear path down to row 1, but cell (2, 2) is occupied by h_arrow
      expect(board.canArrowExit(arrows[1]), isFalse);
    });

    test('Scenario 5: Branching dependency tree', () {
      final arrows = [
        ArrowPiece(id: 'root', row: 0, column: 2, direction: ArrowDirection.up),
        ArrowPiece(id: 'left_branch', row: 2, column: 2, direction: ArrowDirection.up),
        ArrowPiece(id: 'right_branch', row: 4, column: 2, direction: ArrowDirection.up),
      ];

      final board = Board(rows: 5, cols: 5, arrows: arrows);
      final solution = PuzzleSolver.findSolution(board);
      expect(solution, equals(['root', 'left_branch', 'right_branch']));
    });

    test('Scenario 6: Shared corridor bottleneck', () {
      final arrows = [
        ArrowPiece(id: 'lead', row: 0, column: 1, direction: ArrowDirection.left),
        ArrowPiece(id: 'follower', row: 0, column: 3, direction: ArrowDirection.left),
      ];

      final board = Board(rows: 3, cols: 5, arrows: arrows);
      expect(board.canArrowExit(arrows[0]), isTrue);
      expect(board.canArrowExit(arrows[1]), isFalse);
    });

    test('Scenario 7: Dependency graph depth calculation', () {
      final level = GridLevelGenerator.generateGridLevel(15, customSeed: 12345);
      expect(level.network, isNotNull);
      expect(level.network!.chainDepth, greaterThanOrEqualTo(1));
    });

    test('Scenario 8: Long winding polyline path validation', () {
      final arrow = ArrowPiece(
        id: 'snake_1',
        row: 1,
        column: 1,
        direction: ArrowDirection.right,
        pathPattern: const [ArrowDirection.right, ArrowDirection.down, ArrowDirection.left],
      );

      final board = Board(rows: 5, cols: 5, arrows: [arrow]);
      expect(board.canArrowExit(arrow), isTrue);
    });

    test('Scenario 9: Multi-stage chain reaction solve simulation', () {
      final arrows = [
        ArrowPiece(id: 'a1', row: 0, column: 0, direction: ArrowDirection.up),
        ArrowPiece(id: 'a2', row: 1, column: 0, direction: ArrowDirection.up),
        ArrowPiece(id: 'a3', row: 2, column: 0, direction: ArrowDirection.up),
      ];

      var board = Board(rows: 3, cols: 3, arrows: arrows);
      expect(board.getRemovableArrows().map((a) => a.id), contains('a1'));

      board = PuzzleSolver.simulateMove(board, arrows[0]);
      expect(board.getRemovableArrows().map((a) => a.id), contains('a2'));

      board = PuzzleSolver.simulateMove(board, arrows[1]);
      expect(board.getRemovableArrows().map((a) => a.id), contains('a3'));
    });

    test('Scenario 10: Shape-aware 3D Giraffe interlocked puzzle generation', () {
      final level = GridLevelGenerator.generateGridLevel(1, customSeed: 42);
      expect(level.shapeDefinition, equals(ShapeLibrary.giraffe3D));

      final board = level.createInitialBoard();
      final solution = PuzzleSolver.findSolution(board);
      expect(solution, isNotNull);
      expect(solution!.length, equals(board.arrows.length));
    });
  });
}
