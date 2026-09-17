import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize SharedPreferences local storage
  final storageService = await StorageService.init();

  runApp(ArrowEscapeApp(storageService: storageService));
}

class ArrowEscapeApp extends StatefulWidget {
  final StorageService storageService;

  const ArrowEscapeApp({
    super.key,
    required this.storageService,
  });

  @override
  State<ArrowEscapeApp> createState() => _ArrowEscapeAppState();
}

class _ArrowEscapeAppState extends State<ArrowEscapeApp> {
  late final ValueNotifier<ThemeMode> _themeModeNotifier;

  @override
  void initState() {
    super.initState();
    _themeModeNotifier = ValueNotifier(widget.storageService.getThemeMode());
  }

  @override
  void dispose() {
    _themeModeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Arrow Matrix',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: SplashScreen(
            storageService: widget.storageService,
            themeModeNotifier: _themeModeNotifier,
          ),
        );
      },
    );
  }
}
