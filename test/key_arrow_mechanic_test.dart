import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_escape/models/arrow_direction.dart';
import 'package:arrow_escape/models/arrow_piece.dart';
import 'package:arrow_escape/models/board.dart';

void main() {
  group('Final Key Arrow Transformation Mechanics', () {
    test('Final remaining arrow transforms into Key Arrow', () {
      const a1 = ArrowPiece(id: 'a1', row: 0, column: 0, direction: ArrowDirection.up, isStartArrow: true);
      const a2 = ArrowPiece(id: 'a2', row: 0, column: 2, direction: ArrowDirection.right, isKeyArrow: true);

      final initialBoard = Board(rows: 5, cols: 5, arrows: const [a1, a2]);
      expect(initialBoard.activeArrowCount, equals(2));

      // Remove 1st arrow (a1)
      final boardAfterA1 = initialBoard.removeArrow('a1');
      expect(boardAfterA1.activeArrowCount, equals(1));

      final remainingKey = boardAfterA1.finalKeyArrow;
      expect(remainingKey, isNotNull);
      expect(remainingKey!.id, equals('a2'));
      expect(remainingKey.isTransformedToKey, isTrue);
    });

    test('Tapping final transformed Key Arrow clears the board', () {
      const keyArrow = ArrowPiece(
        id: 'final_key',
        row: 0,
        column: 0,
        direction: ArrowDirection.up,
        isKeyArrow: true,
        isTransformedToKey: true,
      );

      final board = Board(rows: 5, cols: 5, arrows: const [keyArrow]);
      final clearedBoard = board.removeArrow('final_key');

      expect(clearedBoard.isCleared, isTrue);
      expect(clearedBoard.activeArrowCount, equals(0));
    });
  });
}
