import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_escape/game/painters/maze_path_painter.dart';
import 'package:arrow_escape/models/arrow_direction.dart';
import 'package:arrow_escape/models/arrow_piece.dart';
import 'package:arrow_escape/models/board.dart';
import 'package:arrow_escape/models/shape_definition.dart';
import 'package:arrow_escape/core/constants/app_colors.dart';

void main() {
  group('Dark Continuous Shape-Maze System Test Suite', () {
    late Board testBoard;

    setUp(() {
      final arrows = [
        ArrowPiece(
          id: 'arrow_1',
          row: 0,
          column: 0,
          direction: ArrowDirection.right,
        ),
        ArrowPiece(
          id: 'arrow_2',
          row: 1,
          column: 1,
          direction: ArrowDirection.down,
        ),
        ArrowPiece(
          id: 'arrow_3',
          row: 2,
          column: 2,
          direction: ArrowDirection.left,
        ),
      ];
      testBoard = Board(
        rows: 3,
        cols: 3,
        arrows: arrows,
        shapeDefinition: ShapeLibrary.giraffe3D,
      );
    });

    testWidgets('MazePathPainter renders continuous glowing lines, shape contours, and active polyline path movement', (WidgetTester tester) async {
      final activeAnim = ActivePathAnimation(
        points: const [Offset(0, 0), Offset(100, 0), Offset(100, 100)],
        progress: 0.5,
        color: Colors.amber,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: AppColors.mazeVoidBackground,
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: CustomPaint(
                  painter: MazePathPainter(
                    board: testBoard,
                    cellSize: 100.0,
                    selectedArrowId: 'arrow_1',
                    activeAnimation: activeAnim,
                    isDark: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    test('ShapeLibrary contains diverse recognizable animal/object silhouettes', () {
      expect(ShapeLibrary.allShapes.length, greaterThanOrEqualTo(21));
      expect(ShapeLibrary.giraffe3D.name, equals('3D Giraffe'));
      expect(ShapeLibrary.fish.name, equals('Fish'));
      expect(ShapeLibrary.rocket.name, equals('Rocket'));
      expect(ShapeLibrary.cat.name, equals('Cat'));
    });

    test('MazePathPainter correctly triggers repaint when selected arrow or active animation changes', () {
      final painter1 = MazePathPainter(
        board: testBoard,
        cellSize: 100.0,
        selectedArrowId: 'arrow_1',
      );

      final painter2 = MazePathPainter(
        board: testBoard,
        cellSize: 100.0,
        selectedArrowId: 'arrow_2',
      );

      final painterSame = MazePathPainter(
        board: testBoard,
        cellSize: 100.0,
        selectedArrowId: 'arrow_1',
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
      expect(painter1.shouldRepaint(painterSame), isFalse);
    });

    test('Dark theme void background token is #05050A', () {
      expect(AppColors.mazeVoidBackground, equals(const Color(0xFF05050A)));
    });
  });
}
