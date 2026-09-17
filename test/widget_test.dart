import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_escape/main.dart';
import 'package:arrow_escape/services/storage_service.dart';
import 'package:arrow_escape/features/settings/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App renders HomeScreen with title and play button', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.init();

    await tester.pumpWidget(ArrowEscapeApp(storageService: storageService));
    await tester.pumpAndSettle();

    expect(find.text('AMAZE GO!'), findsOneWidget);
    expect(find.text('PLAY LEVEL'), findsOneWidget);
    expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
  });

  testWidgets('Navigating to Settings screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.init();

    await tester.pumpWidget(MaterialApp(
      home: SettingsScreen(
        storageService: storageService,
        themeModeNotifier: ValueNotifier(ThemeMode.system),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('Sound Effects'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
  });
}
