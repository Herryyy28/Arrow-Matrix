import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/storage_service.dart';
import '../../widgets/amaze_logo_widget.dart';
import '../../game/puzzle/repository/puzzle_repository.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  final StorageService storageService;
  final ValueNotifier<ThemeMode> themeModeNotifier;

  const SplashScreen({
    super.key,
    required this.storageService,
    required this.themeModeNotifier,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    final reduceMotion = widget.storageService.isReduceMotion();

    _animController = AnimationController(
      duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 450),
      vsync: this,
    );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _startStartupSequence();
  }

  Future<void> _startStartupSequence() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animController.forward();
      }
    });

    // Initialize PuzzleRepository (first launch generates levels 1-50, then background stages 51-1000)
    final repository = PuzzleRepository(storageService: widget.storageService);
    await repository.init();

    // Fast, non-blocking startup delay (500ms max)
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    // Navigate to HomeScreen with smooth cross-fade transition
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(
          storageService: widget.storageService,
          themeModeNotifier: widget.themeModeNotifier,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: AmazeLogoWidget(
              size: 130.0,
              isDark: isDark,
            ),
          ),
        ),
      ),
    );
  }
}
