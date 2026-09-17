import 'dart:math';
import '../../models/arrow_direction.dart';
import '../../models/arrow_piece.dart';
import '../../models/board.dart';
import '../../models/level_data.dart';
import '../../models/puzzle_element.dart';
import '../../models/shape_definition.dart';
import '../../models/pattern_definition.dart';
import '../../models/arrow_network.dart';
import 'network_generator.dart';
import 'packed_pattern_generator.dart';
import 'grid_level_generator.dart';
import '../solver/puzzle_solver.dart';

class LevelGenerator {
  /// Generates a guaranteed-solvable 5x5 to 8x8 grid arrow puzzle for the given level number.
  static LevelData generateLevel(int levelNumber, {int? customSeed}) {
    return GridLevelGenerator.generateGridLevel(
      levelNumber,
      customSeed: customSeed,
    );
  }

  static String _getDifficultyLabel(int levelNumber, int worldNumber) {
    if (worldNumber <= 2) return 'EASY';
    if (worldNumber <= 4) return 'MEDIUM';
    if (worldNumber <= 5) return 'HARD';
    if (worldNumber <= 6) return 'EXPERT';
    return 'MASTER';
  }

  /// 20 Hand-Crafted Curated Connected Network Levels
  static LevelData? _getHandCraftedLevel(int n) {
    switch (n) {
      case 1:
        final nodes1 = const [
          ArrowNode(id: 'a1', row: 0, col: 1, direction: ArrowDirection.up, connectsToIds: ['a2']),
          ArrowNode(id: 'a2', row: 0, col: 5, direction: ArrowDirection.up, dependsOnIds: ['a1'], connectsToIds: ['a3']),
          ArrowNode(id: 'a3', row: 1, col: 0, direction: ArrowDirection.left, dependsOnIds: ['a2']),
          ArrowNode(id: 'a4', row: 1, col: 6, direction: ArrowDirection.right),
          ArrowNode(id: 'a5', row: 5, col: 3, direction: ArrowDirection.down),
        ];
        return LevelData(
          levelNumber: 1,
          rows: ShapeLibrary.heart.rows,
          cols: ShapeLibrary.heart.cols,
          shapeDefinition: ShapeLibrary.heart,
          patternDefinition: PatternLibrary.symbolHeart,
          network: ArrowNetwork.fromNodeList(nodes1),
          worldNumber: 1,
          difficultyLabel: 'EASY',
          title: 'Direct Arrow Chain',
          initialArrows: const [
            ArrowPiece(id: 'a1', row: 0, column: 1, direction: ArrowDirection.up),
            ArrowPiece(id: 'a2', row: 0, column: 5, direction: ArrowDirection.up),
            ArrowPiece(id: 'a3', row: 1, column: 0, direction: ArrowDirection.left),
            ArrowPiece(id: 'a4', row: 1, column: 6, direction: ArrowDirection.right),
            ArrowPiece(id: 'a5', row: 5, column: 3, direction: ArrowDirection.down),
          ],
        );

      case 2:
        final nodes2 = const [
          ArrowNode(id: 'a1', row: 0, col: 3, direction: ArrowDirection.up, connectsToIds: ['a2']),
          ArrowNode(id: 'a2', row: 2, col: 0, direction: ArrowDirection.left, dependsOnIds: ['a1']),
          ArrowNode(id: 'a3', row: 2, col: 6, direction: ArrowDirection.right),
          ArrowNode(id: 'a4', row: 5, col: 0, direction: ArrowDirection.down, connectsToIds: ['a5']),
          ArrowNode(id: 'a5', row: 5, col: 6, direction: ArrowDirection.down, dependsOnIds: ['a4']),
        ];
        return LevelData(
          levelNumber: 2,
          rows: ShapeLibrary.star.rows,
          cols: ShapeLibrary.star.cols,
          shapeDefinition: ShapeLibrary.star,
          network: ArrowNetwork.fromNodeList(nodes2),
          worldNumber: 1,
          difficultyLabel: 'EASY',
          title: 'Dual Parallel Chains',
          initialArrows: const [
            ArrowPiece(id: 'a1', row: 0, column: 3, direction: ArrowDirection.up),
            ArrowPiece(id: 'a2', row: 2, column: 0, direction: ArrowDirection.left),
            ArrowPiece(id: 'a3', row: 2, column: 6, direction: ArrowDirection.right),
            ArrowPiece(id: 'a4', row: 5, column: 0, direction: ArrowDirection.down),
            ArrowPiece(id: 'a5', row: 5, column: 6, direction: ArrowDirection.down),
          ],
        );

      case 3:
        final nodes3 = const [
          ArrowNode(id: 'a1', row: 2, col: 0, direction: ArrowDirection.left, connectsToIds: ['a2']),
          ArrowNode(id: 'a2', row: 1, col: 6, direction: ArrowDirection.right, dependsOnIds: ['a1'], connectsToIds: ['a3']),
          ArrowNode(id: 'a3', row: 3, col: 6, direction: ArrowDirection.right, dependsOnIds: ['a2'], connectsToIds: ['a4']),
          ArrowNode(id: 'a4', row: 0, col: 3, direction: ArrowDirection.up, dependsOnIds: ['a3'], connectsToIds: ['a5']),
          ArrowNode(id: 'a5', row: 4, col: 3, direction: ArrowDirection.down, dependsOnIds: ['a4']),
        ];
        return LevelData(
          levelNumber: 3,
          rows: ShapeLibrary.fish.rows,
          cols: ShapeLibrary.fish.cols,
          shapeDefinition: ShapeLibrary.fish,
          network: ArrowNetwork.fromNodeList(nodes3),
          worldNumber: 1,
          difficultyLabel: 'EASY',
          title: 'Loop Chain',
          initialArrows: const [
            ArrowPiece(id: 'a1', row: 2, column: 0, direction: ArrowDirection.left),
            ArrowPiece(id: 'a2', row: 1, column: 6, direction: ArrowDirection.right),
            ArrowPiece(id: 'a3', row: 3, column: 6, direction: ArrowDirection.right),
            ArrowPiece(id: 'a4', row: 0, column: 3, direction: ArrowDirection.up),
            ArrowPiece(id: 'a5', row: 4, column: 3, direction: ArrowDirection.down),
          ],
        );

      case 4:
        final nodes4 = const [
          ArrowNode(id: 'a1', row: 0, col: 3, direction: ArrowDirection.up, connectsToIds: ['a2']),
          ArrowNode(id: 'a2', row: 0, col: 4, direction: ArrowDirection.up, dependsOnIds: ['a1']),
          ArrowNode(id: 'a3', row: 2, col: 0, direction: ArrowDirection.left, connectsToIds: ['a4']),
          ArrowNode(id: 'a4', row: 4, col: 5, direction: ArrowDirection.right, dependsOnIds: ['a3'], connectsToIds: ['a5']),
          ArrowNode(id: 'a5', row: 5, col: 5, direction: ArrowDirection.down, dependsOnIds: ['a4']),
        ];
        return LevelData(
          levelNumber: 4,
          rows: ShapeLibrary.bird.rows,
          cols: ShapeLibrary.bird.cols,
          shapeDefinition: ShapeLibrary.bird,
          network: ArrowNetwork.fromNodeList(nodes4),
          worldNumber: 1,
          difficultyLabel: 'MEDIUM',
          title: 'Quad Chain Cascade',
          initialArrows: const [
            ArrowPiece(id: 'a1', row: 0, column: 3, direction: ArrowDirection.up),
            ArrowPiece(id: 'a2', row: 0, column: 4, direction: ArrowDirection.up),
            ArrowPiece(id: 'a3', row: 2, column: 0, direction: ArrowDirection.left),
            ArrowPiece(id: 'a4', row: 4, column: 5, direction: ArrowDirection.right),
            ArrowPiece(id: 'a5', row: 5, column: 5, direction: ArrowDirection.down),
          ],
        );

      case 5:
        final nodes5 = const [
          ArrowNode(id: 'a1', row: 0, col: 0, direction: ArrowDirection.up, connectsToIds: ['a2', 'a3'], isBranch: true),
          ArrowNode(id: 'a2', row: 0, col: 1, direction: ArrowDirection.up, dependsOnIds: ['a1']),
          ArrowNode(id: 'a3', row: 1, col: 0, direction: ArrowDirection.left, dependsOnIds: ['a1']),
          ArrowNode(id: 'a4', row: 3, col: 6, direction: ArrowDirection.right, connectsToIds: ['a5']),
          ArrowNode(id: 'a5', row: 5, col: 1, direction: ArrowDirection.down, dependsOnIds: ['a4'], connectsToIds: ['a6']),
          ArrowNode(id: 'a6', row: 5, col: 3, direction: ArrowDirection.down, dependsOnIds: ['a5']),
        ];
        return LevelData(
          levelNumber: 5,
          rows: ShapeLibrary.dog.rows,
          cols: ShapeLibrary.dog.cols,
          shapeDefinition: ShapeLibrary.dog,
          network: ArrowNetwork.fromNodeList(nodes5),
          worldNumber: 1,
          difficultyLabel: 'MEDIUM',
          title: 'Single Branch Network',
          initialArrows: const [
            ArrowPiece(id: 'a1', row: 0, column: 0, direction: ArrowDirection.up),
            ArrowPiece(id: 'a2', row: 0, column: 1, direction: ArrowDirection.up),
            ArrowPiece(id: 'a3', row: 1, column: 0, direction: ArrowDirection.left),
            ArrowPiece(id: 'a4', row: 3, column: 6, direction: ArrowDirection.right),
            ArrowPiece(id: 'a5', row: 5, column: 1, direction: ArrowDirection.down),
            ArrowPiece(id: 'a6', row: 5, column: 3, direction: ArrowDirection.down),
          ],
        );

      case 6:
        final nodes6 = const [
          ArrowNode(id: 'a1', row: 0, col: 0, direction: ArrowDirection.up, connectsToIds: ['a2', 'a3'], isBranch: true),
          ArrowNode(id: 'a2', row: 0, col: 4, direction: ArrowDirection.up, dependsOnIds: ['a1']),
          ArrowNode(id: 'a3', row: 1, col: 0, direction: ArrowDirection.left, dependsOnIds: ['a1']),
          ArrowNode(id: 'a4', row: 1, col: 4, direction: ArrowDirection.right, connectsToIds: ['a5', 'a6'], isBranch: true),
          ArrowNode(id: 'a5', row: 5, col: 1, direction: ArrowDirection.down, dependsOnIds: ['a4']),
          ArrowNode(id: 'a6', row: 5, col: 4, direction: ArrowDirection.right, dependsOnIds: ['a4']),
        ];
        return LevelData(
          levelNumber: 6,
          rows: ShapeLibrary.cat.rows,
          cols: ShapeLibrary.cat.cols,
          shapeDefinition: ShapeLibrary.cat,
          network: ArrowNetwork.fromNodeList(nodes6),
          worldNumber: 1,
          difficultyLabel: 'MEDIUM',
          title: 'Dual Branch Unraveling',
          initialArrows: const [
            ArrowPiece(id: 'a1', row: 0, column: 0, direction: ArrowDirection.up),
            ArrowPiece(id: 'a2', row: 0, column: 4, direction: ArrowDirection.up),
            ArrowPiece(id: 'a3', row: 1, column: 0, direction: ArrowDirection.left),
            ArrowPiece(id: 'a4', row: 1, column: 4, direction: ArrowDirection.right),
            ArrowPiece(id: 'a5', row: 5, column: 1, direction: ArrowDirection.down),
            ArrowPiece(id: 'a6', row: 5, column: 4, direction: ArrowDirection.right),
          ],
        );

      case 7:
        final nodes7 = const [
          ArrowNode(id: 'a1', row: 0, col: 1, direction: ArrowDirection.up, connectsToIds: ['a3']),
          ArrowNode(id: 'a2', row: 0, col: 5, direction: ArrowDirection.up, connectsToIds: ['a3']),
          ArrowNode(id: 'a3', row: 1, col: 0, direction: ArrowDirection.left, dependsOnIds: ['a1', 'a2'], connectsToIds: ['a4', 'a5'], isMerge: true, isBranch: true),
          ArrowNode(id: 'a4', row: 1, col: 6, direction: ArrowDirection.right, dependsOnIds: ['a3']),
          ArrowNode(id: 'a5', row: 6, col: 3, direction: ArrowDirection.down, dependsOnIds: ['a3']),
        ];
        return LevelData(
          levelNumber: 7,
          rows: ShapeLibrary.flower.rows,
          cols: ShapeLibrary.flower.cols,
          shapeDefinition: ShapeLibrary.flower,
          network: ArrowNetwork.fromNodeList(nodes7),
          worldNumber: 1,
          difficultyLabel: 'MEDIUM',
          title: 'Merge & Diverge Network',
          initialArrows: const [
            ArrowPiece(id: 'a1', row: 0, column: 1, direction: ArrowDirection.up),
            ArrowPiece(id: 'a2', row: 0, column: 5, direction: ArrowDirection.up),
            ArrowPiece(id: 'a3', row: 1, column: 0, direction: ArrowDirection.left),
            ArrowPiece(id: 'a4', row: 1, column: 6, direction: ArrowDirection.right),
            ArrowPiece(id: 'a5', row: 6, column: 3, direction: ArrowDirection.down),
          ],
        );

      case 8:
        final nodes8 = const [
          ArrowNode(id: 'a1', row: 0, col: 3, direction: ArrowDirection.up, connectsToIds: ['a2']),
          ArrowNode(id: 'a2', row: 3, col: 0, direction: ArrowDirection.left, dependsOnIds: ['a1']),
          ArrowNode(id: 'a3', row: 3, col: 6, direction: ArrowDirection.right, connectsToIds: ['a4']),
          ArrowNode(id: 'a4', row: 6, col: 3, direction: ArrowDirection.down, dependsOnIds: ['a3']),
        ];
        return LevelData(
          levelNumber: 8,
          rows: ShapeLibrary.tree.rows,
          cols: ShapeLibrary.tree.cols,
          shapeDefinition: ShapeLibrary.tree,
          network: ArrowNetwork.fromNodeList(nodes8),
          worldNumber: 1,
          difficultyLabel: 'MEDIUM',
          title: 'Crossing Paths Network',
          initialArrows: const [
            ArrowPiece(id: 'a1', row: 0, column: 3, direction: ArrowDirection.up),
            ArrowPiece(id: 'a2', row: 3, column: 0, direction: ArrowDirection.left),
            ArrowPiece(id: 'a3', row: 3, column: 6, direction: ArrowDirection.right),
            ArrowPiece(id: 'a4', row: 6, column: 3, direction: ArrowDirection.down),
          ],
        );

      case 9:
        final nodes9 = const [
          ArrowNode(id: 'a1', row: 0, col: 3, direction: ArrowDirection.up, connectsToIds: ['a2']),
          ArrowNode(id: 'a2', row: 3, col: 0, direction: ArrowDirection.left, dependsOnIds: ['a1']),
          ArrowNode(id: 'a3', row: 3, col: 6, direction: ArrowDirection.right, connectsToIds: ['a4']),
          ArrowNode(id: 'a4', row: 6, col: 1, direction: ArrowDirection.down, dependsOnIds: ['a3']),
          ArrowNode(id: 'a5', row: 6, col: 5, direction: ArrowDirection.down),
        ];
        return LevelData(
          levelNumber: 9,
          rows: ShapeLibrary.house.rows,
          cols: ShapeLibrary.house.cols,
          shapeDefinition: ShapeLibrary.house,
          network: ArrowNetwork.fromNodeList(nodes9),
          worldNumber: 1,
          difficultyLabel: 'MEDIUM',
          title: 'House & Gate Network',
          initialArrows: const [
            ArrowPiece(id: 'a1', row: 0, column: 3, direction: ArrowDirection.up),
            ArrowPiece(id: 'a2', row: 3, column: 0, direction: ArrowDirection.left),
            ArrowPiece(id: 'a3', row: 3, column: 6, direction: ArrowDirection.right),
            ArrowPiece(id: 'a4', row: 6, column: 1, direction: ArrowDirection.down),
            ArrowPiece(id: 'a5', row: 6, column: 5, direction: ArrowDirection.down),
          ],
          initialSwitches: const [
            SwitchElement(id: 'sw9', row: 4, col: 3, targetGateId: 'g9'),
          ],
          initialGates: const [
            GateElement(id: 'g9', row: 6, col: 3, isOpen: false, linkedSwitchId: 'sw9'),
          ],
        );

      case 10:
        final nodes10 = const [
          ArrowNode(id: 'a1', row: 0, col: 3, direction: ArrowDirection.up, connectsToIds: ['a2']),
          ArrowNode(id: 'a2', row: 2, col: 0, direction: ArrowDirection.left, dependsOnIds: ['a1'], connectsToIds: ['a3']),
          ArrowNode(id: 'a3', row: 2, col: 6, direction: ArrowDirection.right, dependsOnIds: ['a2']),
          ArrowNode(id: 'a4', row: 4, col: 1, direction: ArrowDirection.down, connectsToIds: ['a5']),
          ArrowNode(id: 'a5', row: 4, col: 5, direction: ArrowDirection.down, dependsOnIds: ['a4']),
        ];
        return LevelData(
          levelNumber: 10,
          rows: ShapeLibrary.car.rows,
          cols: ShapeLibrary.car.cols,
          shapeDefinition: ShapeLibrary.car,
          network: ArrowNetwork.fromNodeList(nodes10),
          worldNumber: 1,
          difficultyLabel: 'MEDIUM',
          title: '3D Weave Crossing',
          initialArrows: const [
            ArrowPiece(id: 'a1', row: 0, column: 3, direction: ArrowDirection.up),
            ArrowPiece(id: 'a2', row: 2, column: 0, direction: ArrowDirection.left),
            ArrowPiece(id: 'a3', row: 2, column: 6, direction: ArrowDirection.right),
            ArrowPiece(id: 'a4', row: 4, column: 1, direction: ArrowDirection.down),
            ArrowPiece(id: 'a5', row: 4, column: 5, direction: ArrowDirection.down),
          ],
        );

      case 11:
        final nodes11 = const [
          ArrowNode(id: 'a1', row: 0, col: 2, direction: ArrowDirection.up, connectsToIds: ['a2']),
          ArrowNode(id: 'a2', row: 4, col: 0, direction: ArrowDirection.left, dependsOnIds: ['a1'], connectsToIds: ['a3']),
          ArrowNode(id: 'a3', row: 4, col: 4, direction: ArrowDirection.right, dependsOnIds: ['a2'], connectsToIds: ['a4']),
          ArrowNode(id: 'a4', row: 5, col: 2, direction: ArrowDirection.down, dependsOnIds: ['a3'], connectsToIds: ['a5']),
          ArrowNode(id: 'a5', row: 5, col: 0, direction: ArrowDirection.down, dependsOnIds: ['a4'], connectsToIds: ['a6']),
          ArrowNode(id: 'a6', row: 5, col: 4, direction: ArrowDirection.down, dependsOnIds: ['a5']),
        ];
        return LevelData(
          levelNumber: 11,
          rows: ShapeLibrary.rocket.rows,
          cols: ShapeLibrary.rocket.cols,
          shapeDefinition: ShapeLibrary.rocket,
          network: ArrowNetwork.fromNodeList(nodes11),
          worldNumber: 2,
          difficultyLabel: 'HARD',
          title: 'Deep Stack Dependency',
          initialArrows: const [
            ArrowPiece(id: 'a1', row: 0, column: 2, direction: ArrowDirection.up),
            ArrowPiece(id: 'a2', row: 4, column: 0, direction: ArrowDirection.left),
            ArrowPiece(id: 'a3', row: 4, column: 4, direction: ArrowDirection.right),
            ArrowPiece(id: 'a4', row: 5, column: 2, direction: ArrowDirection.down),
            ArrowPiece(id: 'a5', row: 5, column: 0, direction: ArrowDirection.down),
            ArrowPiece(id: 'a6', row: 5, column: 4, direction: ArrowDirection.down),
          ],
        );

      case 12:
        final nodes12 = const [
          ArrowNode(id: 'a1', row: 0, col: 2, direction: ArrowDirection.up, connectsToIds: ['a2', 'a3'], isBranch: true),
          ArrowNode(id: 'a2', row: 1, col: 0, direction: ArrowDirection.left, dependsOnIds: ['a1'], connectsToIds: ['a4']),
          ArrowNode(id: 'a3', row: 1, col: 4, direction: ArrowDirection.right, dependsOnIds: ['a1'], connectsToIds: ['a5', 'a6'], isBranch: true),
          ArrowNode(id: 'a4', row: 5, col: 3, direction: ArrowDirection.right, dependsOnIds: ['a2']),
          ArrowNode(id: 'a5', row: 7, col: 3, direction: ArrowDirection.right, dependsOnIds: ['a3']),
          ArrowNode(id: 'a6', row: 7, col: 2, direction: ArrowDirection.down, dependsOnIds: ['a3']),
        ];
        return LevelData(
          levelNumber: 12,
          rows: ShapeLibrary.key.rows,
          cols: ShapeLibrary.key.cols,
          shapeDefinition: ShapeLibrary.key,
          network: ArrowNetwork.fromNodeList(nodes12),
          worldNumber: 2,
          difficultyLabel: 'HARD',
          title: 'Recursive Node Tree',
          initialArrows: const [
            ArrowPiece(id: 'a1', row: 0, column: 2, direction: ArrowDirection.up),
            ArrowPiece(id: 'a2', row: 1, column: 0, direction: ArrowDirection.left),
            ArrowPiece(id: 'a3', row: 1, column: 4, direction: ArrowDirection.right),
            ArrowPiece(id: 'a4', row: 5, column: 3, direction: ArrowDirection.right),
            ArrowPiece(id: 'a5', row: 7, column: 3, direction: ArrowDirection.right),
            ArrowPiece(id: 'a6', row: 7, column: 2, direction: ArrowDirection.down),
          ],
        );

      case 13:
        final nodes13 = const [
          ArrowNode(id: 'a1', row: 0, col: 0, direction: ArrowDirection.up, connectsToIds: ['a2']),
          ArrowNode(id: 'a2', row: 0, col: 2, direction: ArrowDirection.up, dependsOnIds: ['a1'], connectsToIds: ['a3']),
          ArrowNode(id: 'a3', row: 0, col: 4, direction: ArrowDirection.up, dependsOnIds: ['a2'], connectsToIds: ['a4']),
          ArrowNode(id: 'a4', row: 4, col: 0, direction: ArrowDirection.left, dependsOnIds: ['a3'], connectsToIds: ['a5']),
          ArrowNode(id: 'a5', row: 4, col: 4, direction: ArrowDirection.right, dependsOnIds: ['a4']),
        ];
        return LevelData(
          levelNumber: 13,
          rows: ShapeLibrary.crown.rows,
          cols: ShapeLibrary.crown.cols,
          shapeDefinition: ShapeLibrary.crown,
          network: ArrowNetwork.fromNodeList(nodes13),
          worldNumber: 2,
          difficultyLabel: 'HARD',
          title: '12-Node Interlock',
          initialArrows: const [
            ArrowPiece(id: 'a1', row: 0, column: 0, direction: ArrowDirection.up),
            ArrowPiece(id: 'a2', row: 0, column: 2, direction: ArrowDirection.up),
            ArrowPiece(id: 'a3', row: 0, column: 4, direction: ArrowDirection.up),
            ArrowPiece(id: 'a4', row: 4, column: 0, direction: ArrowDirection.left),
            ArrowPiece(id: 'a5', row: 4, column: 4, direction: ArrowDirection.right),
          ],
        );

      case 14:
        final nodes14 = const [
          ArrowNode(id: 'a1', row: 0, col: 4, direction: ArrowDirection.up, connectsToIds: ['a2']),
          ArrowNode(id: 'a2', row: 0, col: 3, direction: ArrowDirection.up, dependsOnIds: ['a1'], connectsToIds: ['a3']),
          ArrowNode(id: 'a3', row: 5, col: 0, direction: ArrowDirection.left, dependsOnIds: ['a2'], connectsToIds: ['a4']),
          ArrowNode(id: 'a4', row: 6, col: 1, direction: ArrowDirection.down, dependsOnIds: ['a3'], connectsToIds: ['a5']),
          ArrowNode(id: 'a5', row: 6, col: 2, direction: ArrowDirection.down, dependsOnIds: ['a4']),
        ];
        return LevelData(
          levelNumber: 14,
          rows: ShapeLibrary.musicNote.rows,
          cols: ShapeLibrary.musicNote.cols,
          shapeDefinition: ShapeLibrary.musicNote,
          network: ArrowNetwork.fromNodeList(nodes14),
          worldNumber: 2,
          difficultyLabel: 'HARD',
          title: 'Switch Gate Chain',
          initialArrows: const [
            ArrowPiece(id: 'a1', row: 0, column: 4, direction: ArrowDirection.up),
            ArrowPiece(id: 'a2', row: 0, column: 3, direction: ArrowDirection.up),
            ArrowPiece(id: 'a3', row: 5, column: 0, direction: ArrowDirection.left),
            ArrowPiece(id: 'a4', row: 6, column: 1, direction: ArrowDirection.down),
            ArrowPiece(id: 'a5', row: 6, column: 2, direction: ArrowDirection.down),
          ],
        );

      case 15:
        final nodes15 = const [
          ArrowNode(id: 'a1', row: 0, col: 2, direction: ArrowDirection.up, connectsToIds: ['a2']),
          ArrowNode(id: 'a2', row: 4, col: 0, direction: ArrowDirection.down, dependsOnIds: ['a1'], connectsToIds: ['a3']),
          ArrowNode(id: 'a3', row: 4, col: 4, direction: ArrowDirection.down, dependsOnIds: ['a2'], connectsToIds: ['a4']),
          ArrowNode(id: 'a4', row: 2, col: 2, direction: ArrowDirection.right, dependsOnIds: ['a3']),
        ];
        return LevelData(
          levelNumber: 15,
          rows: ShapeLibrary.letterA.rows,
          cols: ShapeLibrary.letterA.cols,
          shapeDefinition: ShapeLibrary.letterA,
          network: ArrowNetwork.fromNodeList(nodes15),
          worldNumber: 2,
          difficultyLabel: 'HARD',
          title: 'Dual Gate Relay',
          initialArrows: const [
            ArrowPiece(id: 'a1', row: 0, column: 2, direction: ArrowDirection.up),
            ArrowPiece(id: 'a2', row: 4, column: 0, direction: ArrowDirection.down),
            ArrowPiece(id: 'a3', row: 4, column: 4, direction: ArrowDirection.down),
            ArrowPiece(id: 'a4', row: 2, column: 2, direction: ArrowDirection.right),
          ],
        );

      case 16:
        final nodes16 = const [
          ArrowNode(id: 'a1', row: 0, col: 0, direction: ArrowDirection.up, connectsToIds: ['a2']),
          ArrowNode(id: 'a2', row: 0, col: 4, direction: ArrowDirection.up, dependsOnIds: ['a1'], connectsToIds: ['a5']),
          ArrowNode(id: 'a3', row: 4, col: 0, direction: ArrowDirection.down, connectsToIds: ['a4']),
          ArrowNode(id: 'a4', row: 4, col: 4, direction: ArrowDirection.down, dependsOnIds: ['a3'], connectsToIds: ['a5']),
          ArrowNode(id: 'a5', row: 2, col: 2, direction: ArrowDirection.down, dependsOnIds: ['a2', 'a4'], isMerge: true),
        ];
        return LevelData(
          levelNumber: 16,
          rows: ShapeLibrary.letterM.rows,
          cols: ShapeLibrary.letterM.cols,
          shapeDefinition: ShapeLibrary.letterM,
          network: ArrowNetwork.fromNodeList(nodes16),
          worldNumber: 2,
          difficultyLabel: 'HARD',
          title: 'Key Lock Network',
          initialArrows: const [
            ArrowPiece(id: 'a1', row: 0, column: 0, direction: ArrowDirection.up),
            ArrowPiece(id: 'a2', row: 0, column: 4, direction: ArrowDirection.up),
            ArrowPiece(id: 'a3', row: 4, column: 0, direction: ArrowDirection.down),
            ArrowPiece(id: 'a4', row: 4, column: 4, direction: ArrowDirection.down),
            ArrowPiece(id: 'a5', row: 2, column: 2, direction: ArrowDirection.down),
          ],
        );

      case 17:
        final nodes17 = const [
          ArrowNode(id: 'a1', row: 0, col: 0, direction: ArrowDirection.up, connectsToIds: ['a2']),
          ArrowNode(id: 'a2', row: 0, col: 6, direction: ArrowDirection.up, dependsOnIds: ['a1'], connectsToIds: ['a5']),
          ArrowNode(id: 'a3', row: 6, col: 0, direction: ArrowDirection.down, connectsToIds: ['a4']),
          ArrowNode(id: 'a4', row: 6, col: 6, direction: ArrowDirection.down, dependsOnIds: ['a3'], connectsToIds: ['a6']),
          ArrowNode(id: 'a5', row: 0, col: 3, direction: ArrowDirection.up, dependsOnIds: ['a2']),
          ArrowNode(id: 'a6', row: 6, col: 3, direction: ArrowDirection.down, dependsOnIds: ['a4']),
        ];
        return LevelData(
          levelNumber: 17,
          rows: ShapeLibrary.butterfly.rows,
          cols: ShapeLibrary.butterfly.cols,
          shapeDefinition: ShapeLibrary.butterfly,
          network: ArrowNetwork.fromNodeList(nodes17),
          worldNumber: 2,
          difficultyLabel: 'EXPERT',
          title: 'Portal Connected Web',
          initialArrows: const [
            ArrowPiece(id: 'a1', row: 0, column: 0, direction: ArrowDirection.up),
            ArrowPiece(id: 'a2', row: 0, column: 6, direction: ArrowDirection.up),
            ArrowPiece(id: 'a3', row: 6, column: 0, direction: ArrowDirection.down),
            ArrowPiece(id: 'a4', row: 6, column: 6, direction: ArrowDirection.down),
            ArrowPiece(id: 'a5', row: 0, column: 3, direction: ArrowDirection.up),
            ArrowPiece(id: 'a6', row: 6, column: 3, direction: ArrowDirection.down),
          ],
        );

      case 18:
        final nodes18 = const [
          ArrowNode(id: 'a1', row: 0, col: 2, direction: ArrowDirection.up, connectsToIds: ['a2']),
          ArrowNode(id: 'a2', row: 1, col: 0, direction: ArrowDirection.left, dependsOnIds: ['a1'], connectsToIds: ['a3']),
          ArrowNode(id: 'a3', row: 1, col: 4, direction: ArrowDirection.right, dependsOnIds: ['a2'], connectsToIds: ['a4']),
          ArrowNode(id: 'a4', row: 5, col: 0, direction: ArrowDirection.down, dependsOnIds: ['a3'], connectsToIds: ['a5']),
          ArrowNode(id: 'a5', row: 5, col: 4, direction: ArrowDirection.down, dependsOnIds: ['a4']),
        ];
        return LevelData(
          levelNumber: 18,
          rows: ShapeLibrary.lock.rows,
          cols: ShapeLibrary.lock.cols,
          shapeDefinition: ShapeLibrary.lock,
          network: ArrowNetwork.fromNodeList(nodes18),
          worldNumber: 2,
          difficultyLabel: 'EXPERT',
          title: 'Moving Wall Trap Network',
          initialArrows: const [
            ArrowPiece(id: 'a1', row: 0, column: 2, direction: ArrowDirection.up),
            ArrowPiece(id: 'a2', row: 1, column: 0, direction: ArrowDirection.left),
            ArrowPiece(id: 'a3', row: 1, column: 4, direction: ArrowDirection.right),
            ArrowPiece(id: 'a4', row: 5, column: 0, direction: ArrowDirection.down),
            ArrowPiece(id: 'a5', row: 5, column: 4, direction: ArrowDirection.down),
          ],
        );

      case 19:
        final nodes19 = const [
          ArrowNode(id: 'a1', row: 0, col: 2, direction: ArrowDirection.up, connectsToIds: ['a2']),
          ArrowNode(id: 'a2', row: 0, col: 6, direction: ArrowDirection.up, dependsOnIds: ['a1'], connectsToIds: ['a3']),
          ArrowNode(id: 'a3', row: 2, col: 0, direction: ArrowDirection.left, dependsOnIds: ['a2'], connectsToIds: ['a4']),
          ArrowNode(id: 'a4', row: 2, col: 8, direction: ArrowDirection.right, dependsOnIds: ['a3'], connectsToIds: ['a5']),
          ArrowNode(id: 'a5', row: 6, col: 4, direction: ArrowDirection.down, dependsOnIds: ['a4']),
        ];
        return LevelData(
          levelNumber: 19,
          rows: ShapeLibrary.overlappingDual.rows,
          cols: ShapeLibrary.overlappingDual.cols,
          shapeDefinition: ShapeLibrary.overlappingDual,
          network: ArrowNetwork.fromNodeList(nodes19),
          worldNumber: 2,
          difficultyLabel: 'EXPERT',
          title: 'Chain Cascade Reaction',
          initialArrows: const [
            ArrowPiece(id: 'a1', row: 0, column: 2, direction: ArrowDirection.up),
            ArrowPiece(id: 'a2', row: 0, column: 6, direction: ArrowDirection.up),
            ArrowPiece(id: 'a3', row: 2, column: 0, direction: ArrowDirection.left),
            ArrowPiece(id: 'a4', row: 2, column: 8, direction: ArrowDirection.right),
            ArrowPiece(id: 'a5', row: 6, column: 4, direction: ArrowDirection.down),
          ],
        );

      case 20:
        final nodes20 = const [
          ArrowNode(id: 'a1', row: 0, col: 4, direction: ArrowDirection.up, connectsToIds: ['a2', 'a3'], isBranch: true),
          ArrowNode(id: 'a2', row: 2, col: 0, direction: ArrowDirection.left, dependsOnIds: ['a1'], connectsToIds: ['a4']),
          ArrowNode(id: 'a3', row: 2, col: 7, direction: ArrowDirection.right, dependsOnIds: ['a1'], connectsToIds: ['a5']),
          ArrowNode(id: 'a4', row: 6, col: 0, direction: ArrowDirection.left, dependsOnIds: ['a2'], connectsToIds: ['a6']),
          ArrowNode(id: 'a5', row: 6, col: 7, direction: ArrowDirection.right, dependsOnIds: ['a3'], connectsToIds: ['a7']),
          ArrowNode(id: 'a6', row: 7, col: 0, direction: ArrowDirection.down, dependsOnIds: ['a4']),
          ArrowNode(id: 'a7', row: 7, col: 7, direction: ArrowDirection.down, dependsOnIds: ['a5']),
        ];
        return LevelData(
          levelNumber: 20,
          rows: ShapeLibrary.masterComposite.rows,
          cols: ShapeLibrary.masterComposite.cols,
          shapeDefinition: ShapeLibrary.masterComposite,
          network: ArrowNetwork.fromNodeList(nodes20),
          worldNumber: 2,
          difficultyLabel: 'MASTER',
          title: 'MASTER NETWORK',
          initialArrows: const [
            ArrowPiece(id: 'a1', row: 0, column: 4, direction: ArrowDirection.up),
            ArrowPiece(id: 'a2', row: 2, column: 0, direction: ArrowDirection.left),
            ArrowPiece(id: 'a3', row: 2, column: 7, direction: ArrowDirection.right),
            ArrowPiece(id: 'a4', row: 6, column: 0, direction: ArrowDirection.left),
            ArrowPiece(id: 'a5', row: 6, column: 7, direction: ArrowDirection.right),
            ArrowPiece(id: 'a6', row: 7, column: 0, direction: ArrowDirection.down),
            ArrowPiece(id: 'a7', row: 7, column: 7, direction: ArrowDirection.down),
          ],
        );
    }
    return null;
  }

  static LevelData _tryGenerateWorldLevel({
    required int levelNumber,
    required ShapeDefinition shape,
    required int worldNumber,
    required String difficultyLabel,
    required Random rng,
  }) {
    final playableCount = shape.playableMask.fold<int>(
        0, (acc, row) => acc + row.where((cell) => cell).length);
    final targetArrowCount = min(playableCount, max(3, (playableCount * 0.45).toInt()));

    final arrows = _generateReverseArrows(shape, targetArrowCount, rng);
    final gates = <GateElement>[];
    final switches = <SwitchElement>[];
    final keys = <KeyElement>[];
    final portals = <PortalElement>[];
    final iceCells = <IceCell>[];
    final obstacles = <ObstacleElement>[];

    if (worldNumber >= 3) {
      if (arrows.isNotEmpty) {
        final lockIdx = rng.nextInt(arrows.length);
        final keyPos = _findFreeShapeCell(shape, arrows, obstacles, rng);
        if (keyPos != null) {
          final lockId = 'lock_$levelNumber';
          arrows[lockIdx] = arrows[lockIdx].copyWith(isLocked: true, lockId: lockId);
          keys.add(KeyElement(
            id: 'key_1',
            row: keyPos.x,
            col: keyPos.y,
            targetLockId: lockId,
          ));
        }
      }
    }

    if (worldNumber >= 4) {
      final gatePos = _findFreeShapeCell(shape, arrows, obstacles, rng);
      final switchPos = _findFreeShapeCell(shape, arrows, obstacles, rng);

      if (gatePos != null && switchPos != null) {
        final gateId = 'gate_1';
        final switchId = 'switch_1';
        gates.add(GateElement(id: gateId, row: gatePos.x, col: gatePos.y, isOpen: false, linkedSwitchId: switchId));
        switches.add(SwitchElement(id: switchId, row: switchPos.x, col: switchPos.y, targetGateId: gateId));
      }
    }

    return LevelData(
      levelNumber: levelNumber,
      rows: shape.rows,
      cols: shape.cols,
      shapeDefinition: shape,
      initialArrows: arrows,
      initialGates: gates,
      initialSwitches: switches,
      initialKeys: keys,
      initialPortals: portals,
      initialIceCells: iceCells,
      initialObstacles: obstacles,
      title: '${shape.name} Level',
      worldNumber: worldNumber,
      difficultyLabel: difficultyLabel,
    );
  }

  static Point<int>? _findFreeShapeCell(
    ShapeDefinition shape,
    List<ArrowPiece> arrows,
    List<ObstacleElement> obstacles,
    Random rng,
  ) {
    final candidates = <Point<int>>[];
    for (int r = 0; r < shape.rows; r++) {
      for (int c = 0; c < shape.cols; c++) {
        if (!shape.isPlayable(r, c)) continue;
        final hasArrow = arrows.any((a) => a.row == r && a.column == c);
        final hasObstacle = obstacles.any((o) => o.row == r && o.col == c);
        if (!hasArrow && !hasObstacle) {
          candidates.add(Point(r, c));
        }
      }
    }
    if (candidates.isEmpty) return null;
    return candidates[rng.nextInt(candidates.length)];
  }

  static List<ArrowPiece> _generateReverseArrows(
    ShapeDefinition shape,
    int targetCount,
    Random rng,
  ) {
    final arrows = <ArrowPiece>[];
    int idCounter = 1;

    final positions = <Point<int>>[];
    for (int r = 0; r < shape.rows; r++) {
      for (int c = 0; c < shape.cols; c++) {
        if (shape.isPlayable(r, c)) {
          positions.add(Point(r, c));
        }
      }
    }
    positions.shuffle(rng);

    final selectedPositions = positions.take(targetCount).toList();

    for (final pos in selectedPositions) {
      final directions = ArrowDirection.values.toList()..shuffle(rng);
      ArrowDirection chosenDir = directions.first;

      for (final dir in directions) {
        if (_isPointingOutward(pos.x, pos.y, shape.rows, shape.cols, dir)) {
          chosenDir = dir;
          break;
        }
      }

      arrows.add(ArrowPiece(
        id: 'arrow_${idCounter++}',
        row: pos.x,
        column: pos.y,
        direction: chosenDir,
      ));
    }

    return arrows;
  }

  static bool _isPointingOutward(int r, int c, int rows, int cols, ArrowDirection dir) {
    switch (dir) {
      case ArrowDirection.up:
        return r < rows / 2;
      case ArrowDirection.down:
        return r >= rows / 2;
      case ArrowDirection.left:
        return c < cols / 2;
      case ArrowDirection.right:
        return c >= cols / 2;
    }
  }

  static LevelData _createFallbackLevel(
    int levelNumber,
    ShapeDefinition shape,
    int worldNumber,
    String difficultyLabel,
  ) {
    final arrows = <ArrowPiece>[];
    int idCounter = 1;

    // Pick top-leftmost and bottom-rightmost playable cells
    for (int r = 0; r < shape.rows; r++) {
      for (int c = 0; c < shape.cols; c++) {
        if (shape.isPlayable(r, c)) {
          arrows.add(ArrowPiece(
            id: 'arrow_${idCounter++}',
            row: r,
            column: c,
            direction: r < shape.rows / 2 ? ArrowDirection.up : ArrowDirection.down,
          ));
          if (arrows.length >= 3) break;
        }
      }
      if (arrows.length >= 3) break;
    }

    return LevelData(
      levelNumber: levelNumber,
      rows: shape.rows,
      cols: shape.cols,
      shapeDefinition: shape,
      initialArrows: arrows,
      title: '${shape.name} Challenge',
      worldNumber: worldNumber,
      difficultyLabel: difficultyLabel,
    );
  }
}
