import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_escape/models/shape_definition.dart';
import 'package:arrow_escape/core/theme/game_theme.dart';
import 'package:arrow_escape/models/board.dart';
import 'package:arrow_escape/models/arrow_piece.dart';
import 'package:arrow_escape/models/arrow_direction.dart';
import 'package:arrow_escape/game/solver/puzzle_validator.dart';
import 'package:arrow_escape/game/arrows/arrow_painter.dart';

void main() {
  group('3D Giraffe & Dark Theme Update Verification', () {
    test('ShapeLibrary.giraffe3D is properly defined and registered', () {
      final giraffe = ShapeLibrary.giraffe3D;
      expect(giraffe.id, 'shape_giraffe_3d');
      expect(giraffe.name, '3D Giraffe');
      expect(giraffe.category, ShapeCategory.animals);
      expect(giraffe.rows, 9);
      expect(giraffe.cols, 8);
      expect(ShapeLibrary.allShapes.contains(giraffe), isTrue);
      expect(ShapeLibrary.getById('shape_giraffe_3d'), equals(giraffe));
    });

    test('3D Giraffe shape board creates playable mask cells', () {
      final giraffe = ShapeLibrary.giraffe3D;
      int playableCellCount = 0;
      for (int r = 0; r < giraffe.rows; r++) {
        for (int c = 0; c < giraffe.cols; c++) {
          if (giraffe.isPlayable(r, c)) playableCellCount++;
        }
      }
      expect(playableCellCount, greaterThan(15));
    });

    test('PuzzleValidator verifies solvability on 3D Giraffe shape board', () {
      final giraffe = ShapeLibrary.giraffe3D;
      final board = Board(
        rows: giraffe.rows,
        cols: giraffe.cols,
        shapeDefinition: giraffe,
        arrows: [
          const ArrowPiece(
            id: 'g_arrow_1',
            row: 1,
            column: 3,
            direction: ArrowDirection.up,
          ),
          const ArrowPiece(
            id: 'g_arrow_2',
            row: 6,
            column: 1,
            direction: ArrowDirection.left,
          ),
        ],
      );

      final result = PuzzleValidator.validate(board);
      expect(result.isValid, isTrue);
      expect(result.stepCount, equals(2));
    });

    test('GameThemeData resolves 3D Giraffe Obsidian theme correctly', () {
      final theme = GameThemeData.getTheme('giraffe');
      expect(theme.preset, ThemePreset.giraffe);
      expect(theme.name, '3D Giraffe Obsidian');
      expect(theme.primary, const Color(0xFFFFB000));
      expect(theme.background, const Color(0xFF050508));
    });

    testWidgets('ArrowPainter renders 3D block specular highlight without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: ArrowPainter(
                    direction: ArrowDirection.right,
                    isDark: true,
                    isHighlighted: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsOneWidget);
    });
  });
}
