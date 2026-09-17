import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_escape/game/generator/packed_pattern_generator.dart';
import 'package:arrow_escape/game/solver/puzzle_solver.dart';

void main() {
  group('PackedArrowPatternGenerator Tests (75%-90% Coverage & Key Arrow)', () {
    test('Level 1 Packed Pattern Generation (75%-90% Coverage)', () {
      final level = PackedArrowPatternGenerator.generatePackedPatternLevel(1);
      final board = level.createInitialBoard();

      expect(board.arrows.length, greaterThanOrEqualTo(15));
      expect(board.network, isNotNull);
      expect(board.network!.coverageRatio, greaterThanOrEqualTo(0.75));
      expect(board.network!.coverageRatio, lessThanOrEqualTo(0.90));
      expect(PuzzleSolver.isSolvable(board), isTrue);
    });

    test('Level 50 Turning Pattern Family Generation', () {
      final level = PackedArrowPatternGenerator.generatePackedPatternLevel(50);
      final board = level.createInitialBoard();

      expect(board.arrows.length, greaterThanOrEqualTo(20));
      expect(board.network!.patternFamily, equals('interlocking'));
      expect(PuzzleSolver.isSolvable(board), isTrue);
    });

    test('Start Arrow and Key Arrow Assignment', () {
      final level = PackedArrowPatternGenerator.generatePackedPatternLevel(100);
      final board = level.createInitialBoard();

      final startArrow = board.startArrow;
      final keyArrow = board.finalKeyArrow;

      expect(startArrow, isNotNull);
      expect(keyArrow, isNotNull);
      expect(startArrow!.id, isNot(equals(keyArrow!.id)));
      expect(board.canArrowExit(startArrow!), isTrue);
    });

    test('1000+ Level Tier Scaling & Reproducibility', () {
      final level1 = PackedArrowPatternGenerator.generatePackedPatternLevel(500, customSeed: 42000);
      final level2 = PackedArrowPatternGenerator.generatePackedPatternLevel(500, customSeed: 42000);

      expect(level1.initialArrows.length, equals(level2.initialArrows.length));
      expect(level1.network!.coverageRatio, equals(level2.network!.coverageRatio));
      expect(level1.network!.startArrowId, equals(level2.network!.startArrowId));
    });
  });
}
