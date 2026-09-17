import 'dart:math';
import '../../models/arrow_direction.dart';
import '../../models/arrow_piece.dart';
import '../../models/board.dart';
import '../../models/level_data.dart';
import '../solver/puzzle_solver.dart';

class GridTierConfig {
  final int tierNumber;
  final String name;
  final int gridRows;
  final int gridCols;
  final int arrowCount;
  final String themeBadge;

  const GridTierConfig({
    required this.tierNumber,
    required this.name,
    required this.gridRows,
    required this.gridCols,
    required this.arrowCount,
    required this.themeBadge,
  });
}

class GridLevelGenerator {
  /// Cache/Generator version identifier to ensure old simple outward cached levels are updated.
  static const int generatorVersion = 2;

  /// Gets grid configuration for a level number (1 to 1000+).
  static GridTierConfig getGridConfig(int levelNumber) {
    if (levelNumber <= 10) {
      return GridTierConfig(
        tierNumber: 1,
        name: '5x5 GRID BEGINNER',
        gridRows: 5,
        gridCols: 5,
        arrowCount: (6 + (levelNumber * 0.6)).round().clamp(6, 12),
        themeBadge: 'NEON BEGINNER',
      );
    } else if (levelNumber <= 25) {
      return GridTierConfig(
        tierNumber: 2,
        name: '6x6 GRID INTERMEDIATE',
        gridRows: 6,
        gridCols: 6,
        arrowCount: (12 + (levelNumber * 0.4)).round().clamp(12, 20),
        themeBadge: 'CYBER MATRIX',
      );
    } else if (levelNumber <= 50) {
      return GridTierConfig(
        tierNumber: 3,
        name: '7x7 GRID ADVANCED',
        gridRows: 7,
        gridCols: 7,
        arrowCount: (18 + (levelNumber * 0.35)).round().clamp(18, 30),
        themeBadge: 'EMERALD WEAVE',
      );
    } else {
      return GridTierConfig(
        tierNumber: 4,
        name: '8x8 GRID MASTER',
        gridRows: 8,
        gridCols: 8,
        arrowCount: (24 + ((levelNumber % 50) * 0.4)).round().clamp(24, 48),
        themeBadge: 'TITAN MASTER',
      );
    }
  }

  /// Generates a seed-reproducible, 100% solvable, inter-blocking arrow puzzle.
  static LevelData generateGridLevel(int levelNumber, {int? customSeed}) {
    final baseSeed = customSeed ?? (levelNumber * 10007 + 7919);
    final config = getGridConfig(levelNumber);
    final worldNumber = ((levelNumber - 1) ~/ 100) + 1;

    for (int attempt = 0; attempt < 30; attempt++) {
      final rng = Random(baseSeed + attempt * 13337);
      final level = _tryBuildReverseGridLevel(
        levelNumber: levelNumber,
        config: config,
        worldNumber: worldNumber,
        rng: rng,
      );

      if (level != null) {
        final board = level.createInitialBoard();
        final solution = PuzzleSolver.findSolution(board);
        if (solution != null && solution.length == level.initialArrows.length) {
          // Ensure puzzle has at least some blocking arrows (not all free immediately unless level 1)
          final removable = board.getRemovableArrows();
          if (levelNumber == 1 || removable.length < level.initialArrows.length) {
            return level;
          }
        }
      }
    }

    return _buildFallbackGridLevel(levelNumber, config, worldNumber);
  }

  /// Generates arrows in REVERSE sequence from empty board state so that arrows block each other.
  static LevelData? _tryBuildReverseGridLevel({
    required int levelNumber,
    required GridTierConfig config,
    required int worldNumber,
    required Random rng,
  }) {
    final rows = config.gridRows;
    final cols = config.gridCols;
    final targetCount = config.arrowCount;

    final placedArrows = <ArrowPiece>[];
    final occupied = List.generate(rows, (_) => List.filled(cols, false));

    for (int step = 0; step < targetCount; step++) {
      // Find all valid placements (r, c, dir) for the next arrow in reverse sequence.
      final candidates = <_CandidatePlacement>[];

      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          if (occupied[r][c]) continue;

          for (final dir in ArrowDirection.values) {
            if (_isExitPathClear(r, c, dir, rows, cols, occupied)) {
              final blocksCount = _countBlockedExistingArrows(r, c, dir, placedArrows, rows, cols);
              candidates.add(_CandidatePlacement(
                row: r,
                col: c,
                direction: dir,
                blocksCount: blocksCount,
              ));
            }
          }
        }
      }

      if (candidates.isEmpty) {
        if (placedArrows.length >= (targetCount * 0.7).round() && placedArrows.length >= 4) {
          break; // Good density reached
        }
        return null; // Retry with different attempt seed
      }

      // Prioritize placements that block existing arrows (interlocking puzzle candidates)
      final blockingCandidates = candidates.where((c) => c.blocksCount > 0).toList();
      _CandidatePlacement chosen;

      if (blockingCandidates.isNotEmpty && (step > 0) && rng.nextDouble() < 0.82) {
        blockingCandidates.shuffle(rng);
        chosen = blockingCandidates.first;
      } else {
        candidates.shuffle(rng);
        chosen = candidates.first;
      }

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

    return LevelData(
      levelNumber: levelNumber,
      rows: rows,
      cols: cols,
      initialArrows: placedArrows,
      worldNumber: worldNumber,
      difficultyLabel: config.name,
      title: '${config.themeBadge} #${levelNumber}',
    );
  }

  /// Checks if an arrow starting at (r, c) facing dir can reach the board boundary without hitting any occupied cell.
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
      if (occupied[currR][currC]) {
        return false;
      }
      currR += dir.dr;
      currC += dir.dc;
    }

    return true;
  }

  /// Counts how many already placed arrows would be blocked by placing a new arrow at (r, c).
  static int _countBlockedExistingArrows(
    int r,
    int c,
    ArrowDirection dir,
    List<ArrowPiece> placedArrows,
    int rows,
    int cols,
  ) {
    int blocked = 0;
    for (final arrow in placedArrows) {
      // Check if (r, c) lies along arrow's forward exit ray
      int checkR = arrow.row + arrow.direction.dr;
      int checkC = arrow.column + arrow.direction.dc;

      while (checkR >= 0 && checkR < rows && checkC >= 0 && checkC < cols) {
        if (checkR == r && checkC == c) {
          blocked++;
          break;
        }
        checkR += arrow.direction.dr;
        checkC += arrow.direction.dc;
      }
    }
    return blocked;
  }

  static LevelData _buildFallbackGridLevel(int levelNumber, GridTierConfig config, int worldNumber) {
    final rows = config.gridRows;
    final cols = config.gridCols;

    final arrows = [
      ArrowPiece(id: 'a_1', row: 1, column: 1, direction: ArrowDirection.down),
      ArrowPiece(id: 'a_2', row: 2, column: 1, direction: ArrowDirection.right),
      ArrowPiece(id: 'a_3', row: 2, column: cols - 1, direction: ArrowDirection.right),
    ];

    return LevelData(
      levelNumber: levelNumber,
      rows: rows,
      cols: cols,
      initialArrows: arrows,
      worldNumber: worldNumber,
      difficultyLabel: config.name,
      title: 'Level $levelNumber',
    );
  }
}

class _CandidatePlacement {
  final int row;
  final int col;
  final ArrowDirection direction;
  final int blocksCount;

  _CandidatePlacement({
    required this.row,
    required this.col,
    required this.direction,
    required this.blocksCount,
  });
}

