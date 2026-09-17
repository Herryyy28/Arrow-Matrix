import '../../models/board.dart';

enum PuzzleDifficulty {
  easy,
  medium,
  hard,
  expert,
  master,
}

extension PuzzleDifficultyExtension on PuzzleDifficulty {
  String get label {
    switch (this) {
      case PuzzleDifficulty.easy:
        return 'EASY';
      case PuzzleDifficulty.medium:
        return 'MEDIUM';
      case PuzzleDifficulty.hard:
        return 'HARD';
      case PuzzleDifficulty.expert:
        return 'EXPERT';
      case PuzzleDifficulty.master:
        return 'MASTER';
    }
  }
}

class DifficultyAnalyzer {
  /// Analyzes a board state and its solution path to return an objective difficulty rating.
  static PuzzleDifficulty analyze(Board board, List<String> solutionPath) {
    final int solutionLength = solutionPath.length;
    final int totalCells = board.rows * board.cols;
    final double density = board.arrows.length / totalCells;

    final int elementCount = board.switches.length +
        board.gates.length +
        board.keys.length +
        board.portals.length +
        board.arrows.where((a) => a.isLocked).length;

    // Calculate a combined score
    double score = 0;

    // Solution length contribution
    score += solutionLength * 1.5;

    // Grid density contribution
    score += density * 10;

    // Special mechanics contribution
    score += elementCount * 3.5;

    // Master puzzle checks: if contains 4+ special elements and solution length >= 8
    if (elementCount >= 4 && solutionLength >= 8) {
      return PuzzleDifficulty.master;
    }

    if (score >= 35.0 || solutionLength >= 12) {
      return PuzzleDifficulty.expert;
    } else if (score >= 22.0 || solutionLength >= 8 || elementCount >= 2) {
      return PuzzleDifficulty.hard;
    } else if (score >= 12.0 || solutionLength >= 5 || elementCount >= 1) {
      return PuzzleDifficulty.medium;
    } else {
      return PuzzleDifficulty.easy;
    }
  }
}
