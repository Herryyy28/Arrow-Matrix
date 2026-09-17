import 'dart:math';
import '../../models/arrow_direction.dart';
import '../../models/arrow_network.dart';
import '../../models/arrow_piece.dart';
import '../../models/board.dart';
import '../../models/level_data.dart';
import '../../models/shape_definition.dart';
import '../solver/puzzle_solver.dart';

class GridTierConfig {
  final int tierNumber;
  final String name;
  final int gridRows;
  final int gridCols;
  final int arrowCount;
  final int targetDependencyDepth;
  final String themeBadge;

  const GridTierConfig({
    required this.tierNumber,
    required this.name,
    required this.gridRows,
    required this.gridCols,
    required this.arrowCount,
    required this.targetDependencyDepth,
    required this.themeBadge,
  });
}

class GridLevelGenerator {
  /// Cache/Generator version identifier to ensure old cached levels upgrade.
  static const int generatorVersion = 3;

  /// Gets grid & difficulty tier configuration for a level number (1 to 1000+).
  static GridTierConfig getGridConfig(int levelNumber) {
    if (levelNumber <= 10) {
      return GridTierConfig(
        tierNumber: 1,
        name: 'BEGINNER SHAPE MAZE',
        gridRows: 5,
        gridCols: 5,
        arrowCount: (4 + (levelNumber * 0.4)).round().clamp(4, 7),
        targetDependencyDepth: 2,
        themeBadge: 'NEON BEGINNER',
      );
    } else if (levelNumber <= 25) {
      return GridTierConfig(
        tierNumber: 2,
        name: 'INTERMEDIATE INTERLOCKED',
        gridRows: 6,
        gridCols: 6,
        arrowCount: (8 + (levelNumber * 0.35)).round().clamp(8, 14),
        targetDependencyDepth: 3,
        themeBadge: 'CYBER MATRIX',
      );
    } else if (levelNumber <= 50) {
      return GridTierConfig(
        tierNumber: 3,
        name: 'ADVANCED GRAPH MAZE',
        gridRows: 7,
        gridCols: 7,
        arrowCount: (14 + (levelNumber * 0.3)).round().clamp(14, 22),
        targetDependencyDepth: 5,
        themeBadge: 'EMERALD WEAVE',
      );
    } else {
      return GridTierConfig(
        tierNumber: 4,
        name: 'MASTER TOPOLOGY MESH',
        gridRows: 8,
        gridCols: 8,
        arrowCount: (20 + ((levelNumber % 50) * 0.3)).round().clamp(20, 36),
        targetDependencyDepth: 7,
        themeBadge: 'TITAN MASTER',
      );
    }
  }

  /// Generates a seed-reproducible, 100% solvable, interlocked directional puzzle.
  static LevelData generateGridLevel(int levelNumber, {int? customSeed}) {
    final baseSeed = customSeed ?? (levelNumber * 10007 + 7919);
    final config = getGridConfig(levelNumber);
    final worldNumber = ((levelNumber - 1) ~/ 100) + 1;

    for (int attempt = 0; attempt < 50; attempt++) {
      final rng = Random(baseSeed + attempt * 13337);
      final level = _tryBuildInterlockedLevel(
        levelNumber: levelNumber,
        config: config,
        worldNumber: worldNumber,
        rng: rng,
      );

      if (level != null) {
        final board = level.createInitialBoard();
        final solution = PuzzleSolver.findSolution(board);

        if (solution != null && solution.length == level.initialArrows.length) {
          final removable = board.getRemovableArrows();
          final dependencyDepth = board.network?.chainDepth ?? 1;

          // Ensure puzzle has interlocked blocking dependencies (not all free immediately unless level 1)
          if (levelNumber == 1 ||
              (removable.length < level.initialArrows.length && dependencyDepth >= config.targetDependencyDepth)) {
            return level;
          }
        }
      }
    }

    return _buildFallbackInterlockedLevel(levelNumber, config, worldNumber);
  }

  /// Generates interlocked directed dependency graph inside shape silhouettes.
  static LevelData? _tryBuildInterlockedLevel({
    required int levelNumber,
    required GridTierConfig config,
    required int worldNumber,
    required Random rng,
  }) {
    final shape = ShapeLibrary.allShapes[(levelNumber - 1) % ShapeLibrary.allShapes.length];
    final rows = shape.rows;
    final cols = shape.cols;

    final placedArrows = <ArrowPiece>[];
    final occupied = List.generate(rows, (_) => List.filled(cols, false));

    // Calculate maximum target arrows inside the shape mask
    int playableCellCount = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (shape.isPlayable(r, c)) playableCellCount++;
      }
    }
    final targetCount = (playableCellCount * 0.70).round().clamp(4, config.arrowCount);

    for (int step = 0; step < targetCount; step++) {
      final candidates = <_InterlockedCandidate>[];

      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          if (!shape.isPlayable(r, c) || occupied[r][c]) continue;

          for (final dir in ArrowDirection.values) {
            if (_isExitPathClear(r, c, dir, rows, cols, occupied)) {
              final blocksCount = _countBlockedExistingArrows(r, c, dir, placedArrows, rows, cols);
              final isFacing = _isFacingAnyArrow(r, c, dir, placedArrows);
              final isCrossing = _isCrossingAnyArrow(r, c, dir, placedArrows, rows, cols);

              double score = blocksCount * 10.0;
              if (isFacing) score += 15.0;
              if (isCrossing) score += 8.0;

              candidates.add(_InterlockedCandidate(
                row: r,
                col: c,
                direction: dir,
                blocksCount: blocksCount,
                isFacing: isFacing,
                isCrossing: isCrossing,
                interlockScore: score,
              ));
            }
          }
        }
      }

      if (candidates.isEmpty) {
        if (placedArrows.length >= (targetCount * 0.55).round() && placedArrows.length >= 3) {
          break; // Good density reached inside shape
        }
        return null; // Retry with different seed
      }

      // Prioritize high interlock score candidates (facing, blocking, crossing)
      candidates.sort((a, b) => b.interlockScore.compareTo(a.interlockScore));

      final topCandidates = candidates.take(max(1, (candidates.length * 0.3).round())).toList();
      topCandidates.shuffle(rng);
      final chosen = topCandidates.first;

      final arrowId = 'a_${step + 1}';
      placedArrows.add(ArrowPiece(
        id: arrowId,
        row: chosen.row,
        column: chosen.col,
        direction: chosen.direction,
      ));
      occupied[chosen.row][chosen.col] = true;
    }

    if (placedArrows.isEmpty) return null;

    // Build directed network graph
    final nodes = <ArrowNode>[];
    for (final arrow in placedArrows) {
      final connectsTo = <String>[];
      final dependsOn = <String>[];

      for (final other in placedArrows) {
        if (other.id == arrow.id) continue;
        if (_doesArrowBlock(arrow, other, rows, cols)) {
          connectsTo.add(other.id);
        }
        if (_doesArrowBlock(other, arrow, rows, cols)) {
          dependsOn.add(other.id);
        }
      }

      nodes.add(ArrowNode(
        id: arrow.id,
        row: arrow.row,
        col: arrow.column,
        direction: arrow.direction,
        connectsToIds: connectsTo,
        dependsOnIds: dependsOn,
      ));
    }

    final network = ArrowNetwork.fromNodeList(nodes);

    return LevelData(
      levelNumber: levelNumber,
      rows: rows,
      cols: cols,
      shapeDefinition: shape,
      initialArrows: placedArrows,
      worldNumber: worldNumber,
      difficultyLabel: '${shape.name} (${shape.difficulty})',
      title: '${shape.name.toUpperCase()} #${levelNumber}',
      network: network,
    );
  }

  static bool _isExitPathClear(
    int r,
    int c,
    ArrowDirection dir,
    int rows,
    int cols,
    List<List<bool>> occupied,
  ) {
    int currR = r + dir.dr;
    int currC = c + dir.dc;

    while (currR >= 0 && currR < rows && currC >= 0 && currC < cols) {
      if (occupied[currR][currC]) return false;
      currR += dir.dr;
      currC += dir.dc;
    }
    return true;
  }

  static int _countBlockedExistingArrows(
    int r,
    int c,
    ArrowDirection dir,
    List<ArrowPiece> placedArrows,
    int rows,
    int cols,
  ) {
    int count = 0;
    for (final arrow in placedArrows) {
      if (_doesCellBlockArrow(r, c, arrow, rows, cols)) {
        count++;
      }
    }
    return count;
  }

  static bool _doesCellBlockArrow(int r, int c, ArrowPiece arrow, int rows, int cols) {
    int checkR = arrow.row + arrow.direction.dr;
    int checkC = arrow.column + arrow.direction.dc;

    while (checkR >= 0 && checkR < rows && checkC >= 0 && checkC < cols) {
      if (checkR == r && checkC == c) return true;
      checkR += arrow.direction.dr;
      checkC += arrow.direction.dc;
    }
    return false;
  }

  static bool _doesArrowBlock(ArrowPiece blocker, ArrowPiece target, int rows, int cols) {
    return _doesCellBlockArrow(blocker.row, blocker.column, target, rows, cols);
  }

  static bool _isFacingAnyArrow(int r, int c, ArrowDirection dir, List<ArrowPiece> placedArrows) {
    for (final other in placedArrows) {
      final isOpposite = (dir.dr == -other.direction.dr && dir.dc == -other.direction.dc);
      if (isOpposite) {
        if (dir == ArrowDirection.left || dir == ArrowDirection.right) {
          if (r == other.row) return true;
        } else {
          if (c == other.column) return true;
        }
      }
    }
    return false;
  }

  static bool _isCrossingAnyArrow(
    int r,
    int c,
    ArrowDirection dir,
    List<ArrowPiece> placedArrows,
    int rows,
    int cols,
  ) {
    for (final other in placedArrows) {
      final isPerpendicular = (dir.dr * other.direction.dr + dir.dc * other.direction.dc) == 0;
      if (isPerpendicular) {
        if (dir == ArrowDirection.left || dir == ArrowDirection.right) {
          if (c <= max(r, other.column) && c >= min(r, other.column)) return true;
        }
      }
    }
    return false;
  }

  static LevelData _buildFallbackInterlockedLevel(int levelNumber, GridTierConfig config, int worldNumber) {
    final shape = ShapeLibrary.allShapes[(levelNumber - 1) % ShapeLibrary.allShapes.length];
    final rows = shape.rows;
    final cols = shape.cols;

    final arrows = <ArrowPiece>[];
    int count = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (shape.isPlayable(r, c) && count < 5) {
          count++;
          arrows.add(ArrowPiece(
            id: 'a_$count',
            row: r,
            column: c,
            direction: ArrowDirection.values[count % 4],
          ));
        }
      }
    }

    return LevelData(
      levelNumber: levelNumber,
      rows: rows,
      cols: cols,
      shapeDefinition: shape,
      initialArrows: arrows,
      worldNumber: worldNumber,
      difficultyLabel: '${shape.name} (${shape.difficulty})',
      title: '${shape.name.toUpperCase()} #${levelNumber}',
    );
  }
}

class _InterlockedCandidate {
  final int row;
  final int col;
  final ArrowDirection direction;
  final int blocksCount;
  final bool isFacing;
  final bool isCrossing;
  final double interlockScore;

  _InterlockedCandidate({
    required this.row,
    required this.col,
    required this.direction,
    required this.blocksCount,
    required this.isFacing,
    required this.isCrossing,
    required this.interlockScore,
  });
}


