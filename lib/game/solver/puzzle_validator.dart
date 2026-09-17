import '../../models/board.dart';
import '../../models/puzzle_element.dart';
import 'puzzle_solver.dart';
import 'difficulty_analyzer.dart';

class ValidationResult {
  final bool isValid;
  final String reason;
  final PuzzleDifficulty difficulty;
  final List<String>? solutionPath;
  final int stepCount;

  const ValidationResult({
    required this.isValid,
    required this.reason,
    this.difficulty = PuzzleDifficulty.easy,
    this.solutionPath,
    this.stepCount = 0,
  });

  @override
  String toString() =>
      'ValidationResult(isValid: $isValid, difficulty: $difficulty, steps: $stepCount, reason: "$reason")';
}

class PuzzleValidator {
  /// Validates a level board state:
  /// LOAD -> SIMULATE -> SOLVE -> VALIDATE -> ACCEPT / REJECT
  static ValidationResult validate(Board board) {
    if (board.arrows.isEmpty) {
      return const ValidationResult(
        isValid: false,
        reason: 'Board contains no arrows.',
      );
    }

    // 1. Solve board
    final solutionPath = PuzzleSolver.findSolution(board);
    if (solutionPath == null || solutionPath.isEmpty) {
      return const ValidationResult(
        isValid: false,
        reason: 'No valid solution sequence found (deadlock or impossible condition).',
      );
    }

    // 2. Simulate step by step to ensure all key/switch dependencies resolve correctly
    Board simulated = board.copyWith();
    for (final arrowId in solutionPath) {
      final arrow = simulated.arrows.firstWhere(
        (a) => a.id == arrowId,
        orElse: () => throw StateError('Arrow $arrowId not found during validation simulation'),
      );
      simulated = PuzzleSolver.simulateMove(simulated, arrow);
    }

    if (!simulated.isCleared) {
      return const ValidationResult(
        isValid: false,
        reason: 'Simulation ended with remaining uncollected arrows.',
      );
    }

    // 3. Verify object completeness
    for (final key in board.keys) {
      final finalKey = simulated.keys.firstWhere((k) => k.id == key.id);
      if (!finalKey.isCollected) {
        return ValidationResult(
          isValid: false,
          reason: 'Key ${key.id} was never collected in solution path.',
          solutionPath: solutionPath,
        );
      }
    }

    for (final sw in board.switches) {
      final finalSwitch = simulated.switches.firstWhere((s) => s.id == sw.id);
      if (!finalSwitch.isActivated) {
        return ValidationResult(
          isValid: false,
          reason: 'Switch ${sw.id} was never activated in solution path.',
          solutionPath: solutionPath,
        );
      }
    }

    // 4. Calculate difficulty
    final difficulty = DifficultyAnalyzer.analyze(board, solutionPath);

    return ValidationResult(
      isValid: true,
      reason: 'Puzzle is 100% valid and solvable.',
      difficulty: difficulty,
      solutionPath: solutionPath,
      stepCount: solutionPath.length,
    );
  }
}
