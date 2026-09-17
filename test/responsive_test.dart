import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_escape/main.dart';
import 'package:arrow_escape/services/storage_service.dart';
import 'package:arrow_escape/features/gameplay/game_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testSizes = [
    const Size(320, 568),  // Compact Phone
    const Size(360, 640),  // Normal Phone
    const Size(390, 844),  // Modern Phone
    const Size(412, 915),  // Large Phone
    const Size(600, 960),  // Tablet Portrait
    const Size(800, 1280), // Large Tablet
  ];

  group('Responsive Screen Overflow & Rendering Tests', () {
    for (final size in testSizes) {
      testWidgets('HomeScreen renders without overflow at ${size.width}x${size.height}', (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        final storageService = await StorageService.init();

        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(ArrowEscapeApp(storageService: storageService));
        await tester.pumpAndSettle();

        expect(find.text('AMAZE GO!'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('GameScreen renders without overflow at ${size.width}x${size.height}', (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        final storageService = await StorageService.init();

        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(MaterialApp(
          home: GameScreen(levelNumber: 1, storageService: storageService),
        ));
        await tester.pumpAndSettle();

        expect(find.text('LEVEL 1'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
