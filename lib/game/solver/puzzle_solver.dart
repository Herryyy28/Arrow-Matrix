import '../../models/board.dart';
import '../../models/arrow_piece.dart';
import '../../models/arrow_direction.dart';
import '../../models/arrow_network.dart';

class PuzzleHint {
  final String targetArrowId;
  final String? dependencyId;
  final String explanation;
  final int tier;

  const PuzzleHint({
    required this.targetArrowId,
    this.dependencyId,
    required this.explanation,
    required this.tier,
  });
}

class _SolverContext {
  int evaluations = 0;
  final int maxEvaluations;
  _SolverContext({this.maxEvaluations = 600});
}

class PuzzleSolver {
  /// Determines whether the given board is 100% solvable.
  /// Solvable means there exists at least one sequence of valid moves that clears all arrows.
  static bool isSolvable(Board board) {
    return findSolution(board) != null;
  }

  /// Finds a sequence of arrow IDs that successfully clears the board.
  /// Returns null if no solution exists.
  static List<String>? findSolution(Board board) {
    final currentBoard = board.copyWith();
    final solutionPath = <String>[];
    final ctx = _SolverContext(maxEvaluations: 600);
    if (_solveRecursive(currentBoard, solutionPath, 0, ctx)) {
      return solutionPath;
    }
    return null;
  }

  static bool _solveRecursive(Board board, List<String> path, int depth, _SolverContext ctx) {
    ctx.evaluations++;
    if (board.isCleared) {
      return true;
    }

    if (depth > 100 || ctx.evaluations > ctx.maxEvaluations) return false;

    final removable = board.getRemovableArrows();
    if (removable.isEmpty) {
      return false;
    }

    for (final arrow in removable) {
      path.add(arrow.id);

      // Simulate move and resulting state changes (gates, keys, locks, etc.)
      final nextBoard = simulateMove(board, arrow);

      if (_solveRecursive(nextBoard, path, depth + 1, ctx)) {
        return true;
      }

      // Backtrack
      path.removeLast();
    }

    return false;
  }

  /// Simulates removing an arrow and applying all triggered switches, key collections, and gate state changes.
  static Board simulateMove(Board board, ArrowPiece arrow) {
    final pathInfo = board.calculateArrowPath(arrow);

    // 1. Mark arrow as removed
    final updatedArrows = board.arrows.map((a) {
      if (a.id == arrow.id) {
        return a.copyWith(isRemoved: true);
      }
      return a.copyWith();
    }).toList();

    // 2. Trigger switches & open target gates
    final updatedGates = board.gates.map((g) => g.copyWith()).toList();
    final updatedSwitches = board.switches.map((s) => s.copyWith()).toList();

    for (final sw in pathInfo.triggeredSwitches) {
      final sIdx = updatedSwitches.indexWhere((s) => s.id == sw.id);
      if (sIdx != -1) {
        updatedSwitches[sIdx] = updatedSwitches[sIdx].copyWith(isActivated: true);
        final targetGateId = updatedSwitches[sIdx].targetGateId;

        final gIdx = updatedGates.indexWhere((g) => g.id == targetGateId);
        if (gIdx != -1) {
          updatedGates[gIdx] = updatedGates[gIdx].copyWith(isOpen: true);
        }
      }
    }

    // 3. Collect keys & unlock locked arrows
    final updatedKeys = board.keys.map((k) => k.copyWith()).toList();
    for (final key in pathInfo.collectedKeys) {
      final kIdx = updatedKeys.indexWhere((k) => k.id == key.id);
      if (kIdx != -1) {
        updatedKeys[kIdx] = updatedKeys[kIdx].copyWith(isCollected: true);
        final lockId = updatedKeys[kIdx].targetLockId;

        // Unlock arrow matching lockId
        for (int i = 0; i < updatedArrows.length; i++) {
          if (updatedArrows[i].lockId == lockId || updatedArrows[i].id == lockId) {
            updatedArrows[i] = updatedArrows[i].copyWith(isLocked: false);
          }
        }

        // Unlock gate matching lockId
        for (int i = 0; i < updatedGates.length; i++) {
          if (updatedGates[i].id == lockId) {
            updatedGates[i] = updatedGates[i].copyWith(isOpen: true);
          }
        }
      }
    }

    // 4. Toggle moving walls linked to triggered switches
    final updatedWalls = board.movingWalls.map((w) => w.copyWith()).toList();
    for (final sw in pathInfo.triggeredSwitches) {
      for (int i = 0; i < updatedWalls.length; i++) {
        if (updatedWalls[i].linkedSwitchId == sw.id || updatedWalls[i].id == sw.targetGateId) {
          updatedWalls[i] = updatedWalls[i].copyWith(isMoved: !updatedWalls[i].isMoved);
        }
      }
    }

    // 5. Rotate section angles linked to triggered switches
    final updatedSections = board.rotatingSections.map((s) => s.copyWith()).toList();
    for (final sw in pathInfo.triggeredSwitches) {
      for (int i = 0; i < updatedSections.length; i++) {
        if (updatedSections[i].linkedSwitchId == sw.id || updatedSections[i].id == sw.targetGateId) {
          final nextAngle = (updatedSections[i].angleDegrees + 90) % 360;
          updatedSections[i] = updatedSections[i].copyWith(angleDegrees: nextAngle);
        }
      }
    }

    return Board(
      rows: board.rows,
      cols: board.cols,
      shapeDefinition: board.shapeDefinition,
      patternDefinition: board.patternDefinition,
      network: board.network,
      arrows: updatedArrows,
      gates: updatedGates,
      switches: updatedSwitches,
      keys: updatedKeys,
      portals: board.portals,
      iceCells: board.iceCells,
      obstacles: board.obstacles,
      movingWalls: updatedWalls,
      rotatingSections: updatedSections,
    );
  }

  /// Calculates the shortest/optimal solution step count.
  static int findOptimalMovesCount(Board board) {
    final solution = findSolution(board);
    return solution?.length ?? 0;
  }

  /// Finds the next best removable arrow ID for hints.
  static String? getHintArrowId(Board board) {
    final hint = getSmartHint(board, tier: 1);
    return hint?.targetArrowId;
  }

  /// Generates a multi-tier smart hint using actual solver state and network graph context.
  static PuzzleHint? getSmartHint(Board board, {int tier = 1}) {
    final solution = findSolution(board);
    if (solution == null || solution.isEmpty) {
      final removable = board.getRemovableArrows();
      if (removable.isEmpty) return null;
      final target = removable.first;
      return PuzzleHint(
        targetArrowId: target.id,
        explanation: 'Try clearing this arrow to break the impasse.',
        tier: tier,
      );
    }

    final targetId = solution.first;
    final arrow = board.arrows.firstWhere((a) => a.id == targetId);
    final pathInfo = board.calculateArrowPath(arrow);

    String? dependencyId;
    String explanation;

    if (board.network != null) {
      final node = board.network!.nodes.firstWhere(
        (n) => n.id == targetId,
        orElse: () => ArrowNode(
          id: targetId,
          row: arrow.row,
          col: arrow.column,
          direction: arrow.direction,
        ),
      );

      if (node.connectsToIds.isNotEmpty) {
        dependencyId = node.connectsToIds.first;
        explanation = 'Clear $targetId to release connected dependent arrow $dependencyId.';
      } else {
        explanation = 'Tap open arrow $targetId to start unravelling the network!';
      }
    } else if (pathInfo.triggeredSwitches.isNotEmpty) {
      dependencyId = pathInfo.triggeredSwitches.first.id;
      explanation = 'Clearing this arrow activates a switch to open a gate.';
    } else if (pathInfo.collectedKeys.isNotEmpty) {
      dependencyId = pathInfo.collectedKeys.first.id;
      explanation = 'Clearing this arrow collects a key to unlock the next path.';
    } else if (pathInfo.portalsTraversed.isNotEmpty) {
      dependencyId = pathInfo.portalsTraversed.first.id;
      explanation = 'This arrow travels through a portal exit.';
    } else {
      explanation = 'Tap this arrow to free up connected paths.';
    }

    return PuzzleHint(
      targetArrowId: targetId,
      dependencyId: dependencyId,
      explanation: explanation,
      tier: tier,
    );
  }
}
