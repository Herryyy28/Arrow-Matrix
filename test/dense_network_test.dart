import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_escape/models/arrow_direction.dart';
import 'package:arrow_escape/models/arrow_piece.dart';
import 'package:arrow_escape/models/arrow_network.dart';
import 'package:arrow_escape/models/board.dart';
import 'package:arrow_escape/game/solver/puzzle_solver.dart';

void main() {
  group('Gameplay 4.0 Polyline Bent Arrow & Path Tests', () {
    test('Polyline L-shaped bent arrow exit calculation', () {
      const bentArrow = ArrowPiece(
        id: 'bent_1',
        row: 0,
        column: 0,
        direction: ArrowDirection.down,
        pathPattern: [ArrowDirection.down, ArrowDirection.right],
      );

      final board = Board(
        rows: 5,
        cols: 5,
        arrows: const [bentArrow],
      );

      final path = board.calculateArrowPath(bentArrow);
      expect(path.isExitValid, isTrue);
      expect(path.pathCells.length, greaterThan(1));
    });

    test('False opening detection on multi-step trajectory', () {
      const arrow1 = ArrowPiece(
        id: 'a1',
        row: 0,
        column: 0,
        direction: ArrowDirection.down,
      );
      const blockerArrow = ArrowPiece(
        id: 'blocker',
        row: 2,
        column: 0,
        direction: ArrowDirection.right,
      );

      final board = Board(
        rows: 5,
        cols: 5,
        arrows: const [arrow1, blockerArrow],
      );

      final path = board.calculateArrowPath(arrow1);
      expect(path.isExitValid, isFalse);
      expect(path.blockedByArrow?.id, equals('blocker'));
    });

    test('Connected DAG graph dependency solver untangling', () {
      const nodes = [
        ArrowNode(id: 'n1', row: 0, col: 0, direction: ArrowDirection.up, connectsToIds: ['n2']),
        ArrowNode(id: 'n2', row: 0, col: 4, direction: ArrowDirection.up, dependsOnIds: ['n1']),
      ];
      final network = ArrowNetwork.fromNodeList(nodes);

      const a1 = ArrowPiece(id: 'n1', row: 0, column: 0, direction: ArrowDirection.up);
      const a2 = ArrowPiece(id: 'n2', row: 0, column: 4, direction: ArrowDirection.up);

      final board = Board(
        rows: 5,
        cols: 5,
        network: network,
        arrows: const [a1, a2],
      );

      // n2 depends on n1, so n2 cannot exit first
      expect(board.canArrowExit(a2), isFalse);
      // n1 has no dependencies, so n1 can exit first
      expect(board.canArrowExit(a1), isTrue);

      final solution = PuzzleSolver.findSolution(board);
      expect(solution, isNotNull);
      expect(solution!.first, equals('n1'));
    });
  });
}
