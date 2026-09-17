import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_escape/game/generator/level_generator.dart';
import 'package:arrow_escape/game/generator/network_generator.dart';
import 'package:arrow_escape/game/solver/puzzle_solver.dart';

void main() {
  group('Infinite 1000+ Procedural Network Generator Tests', () {
    test('Tier Configuration Mapping', () {
      final tier1 = ProceduralNetworkGenerator.getTierConfig(10);
      expect(tier1.tierNumber, equals(1));
      expect(tier1.name, equals('FOUNDATION'));

      final tier5 = ProceduralNetworkGenerator.getTierConfig(350);
      expect(tier5.tierNumber, equals(5));
      expect(tier5.name, equals('DEEP DEPENDENCIES'));

      final tier10 = ProceduralNetworkGenerator.getTierConfig(950);
      expect(tier10.tierNumber, equals(10));
      expect(tier10.name, equals('MASTER NETWORKS'));
    });

    test('Generates solvable procedural network levels across all 10 tiers', () {
      final sampleLevels = [1, 50, 100, 250, 500, 750, 1000, 1005];

      for (final lvlNum in sampleLevels) {
        final level = LevelGenerator.generateLevel(lvlNum);
        expect(level.levelNumber, equals(lvlNum));
        expect(level.network, isNotNull, reason: 'Level $lvlNum must contain an ArrowNetwork');

        final board = level.createInitialBoard();
        expect(board.arrows.isNotEmpty, isTrue);
        expect(PuzzleSolver.isSolvable(board), isTrue, reason: 'Level $lvlNum must be 100% solvable');
      }
    });

    test('Seeded generation is 100% deterministic', () {
      final levelA = ProceduralNetworkGenerator.generateNetworkLevel(784, customSeed: 9999);
      final levelB = ProceduralNetworkGenerator.generateNetworkLevel(784, customSeed: 9999);

      expect(levelA.initialArrows.length, equals(levelB.initialArrows.length));
      expect(levelA.network?.nodes.length, equals(levelB.network?.nodes.length));
      for (int i = 0; i < levelA.initialArrows.length; i++) {
        expect(levelA.initialArrows[i].id, equals(levelB.initialArrows[i].id));
        expect(levelA.initialArrows[i].row, equals(levelB.initialArrows[i].row));
        expect(levelA.initialArrows[i].column, equals(levelB.initialArrows[i].column));
        expect(levelA.initialArrows[i].direction, equals(levelB.initialArrows[i].direction));
      }
    });
  });
}
