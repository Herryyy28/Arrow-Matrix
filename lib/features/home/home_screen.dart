import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../game/arrows/arrow_painter.dart';
import '../../game/generator/level_generator.dart';
import '../../models/arrow_direction.dart';
import '../../models/level_data.dart';
import '../../services/storage_service.dart';
import '../../widgets/interactive_button.dart';
import '../../widgets/mini_puzzle_preview.dart';
import '../daily_challenge/daily_challenge_screen.dart';
import '../gameplay/game_screen.dart';
import '../settings/settings_screen.dart';
import '../worlds/worlds_screen.dart';
import '../statistics/statistics_screen.dart';
import '../achievements/achievements_screen.dart';

import '../../widgets/game_environment_widget.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storageService;
  final ValueNotifier<ThemeMode> themeModeNotifier;

  const HomeScreen({
    super.key,
    required this.storageService,
    required this.themeModeNotifier,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late int _currentLevel;
  late int _highestUnlocked;
  late int _bestScore;
  late int _dailyStreak;
  LevelData? _previewLevelData;
  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    final reduceMotion = widget.storageService.isReduceMotion();
    _entranceController = AnimationController(
      vsync: this,
      duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOut));
    _loadStats();
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _loadStats() {
    final lvl = widget.storageService.getCurrentLevel();
    final unlocked = widget.storageService.getHighestUnlockedLevel();
    final best = widget.storageService.getBestScore();
    final streak = widget.storageService.getDailyStreak();

    if (_previewLevelData == null || _previewLevelData!.levelNumber != lvl) {
      _previewLevelData = LevelGenerator.generateLevel(lvl);
    }

    setState(() {
      _currentLevel = lvl;
      _highestUnlocked = unlocked;
      _bestScore = best;
      _dailyStreak = streak;
    });
  }

  String _getDifficultyName(int level) {
    if (level <= 25) return 'EASY';
    if (level <= 50) return 'MEDIUM';
    if (level <= 75) return 'HARD';
    return 'EXPERT';
  }

  Color _getDifficultyColor(int level) {
    if (level <= 25) return AppColors.success;
    if (level <= 50) return AppColors.warning;
    if (level <= 75) return AppColors.primary;
    return AppColors.secondary;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = widget.storageService.isReduceMotion();
    final progressRatio = (_highestUnlocked / AppConstants.totalLevels).clamp(0.0, 1.0);

    return Scaffold(
      body: GameEnvironmentWidget(
        isDark: isDark,
        child: SafeArea(
          child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Bar: Brand & Settings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CustomPaint(
                              painter: ArrowPainter(
                                direction: ArrowDirection.up,
                                isHighlighted: true,
                                isDark: isDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'AMAZE GO!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                'CONNECTED ARROW NETWORKS',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton.filledTonal(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SettingsScreen(
                                storageService: widget.storageService,
                                themeModeNotifier: widget.themeModeNotifier,
                              ),
                            ),
                          );
                          _loadStats();
                        },
                        icon: const Icon(Icons.settings_rounded),
                        tooltip: 'Settings',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // DYNAMIC SHOWCASE CARD (Continue Journey)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? AppColors.gridBorderDark : AppColors.gridBorderLight,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CURRENT JOURNEY',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Level $_currentLevel',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(_currentLevel).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getDifficultyName(_currentLevel),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getDifficultyColor(_currentLevel),
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Progress Bar
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: progressRatio,
                                  minHeight: 8,
                                  backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$_highestUnlocked/${AppConstants.totalLevels}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Dynamic Mini Puzzle Preview & Action
                        Row(
                          children: [
                            MiniPuzzlePreview(levelData: _previewLevelData!, size: 100),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _previewLevelData!.shapeDefinition != null
                                        ? '${_previewLevelData!.shapeDefinition!.name} Shape'
                                        : '${_previewLevelData!.initialArrows.length} Arrows Grid',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Clear all vectors to unlock Level ${_currentLevel + 1}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  InteractiveButton(
                                    reduceMotion: reduceMotion,
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => GameScreen(
                                            levelNumber: _currentLevel,
                                            storageService: widget.storageService,
                                          ),
                                        ),
                                      );
                                      _loadStats();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                                            SizedBox(width: 4),
                                            Text(
                                              'PLAY LEVEL',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // DAILY CHALLENGE CARD
                  InteractiveButton(
                    reduceMotion: reduceMotion,
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DailyChallengeScreen(storageService: widget.storageService),
                        ),
                      );
                      _loadStats();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppColors.gridBorderDark : AppColors.gridBorderLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.event_available_rounded, color: AppColors.secondary, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DAILY CHALLENGE',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Streak: $_dailyStreak Days 🔥',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // WORLDS, STATS & ACHIEVEMENTS QUICK ACTIONS
                  Row(
                    children: [
                      Expanded(
                        child: InteractiveButton(
                          reduceMotion: reduceMotion,
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WorldsScreen(storageService: widget.storageService),
                              ),
                            );
                            _loadStats();
                          },
                          child: _QuickActionTile(
                            icon: Icons.map_rounded,
                            label: 'WORLDS',
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InteractiveButton(
                          reduceMotion: reduceMotion,
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StatisticsScreen(storageService: widget.storageService),
                              ),
                            );
                            _loadStats();
                          },
                          child: _QuickActionTile(
                            icon: Icons.bar_chart_rounded,
                            label: 'STATS',
                            color: Colors.teal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InteractiveButton(
                          reduceMotion: reduceMotion,
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AchievementsScreen(storageService: widget.storageService),
                              ),
                            );
                            _loadStats();
                          },
                          child: _QuickActionTile(
                            icon: Icons.workspace_premium_rounded,
                            label: 'TROPHIES',
                            color: Colors.purple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // STATS BAR
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.emoji_events_rounded,
                          title: 'BEST SCORE',
                          value: '$_bestScore',
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.grid_view_rounded,
                          title: 'UNLOCKED',
                          value: '$_highestUnlocked',
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ),
),
);
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.gridBorderDark : AppColors.gridBorderLight,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.gridBorderDark : AppColors.gridBorderLight,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
