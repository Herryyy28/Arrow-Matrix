import 'dart:math';
import '../../models/arrow_direction.dart';
import '../../models/arrow_network.dart';
import '../../models/arrow_piece.dart';
import '../../models/board.dart';
import '../../models/level_data.dart';
import '../../models/puzzle_element.dart';
import '../solver/puzzle_solver.dart';

class NetworkTierConfig {
  final int tierNumber;
  final String name;
  final int minDepth;
  final int maxDepth;
  final int minNodes;
  final int maxNodes;
  final int gridRows;
  final int gridCols;
  final double branchProbability;
  final double mergeProbability;
  final bool allowSwitches;
  final bool allowKeys;
  final bool allowMovingWalls;
  final bool allowPortals;

  const NetworkTierConfig({
    required this.tierNumber,
    required this.name,
    required this.minDepth,
    required this.maxDepth,
    required this.minNodes,
    required this.maxNodes,
    required this.gridRows,
    required this.gridCols,
    this.branchProbability = 0.0,
    this.mergeProbability = 0.0,
    this.allowSwitches = false,
    this.allowKeys = false,
    this.allowMovingWalls = false,
    this.allowPortals = false,
  });
}

class ProceduralNetworkGenerator {
  /// Maps level numbers to difficulty tier parameters.
  static NetworkTierConfig getTierConfig(int levelNumber) {
    if (levelNumber <= 50) {
      return const NetworkTierConfig(
        tierNumber: 1,
        name: 'FOUNDATION',
        minDepth: 1,
        maxDepth: 3,
        minNodes: 3,
        maxNodes: 5,
        gridRows: 5,
        gridCols: 5,
      );
    } else if (levelNumber <= 100) {
      return const NetworkTierConfig(
        tierNumber: 2,
        name: 'PLANNING',
        minDepth: 3,
        maxDepth: 5,
        minNodes: 4,
        maxNodes: 6,
        gridRows: 6,
        gridCols: 6,
        branchProbability: 0.25,
      );
    } else if (levelNumber <= 200) {
      return const NetworkTierConfig(
        tierNumber: 3,
        name: 'INTERLOCKING',
        minDepth: 5,
        maxDepth: 8,
        minNodes: 5,
        maxNodes: 8,
        gridRows: 6,
        gridCols: 6,
        branchProbability: 0.35,
        mergeProbability: 0.20,
      );
    } else if (levelNumber <= 300) {
      return const NetworkTierConfig(
        tierNumber: 4,
        name: 'BRANCHING & MECHANICS',
        minDepth: 7,
        maxDepth: 10,
        minNodes: 6,
        maxNodes: 9,
        gridRows: 7,
        gridCols: 7,
        branchProbability: 0.45,
        mergeProbability: 0.25,
        allowSwitches: true,
      );
    } else if (levelNumber <= 400) {
      return const NetworkTierConfig(
        tierNumber: 5,
        name: 'DEEP DEPENDENCIES',
        minDepth: 8,
        maxDepth: 12,
        minNodes: 7,
        maxNodes: 10,
        gridRows: 7,
        gridCols: 7,
        branchProbability: 0.50,
        mergeProbability: 0.30,
        allowSwitches: true,
        allowKeys: true,
      );
    } else if (levelNumber <= 500) {
      return const NetworkTierConfig(
        tierNumber: 6,
        name: 'MULTI-STATE',
        minDepth: 10,
        maxDepth: 15,
        minNodes: 8,
        maxNodes: 12,
        gridRows: 8,
        gridCols: 8,
        branchProbability: 0.55,
        mergeProbability: 0.35,
        allowSwitches: true,
        allowKeys: true,
        allowMovingWalls: true,
      );
    } else if (levelNumber <= 600) {
      return const NetworkTierConfig(
        tierNumber: 7,
        name: 'ADVANCED MECHANICS',
        minDepth: 12,
        maxDepth: 18,
        minNodes: 9,
        maxNodes: 14,
        gridRows: 8,
        gridCols: 8,
        branchProbability: 0.60,
        mergeProbability: 0.40,
        allowSwitches: true,
        allowKeys: true,
        allowMovingWalls: true,
        allowPortals: true,
      );
    } else if (levelNumber <= 700) {
      return const NetworkTierConfig(
        tierNumber: 8,
        name: 'MULTI-CHAIN',
        minDepth: 15,
        maxDepth: 20,
        minNodes: 10,
        maxNodes: 16,
        gridRows: 8,
        gridCols: 8,
        branchProbability: 0.65,
        mergeProbability: 0.45,
        allowSwitches: true,
        allowKeys: true,
        allowMovingWalls: true,
        allowPortals: true,
      );
    } else if (levelNumber <= 850) {
      return const NetworkTierConfig(
        tierNumber: 9,
        name: 'EXPERT NETWORKS',
        minDepth: 18,
        maxDepth: 25,
        minNodes: 12,
        maxNodes: 18,
        gridRows: 9,
        gridCols: 9,
        branchProbability: 0.70,
        mergeProbability: 0.50,
        allowSwitches: true,
        allowKeys: true,
        allowMovingWalls: true,
        allowPortals: true,
      );
    } else {
      return const NetworkTierConfig(
        tierNumber: 10,
        name: 'MASTER NETWORKS',
        minDepth: 20,
        maxDepth: 30,
        minNodes: 14,
        maxNodes: 20,
        gridRows: 9,
        gridCols: 9,
        branchProbability: 0.75,
        mergeProbability: 0.55,
        allowSwitches: true,
        allowKeys: true,
        allowMovingWalls: true,
        allowPortals: true,
      );
    }
  }

  /// Generates a guaranteed-solvable, deadlock-free procedural network level.
  static LevelData generateNetworkLevel(int levelNumber, {int? customSeed}) {
    final baseSeed = customSeed ?? (levelNumber * 7919);
    final tier = getTierConfig(levelNumber);
    final worldNumber = ((levelNumber - 1) ~/ 100) + 1;

    for (int attempt = 0; attempt < 10; attempt++) {
      final rng = Random(baseSeed + attempt * 10007);
      final level = _tryBuildNetworkLevel(
        levelNumber: levelNumber,
        tier: tier,
        worldNumber: worldNumber,
        rng: rng,
      );

      if (level != null) {
        final board = level.createInitialBoard();
        if (PuzzleSolver.isSolvable(board)) {
          return level;
        }
      }
    }

    // High-reliability fallback
    return _buildFallbackNetworkLevel(levelNumber, tier, worldNumber);
  }

  static LevelData? _tryBuildNetworkLevel({
    required int levelNumber,
    required NetworkTierConfig tier,
    required int worldNumber,
    required Random rng,
  }) {
    final nodeCount = tier.minNodes + rng.nextInt(max(1, tier.maxNodes - tier.minNodes + 1));
    final rows = tier.gridRows;
    final cols = tier.gridCols;

    // Pick distinct grid cell positions
    final positions = <Point<int>>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        positions.add(Point(r, c));
      }
    }
    positions.shuffle(rng);
    if (positions.length < nodeCount) return null;

    final selectedPositions = positions.take(nodeCount).toList();
    final arrowPieces = <ArrowPiece>[];
    final nodes = <ArrowNode>[];

    // Assign directions pointing towards outer edges
    for (int i = 0; i < nodeCount; i++) {
      final pos = selectedPositions[i];
      final id = 'a${i + 1}';
      final dir = _pickOutwardDirection(pos.x, pos.y, rows, cols, rng);

      arrowPieces.add(ArrowPiece(
        id: id,
        row: pos.x,
        column: pos.y,
        direction: dir,
      ));
    }

    // Build DAG (Directed Acyclic Graph) connections without cycles
    final graph = DependencyGraph();
    for (int i = 0; i < nodeCount; i++) {
      graph.addNode('a${i + 1}');
    }

    final connectsToMap = <String, List<String>>{};
    final dependsOnMap = <String, List<String>>{};

    for (int i = 0; i < nodeCount; i++) {
      connectsToMap['a${i + 1}'] = [];
      dependsOnMap['a${i + 1}'] = [];
    }

    // Forward chain dependencies: node i depends on node i-1 (so node 1 exits first)
    for (int i = 1; i < nodeCount; i++) {
      final prevId = 'a$i';
      final currId = 'a${i + 1}';

      connectsToMap[prevId]!.add(currId);
      dependsOnMap[currId]!.add(prevId);
      graph.addEdge(prevId, currId);

      // Branching logic
      if (i + 2 <= nodeCount && rng.nextDouble() < tier.branchProbability) {
        final branchTarget = 'a${i + 2}';
        if (!connectsToMap[prevId]!.contains(branchTarget)) {
          connectsToMap[prevId]!.add(branchTarget);
          dependsOnMap[branchTarget]!.add(prevId);
          graph.addEdge(prevId, branchTarget);
        }
      }
    }

    // Ensure cycle-free
    if (graph.hasCycle()) return null;

    // Construct ArrowNode instances
    for (int i = 0; i < nodeCount; i++) {
      final id = 'a${i + 1}';
      final piece = arrowPieces[i];
      final connects = connectsToMap[id] ?? [];
      final depends = dependsOnMap[id] ?? [];

      nodes.add(ArrowNode(
        id: id,
        row: piece.row,
        col: piece.column,
        direction: piece.direction,
        connectsToIds: connects,
        dependsOnIds: depends,
        isBranch: connects.length > 1,
        isMerge: depends.length > 1,
      ));
    }

    final network = ArrowNetwork.fromNodeList(nodes);

    return LevelData(
      levelNumber: levelNumber,
      rows: rows,
      cols: cols,
      network: network,
      initialArrows: arrowPieces,
      worldNumber: worldNumber,
      difficultyLabel: tier.name,
      title: '${tier.name} #${levelNumber}',
    );
  }

  static ArrowDirection _pickOutwardDirection(
    int r,
    int c,
    int rows,
    int cols,
    Random rng,
  ) {
    final dirs = ArrowDirection.values.toList()..shuffle(rng);
    for (final dir in dirs) {
      if (dir == ArrowDirection.up && r < rows / 2) return dir;
      if (dir == ArrowDirection.down && r >= rows / 2) return dir;
      if (dir == ArrowDirection.left && c < cols / 2) return dir;
      if (dir == ArrowDirection.right && c >= cols / 2) return dir;
    }
    return dirs.first;
  }

  static LevelData _buildFallbackNetworkLevel(
    int levelNumber,
    NetworkTierConfig tier,
    int worldNumber,
  ) {
    final nodes = [
      const ArrowNode(id: 'a1', row: 0, col: 0, direction: ArrowDirection.up, connectsToIds: ['a2']),
      const ArrowNode(id: 'a2', row: 0, col: 4, direction: ArrowDirection.up, dependsOnIds: ['a1'], connectsToIds: ['a3']),
      const ArrowNode(id: 'a3', row: 4, col: 0, direction: ArrowDirection.down, dependsOnIds: ['a2']),
    ];
    final arrows = const [
      ArrowPiece(id: 'a1', row: 0, column: 0, direction: ArrowDirection.up),
      ArrowPiece(id: 'a2', row: 0, column: 4, direction: ArrowDirection.up),
      ArrowPiece(id: 'a3', row: 4, column: 0, direction: ArrowDirection.down),
    ];

    return LevelData(
      levelNumber: levelNumber,
      rows: tier.gridRows,
      cols: tier.gridCols,
      network: ArrowNetwork.fromNodeList(nodes),
      initialArrows: arrows,
      worldNumber: worldNumber,
      difficultyLabel: tier.name,
      title: 'Level $levelNumber',
    );
  }
}
