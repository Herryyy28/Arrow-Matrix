import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_escape/models/arrow_direction.dart';
import 'package:arrow_escape/models/arrow_piece.dart';
import 'package:arrow_escape/models/arrow_state.dart';
import 'package:arrow_escape/models/board.dart';

void main() {
  group('ArrowState & ArrowOccupancyModel Tests', () {
    test('ArrowState enum and effectiveState getter logic', () {
      const a1 = ArrowPiece(
        id: '1',
        row: 0,
        column: 0,
        direction: ArrowDirection.up,
        isRemoved: true,
      );
      expect(a1.effectiveState, equals(ArrowState.cleared));

      const a2 = ArrowPiece(
        id: '2',
        row: 1,
        column: 1,
        direction: ArrowDirection.down,
        isLocked: true,
      );
      expect(a2.effectiveState, equals(ArrowState.locked));

      const a3 = ArrowPiece(
        id: '3',
        row: 2,
        column: 2,
        direction: ArrowDirection.right,
        isMoving: true,
      );
      expect(a3.effectiveState, equals(ArrowState.moving));

      const a4 = ArrowPiece(
        id: '4',
        row: 3,
        column: 3,
        direction: ArrowDirection.left,
        state: ArrowState.available,
      );
      expect(a4.effectiveState, equals(ArrowState.available));
    });

    test('ArrowOccupancyModel cell claiming and releases', () {
      const a1 = ArrowPiece(
        id: 'a1',
        row: 0,
        column: 0,
        direction: ArrowDirection.right,
      );
      const a2 = ArrowPiece(
        id: 'a2',
        row: 0,
        column: 2,
        direction: ArrowDirection.down,
      );

      final board = Board(
        rows: 5,
        cols: 5,
        arrows: const [a1, a2],
      );

      final occupancy = board.occupancyModel;
      expect(occupancy.isCellOccupied(0, 0, 'a2'), isTrue);
      expect(occupancy.isCellOccupied(0, 0, 'a1'), isFalse);
      expect(occupancy.isCellOccupied(0, 2, 'a1'), isTrue);

      occupancy.releaseOccupancy('a1');
      expect(occupancy.isCellOccupied(0, 0, 'a2'), isFalse);
    });
  });
}
