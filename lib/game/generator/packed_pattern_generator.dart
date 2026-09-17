import 'dart:math';
import '../../models/arrow_direction.dart';
import '../../models/arrow_network.dart';
import '../../models/arrow_piece.dart';
import '../../models/board.dart';
import '../../models/level_data.dart';
import '../solver/puzzle_solver.dart';

enum PatternFamily {
  denseStraight,
  turning,
  interlocking,
  branching,
  spiral,
  wave,
  cross,
  layered,
  ring,
  hybrid,
}

class PackedTierConfig {
  final int tierNumber;
  final String name;
  final PatternFamily family;
  final int gridRows;
  final int gridCols;
  final double minCoverage; // 0.75 to 0.90
  final double maxCoverage;
  final int minDepth;
  final int maxDepth;
  final bool allowSwitches;
  final bool allowKeys;

  const PackedTierConfig({
    required this.tierNumber,
    required this.name,
    required this.family,
    required this.gridRows,
    required this.gridCols,
    this.minCoverage = 0.75,
    this.maxCoverage = 0.90,
    required this.minDepth,
    required this.maxDepth,
    this.allowSwitches = false,
    this.allowKeys = false,
  });
}

class PackedArrowPatternGenerator {
  static const int generatorVersion = 1;
  static const int maxAttempts = 100;

  /// Gets tier configuration for a level number (1 to 1000+).
  static PackedTierConfig getTierConfig(int levelNumber) {
    final familyIndex = ((levelNumber - 1) ~/ 100) % PatternFamily.values.length;
    final family = PatternFamily.values[familyIndex];

    if (levelNumber <= 10) {
      return const PackedTierConfig(
        tierNumber: 1,
        name: 'PACKED FOUNDATION',
        family: PatternFamily.denseStraight,
        gridRows: 5,
        gridCols: 5,
        minCoverage: 0.76,
        maxCoverage: 0.84,
        minDepth: 2,
        maxDepth: 4,
      );
    } else if (levelNumber <= 25) {
      return const PackedTierConfig(
        tierNumber: 2,
        name: 'TURNING PATTERNS',
        family: PatternFamily.turning,
        gridRows: 5,
        gridCols: 5,
        minCoverage: 0.78,
        maxCoverage: 0.88,
        minDepth: 3,
        maxDepth: 5,
      );
    } else if (levelNumber <= 50) {
      return const PackedTierConfig(
        tierNumber: 3,
        name: 'INTERLOCKING PATTERNS',
        family: PatternFamily.interlocking,
        gridRows: 6,
        gridCols: 6,
        minCoverage: 0.80,
        maxCoverage: 0.90,
        minDepth: 4,
        maxDepth: 7,
      );
    } else if (levelNumber <= 100) {
      return const PackedTierConfig(
        tierNumber: 4,
        name: 'BRANCHING PATTERNS',
        family: PatternFamily.branching,
        gridRows: 6,
        gridCols: 6,
        minCoverage: 0.80,
        maxCoverage: 0.90,
        minDepth: 5,
        maxDepth: 9,
      );
    } else if (levelNumber <= 200) {
      return const PackedTierConfig(
        tierNumber: 5,
        name: 'SPIRAL PATTERNS',
        family: PatternFamily.spiral,
        gridRows: 7,
        gridCols: 7,
        minCoverage: 0.80,
        maxCoverage: 0.90,
        minDepth: 7,
        maxDepth: 12,
        allowSwitches: true,
      );
    } else if (levelNumber <= 300) {
      return const PackedTierConfig(
        tierNumber: 6,
        name: 'WAVE PATTERNS',
        family: PatternFamily.wave,
        gridRows: 7,
        gridCols: 7,
        minCoverage: 0.82,
        maxCoverage: 0.90,
        minDepth: 9,
        maxDepth: 15,
        allowSwitches: true,
        allowKeys: true,
      );
    } else if (levelNumber <= 500) {
      return const PackedTierConfig(
        tierNumber: 7,
        name: 'CROSS & LAYERED',
        family: PatternFamily.cross,
        gridRows: 8,
        gridCols: 8,
        minCoverage: 0.82,
        maxCoverage: 0.90,
        minDepth: 12,
        maxDepth: 20,
        allowSwitches: true,
        allowKeys: true,
      );
    } else if (levelNumber <= 750) {
      return const PackedTierConfig(
        tierNumber: 8,
        name: 'EXPERT PACKED',
        family: PatternFamily.ring,
        gridRows: 8,
        gridCols: 8,
        minCoverage: 0.84,
        maxCoverage: 0.90,
        minDepth: 15,
        maxDepth: 25,
        allowSwitches: true,
        allowKeys: true,
      );
    } else if (levelNumber <= 1000) {
      return const PackedTierConfig(
        tierNumber: 9,
        name: 'MASTER PACKED',
        family: PatternFamily.hybrid,
        gridRows: 9,
        gridCols: 9,
        minCoverage: 0.85,
        maxCoverage: 0.90,
        minDepth: 18,
        maxDepth: 30,
        allowSwitches: true,
        allowKeys: true,
      );
    } else {
      return PackedTierConfig(
        tierNumber: 10,
        name: 'INFINITE PACKED',
        family: family,
        gridRows: 9,
        gridCols: 9,
        minCoverage: 0.85,
        maxCoverage: 0.90,
        minDepth: 20,
        maxDepth: 35,
        allowSwitches: true,
        allowKeys: true,
      );
    }
  }

  /// Generates a seed-reproducible packed arrow pattern level (75%-90% coverage)
  /// with a designated Start Arrow and a Final Key Arrow.
  static LevelData generatePackedPatternLevel(int levelNumber, {int? customSeed}) {
    final baseSeed = customSeed ?? (levelNumber * 10007 + 7919);
    final tier = getTierConfig(levelNumber);
    final worldNumber = ((levelNumber - 1) ~/ 100) + 1;

    for (int attempt = 0; attempt < 12; attempt++) {
      final rng = Random(baseSeed + attempt * 13337);
      final level = _tryBuildPackedLevel(
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

    return _buildFallbackPackedLevel(levelNumber, tier, worldNumber);
  }

  static LevelData? _tryBuildPackedLevel({
    required int levelNumber,
    required PackedTierConfig tier,
    required int worldNumber,
    required Random rng,
  }) {
    final rows = tier.gridRows;
    final cols = tier.gridCols;
    final totalCells = rows * cols;

    final targetCoverage = tier.minCoverage + rng.nextDouble() * (tier.maxCoverage - tier.minCoverage);
    final targetNodeCount = (totalCells * targetCoverage).round().clamp(3, totalCells);

    final positions = <Point<int>>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        positions.add(Point(r, c));
      }
    }
    positions.shuffle(rng);

    final selectedPositions = positions.take(targetNodeCount).toList();
    final arrowPieces = <ArrowPiece>[];
    final nodes = <ArrowNode>[];

    final startIdx = rng.nextInt(targetNodeCount);
    int keyIdx = rng.nextInt(targetNodeCount);
    while (keyIdx == startIdx && targetNodeCount > 1) {
      keyIdx = rng.nextInt(targetNodeCount);
    }

    for (int i = 0; i < targetNodeCount; i++) {
      final pos = selectedPositions[i];
      final id = 'p_${i + 1}';
      final dir = _pickOutwardDirection(pos.x, pos.y, rows, cols, rng);
      final isStart = (i == startIdx);
      final isKey = (i == keyIdx);

      // Polyline path patterns for turning & wave families
      List<ArrowDirection>? pathPattern;
      if (tier.family == PatternFamily.turning || tier.family == PatternFamily.wave || tier.family == PatternFamily.hybrid) {
        if (rng.nextBool()) {
          final turnDir = (dir == ArrowDirection.up || dir == ArrowDirection.down)
              ? (rng.nextBool() ? ArrowDirection.left : ArrowDirection.right)
              : (rng.nextBool() ? ArrowDirection.up : ArrowDirection.down);
          pathPattern = [dir, turnDir];
        }
      }

      arrowPieces.add(ArrowPiece(
        id: id,
        row: pos.x,
        column: pos.y,
        direction: dir,
        pathPattern: pathPattern,
        isStartArrow: isStart,
        isKeyArrow: isKey,
      ));
    }

    // Build DAG dependency structure ensuring startIdx node exits first
    final connectsToMap = <String, List<String>>{};
    final dependsOnMap = <String, List<String>>{};
    final graph = DependencyGraph();

    for (int i = 0; i < targetNodeCount; i++) {
      final id = 'p_${i + 1}';
      connectsToMap[id] = [];
      dependsOnMap[id] = [];
      graph.addNode(id);
    }

    // Connect start node to subsequent nodes
    final startId = 'p_${startIdx + 1}';
    final keyId = 'p_${keyIdx + 1}';

    final remainingIndices = List.generate(targetNodeCount, (idx) => idx)..remove(startIdx);
    remainingIndices.shuffle(rng);

    String lastId = startId;
    for (final idx in remainingIndices) {
      final currId = 'p_${idx + 1}';
      connectsToMap[lastId]!.add(currId);
      dependsOnMap[currId]!.add(lastId);
      graph.addEdge(lastId, currId);
      lastId = currId;
    }

    if (graph.hasCycle()) return null;

    for (int i = 0; i < targetNodeCount; i++) {
      final id = 'p_${i + 1}';
      final piece = arrowPieces[i];

      nodes.add(ArrowNode(
        id: id,
        row: piece.row,
        col: piece.column,
        direction: piece.direction,
        pathPattern: piece.pathPattern,
        connectsToIds: connectsToMap[id] ?? [],
        dependsOnIds: dependsOnMap[id] ?? [],
        isBranch: (connectsToMap[id] ?? []).length > 1,
        isMerge: (dependsOnMap[id] ?? []).length > 1,
      ));
    }

    final actualCoverage = targetNodeCount / totalCells;
    final network = ArrowNetwork.fromNodeList(
      nodes,
      startArrowId: startId,
      keyArrowId: keyId,
      coverageRatio: actualCoverage,
      patternFamily: tier.family.name,
    );

    return LevelData(
      levelNumber: levelNumber,
      rows: rows,
      cols: cols,
      network: network,
      initialArrows: arrowPieces,
      worldNumber: worldNumber,
      difficultyLabel: '${tier.name} (${(actualCoverage * 100).round()}% PACKED)',
      title: '${tier.name} #${levelNumber}',
    );
  }

  static ArrowDirection _pickOutwardDirection(int r, int c, int rows, int cols, Random rng) {
    final dirs = ArrowDirection.values.toList()..shuffle(rng);
    for (final dir in dirs) {
      if (dir == ArrowDirection.up && r < rows / 2) return dir;
      if (dir == ArrowDirection.down && r >= rows / 2) return dir;
      if (dir == ArrowDirection.left && c < cols / 2) return dir;
      if (dir == ArrowDirection.right && c >= cols / 2) return dir;
    }
    return dirs.first;
  }

  static LevelData _buildFallbackPackedLevel(int levelNumber, PackedTierConfig tier, int worldNumber) {
    final arrows = [
      const ArrowPiece(id: 'p_1', row: 0, column: 0, direction: ArrowDirection.up, isStartArrow: true),
      const ArrowPiece(id: 'p_2', row: 0, column: 2, direction: ArrowDirection.right),
      const ArrowPiece(id: 'p_3', row: 2, column: 0, direction: ArrowDirection.left),
      const ArrowPiece(id: 'p_4', row: 2, column: 2, direction: ArrowDirection.down, isKeyArrow: true),
    ];
    final nodes = [
      const ArrowNode(id: 'p_1', row: 0, col: 0, direction: ArrowDirection.up, connectsToIds: ['p_2']),
      const ArrowNode(id: 'p_2', row: 0, col: 2, direction: ArrowDirection.right, dependsOnIds: ['p_1'], connectsToIds: ['p_3']),
      const ArrowNode(id: 'p_3', row: 2, col: 0, direction: ArrowDirection.left, dependsOnIds: ['p_2'], connectsToIds: ['p_4']),
      const ArrowNode(id: 'p_4', row: 2, col: 2, direction: ArrowDirection.down, dependsOnIds: ['p_3']),
    ];

    return LevelData(
      levelNumber: levelNumber,
      rows: tier.gridRows,
      cols: tier.gridCols,
      network: ArrowNetwork.fromNodeList(
        nodes,
        startArrowId: 'p_1',
        keyArrowId: 'p_4',
        coverageRatio: 0.80,
        patternFamily: tier.family.name,
      ),
      initialArrows: arrows,
      worldNumber: worldNumber,
      difficultyLabel: '${tier.name} (80% PACKED)',
      title: 'Level $levelNumber',
    );
  }
}
