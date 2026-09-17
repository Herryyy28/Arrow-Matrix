import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_escape/core/constants/app_colors.dart';
import 'package:arrow_escape/game/arrows/arrow_painter.dart';
import 'package:arrow_escape/models/arrow_direction.dart';
import 'package:arrow_escape/models/board.dart';
import 'package:arrow_escape/features/gameplay/widgets/board_widget.dart';
import 'package:arrow_escape/game/board/board_controller.dart';
import 'package:arrow_escape/services/storage_service.dart';
import 'package:arrow_escape/services/audio_service.dart';
import 'package:arrow_escape/services/haptic_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Premium 3D Arrow & Molded Tile System Test Suite', () {
    test('AppColors 3D design tokens are properly defined', () {
      expect(AppColors.primary, const Color(0xFFFF6B4A));
      expect(AppColors.primaryDepthWall, const Color(0xFFD43A19));
      expect(AppColors.warning, const Color(0xFFFFB000));
      expect(AppColors.cellBgLight, const Color(0xFFE2E8F0));
      expect(AppColors.cellBgDark, const Color(0xFF0F172A));
    });

    testWidgets('ArrowPainter renders 6-layer 3D molded arrow across all 4 directions', (WidgetTester tester) async {
      for (final dir in ArrowDirection.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CustomPaint(
                    painter: ArrowPainter(
                      direction: dir,
                      isDark: true,
                      isHighlighted: dir == ArrowDirection.up,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        expect(find.byType(CustomPaint), findsOneWidget);
      }
    });

    testWidgets('BoardWidget renders 3D molded cell wells and interactive tiles', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final audio = AudioService(storage);
      final haptic = HapticService(storage);

      final controller = BoardController(
        storageService: storage,
        audioService: audio,
        hapticService: haptic,
      );

      controller.loadLevel(1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 350,
              height: 350,
              child: BoardWidget(controller: controller),
            ),
          ),
        ),
      );

      expect(find.byType(BoardWidget), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
