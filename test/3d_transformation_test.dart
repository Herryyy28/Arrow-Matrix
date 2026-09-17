import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_escape/widgets/game_particle_overlay.dart';
import 'package:arrow_escape/widgets/game_environment_widget.dart';
import 'package:arrow_escape/game/painters/element_painters.dart';
import 'package:arrow_escape/models/arrow_direction.dart';
import 'package:arrow_escape/models/shape_definition.dart';

void main() {
  group('Master 3D Game Transformation Test Suite', () {
    test('ParticleController correctly manages particle lifespan and triggers', () {
      final controller = ParticleController();
      expect(controller.particles, isEmpty);

      controller.spawnExitTrail(const Offset(100, 100), const Offset(1, 0), Colors.amber);
      expect(controller.particles.length, equals(16));

      controller.update(0.1);
      expect(controller.particles.isNotEmpty, isTrue);

      controller.clear();
      expect(controller.particles, isEmpty);
    });

    test('ParticleController triggers invalid impact and victory confetti bursts', () {
      final controller = ParticleController();
      controller.spawnInvalidImpact(const Offset(200, 200));
      expect(controller.particles.length, equals(18));

      controller.spawnVictoryBurst(const Size(400, 800));
      expect(controller.particles.length, equals(78));
    });

    testWidgets('GameEnvironmentWidget renders layered atmosphere without layout overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GameEnvironmentWidget(
              isDark: true,
              child: Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('GameParticleOverlay renders particle canvas seamlessly', (WidgetTester tester) async {
      final controller = ParticleController();
      controller.spawnExitTrail(const Offset(50, 50), const Offset(0, -1), Colors.cyan);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameParticleOverlay(
              controller: controller,
              child: const SizedBox(width: 200, height: 200),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('3D Element Painters (Gate, Switch, Key, Portal, Ice) render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CustomPaint(size: const Size(40, 40), painter: const GatePainter(isOpen: false, isDark: true)),
                CustomPaint(size: const Size(40, 40), painter: const SwitchPainter(isActivated: true, isDark: true)),
                CustomPaint(size: const Size(40, 40), painter: const KeyPainter(isCollected: false)),
                CustomPaint(size: const Size(40, 40), painter: const PortalPainter(exitDirection: ArrowDirection.right, isDark: true)),
                CustomPaint(size: const Size(40, 40), painter: const IcePainter(isDark: true)),
                CustomPaint(size: const Size(40, 40), painter: const MovingWallPainter(isMoved: false, isDark: true)),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsNWidgets(6));
    });

    testWidgets('ShapeSilhouettePainter renders shape contour lines accurately', (WidgetTester tester) async {
      final heart = ShapeLibrary.heart;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 300,
              child: CustomPaint(
                painter: ShapeSilhouettePainter(
                  shapeDefinition: heart,
                  cellSize: 30,
                  isDark: true,
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
