import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_escape/models/arrow_direction.dart';
import 'package:arrow_escape/models/arrow_piece.dart';
import 'package:arrow_escape/models/board.dart';
import 'package:arrow_escape/models/shape_definition.dart';
import 'package:arrow_escape/models/pattern_definition.dart';
import 'package:arrow_escape/models/arrow_network.dart';
import 'package:arrow_escape/core/utils/daily_seed.dart';

void main() {
  group('ArrowDirection Tests', () {
    test('Direction vectors', () {
      expect(ArrowDirection.up.dr, -1);
      expect(ArrowDirection.up.dc, 0);

      expect(ArrowDirection.down.dr, 1);
      expect(ArrowDirection.down.dc, 0);

      expect(ArrowDirection.left.dr, 0);
      expect(ArrowDirection.left.dc, -1);

      expect(ArrowDirection.right.dr, 0);
      expect(ArrowDirection.right.dc, 1);
    });

    test('FromString conversion', () {
      expect(ArrowDirection.fromString('UP'), ArrowDirection.up);
      expect(ArrowDirection.fromString('down'), ArrowDirection.down);
      expect(ArrowDirection.fromString('left'), ArrowDirection.left);
      expect(ArrowDirection.fromString('right'), ArrowDirection.right);
    });
  });

  group('Board & Path Detection Tests', () {
    test('Arrow exit check unobstructed', () {
      const arrowRight = ArrowPiece(
        id: '1',
        row: 0,
        column: 0,
        direction: ArrowDirection.right,
      );

      final board = Board(
        rows: 5,
        cols: 5,
        arrows: const [arrowRight],
      );

      expect(board.canArrowExit(arrowRight), isTrue);
    });

    test('Arrow exit check blocked by another arrow', () {
      const arrow1 = ArrowPiece(
        id: '1',
        row: 0,
        column: 0,
        direction: ArrowDirection.right,
      );
      const arrow2 = ArrowPiece(
        id: '2',
        row: 0,
        column: 2,
        direction: ArrowDirection.down,
      );

      final board = Board(
        rows: 5,
        cols: 5,
        arrows: const [arrow1, arrow2],
      );

      // arrow1 is pointing RIGHT towards (0,1), (0,2). (0,2) is occupied by arrow2.
      expect(board.canArrowExit(arrow1), isFalse);
      // arrow2 is pointing DOWN towards (1,2), (2,2), (3,2), (4,2) - all empty!
      expect(board.canArrowExit(arrow2), isTrue);
    });

    test('Board cleared state check', () {
      const arrow1 = ArrowPiece(
        id: '1',
        row: 0,
        column: 0,
        direction: ArrowDirection.up,
        isRemoved: true,
      );

      final board = Board(rows: 5, cols: 5, arrows: const [arrow1]);
      expect(board.isCleared, isTrue);
    });
  });

  group('Daily Seed Tests', () {
    test('Deterministic date seed', () {
      final date = DateTime(2026, 9, 12);
      final seed1 = DailySeed.getSeedFromDate(date);
      final seed2 = DailySeed.getSeedFromDate(date);
      expect(seed1, equals(seed2));
      expect(DailySeed.getDateString(date), '2026-09-12');
    });
  });

  group('ShapeDefinition & ShapeLibrary Tests', () {
    test('ShapeLibrary contains 20 curated shape definitions', () {
      expect(ShapeLibrary.allShapes.length, equals(20));
      for (final shape in ShapeLibrary.allShapes) {
        expect(shape.id, isNotEmpty);
        expect(shape.name, isNotEmpty);
        expect(shape.rows, greaterThan(0));
        expect(shape.cols, greaterThan(0));
        expect(shape.playableMask.length, equals(shape.rows));
      }
    });

    test('ShapeDefinition isPlayable cell boundary checking', () {
      final heart = ShapeLibrary.heart;
      expect(heart.isPlayable(0, 1), isTrue);
      expect(heart.isPlayable(0, 0), isFalse);
      expect(heart.isPlayable(-1, 0), isFalse);
      expect(heart.isPlayable(100, 100), isFalse);
    });
  });

  group('PatternDefinition & PatternLibrary Tests', () {
    test('PatternLibrary contains 20 curated pattern definitions', () {
      expect(PatternLibrary.allPatterns.length, equals(20));
      for (final pat in PatternLibrary.allPatterns) {
        expect(pat.id, isNotEmpty);
        expect(pat.name, isNotEmpty);
        expect(pat.rows, greaterThan(0));
        expect(pat.cols, greaterThan(0));
        expect(pat.playableMask.length, equals(pat.rows));
      }
    });

    test('PatternDefinition isPlayable cell boundary checking', () {
      final pat = PatternLibrary.symbolHeart;
      expect(pat.isPlayable(0, 1), isTrue);
      expect(pat.isPlayable(0, 0), isFalse);
      expect(pat.isPlayable(-1, 0), isFalse);
    });
  });

  group('ArrowNetwork & DependencyGraph Tests', () {
    test('DependencyGraph cycle detection and depth calculation', () {
      final graph = DependencyGraph();
      graph.addEdge('n1', 'n2');
      graph.addEdge('n2', 'n3');
      expect(graph.hasCycle(), isFalse);
      expect(graph.calculateDepth(), equals(3));

      // Introduce circular deadlock cycle
      graph.addEdge('n3', 'n1');
      expect(graph.hasCycle(), isTrue);
    });

    test('ArrowNetwork creation and topological depth evaluation', () {
      const nodes = [
        ArrowNode(id: 'a1', row: 0, col: 0, direction: ArrowDirection.up, connectsToIds: ['a2']),
        ArrowNode(id: 'a2', row: 0, col: 1, direction: ArrowDirection.up, dependsOnIds: ['a1'], connectsToIds: ['a3']),
        ArrowNode(id: 'a3', row: 0, col: 2, direction: ArrowDirection.up, dependsOnIds: ['a2']),
      ];
      final network = ArrowNetwork.fromNodeList(nodes);
      expect(network.chainDepth, equals(3));
      expect(network.graph.hasCycle(), isFalse);
    });
  });
}
