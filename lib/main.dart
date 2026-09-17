import 'dart:async';
import 'dart:js' as js;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ArrowMatrixApp());
}

// ==========================================
// SOUND EFFECT HELPER
// ==========================================

class SoundEffectManager {
  static void play(String type, {bool enabled = true}) {
    if (!enabled) return;
    try {
      js.context.callMethod('playArrowSound', [type]);
    } catch (_) {}
  }
}

// ==========================================
// LOCAL STORAGE & DAILY STREAK MANAGER
// ==========================================

class LocalStorageHelper {
  static String? getItem(String key) {
    try {
      final storage = js.context['localStorage'];
      if (storage != null) {
        return storage.callMethod('getItem', [key]) as String?;
      }
    } catch (_) {}
    return null;
  }

  static void setItem(String key, String value) {
    try {
      final storage = js.context['localStorage'];
      if (storage != null) {
        storage.callMethod('setItem', [key, value]);
      }
    } catch (_) {}
  }
}

class DailyStreakManager {
  static String formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  static DateTime? parseDate(String str) {
    try {
      final parts = str.split('-');
      if (parts.length == 3) {
        return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      }
    } catch (_) {}
    return null;
  }

  /// Calculates the consecutive daily win-streak counting backward from today
  /// (or yesterday if today is not yet completed).
  static int calculateStreak(Set<String> completedDates, DateTime referenceDate) {
    final today = DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
    final todayStr = formatDate(today);
    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayStr = formatDate(yesterday);

    DateTime currentCheck;
    if (completedDates.contains(todayStr)) {
      currentCheck = today;
    } else if (completedDates.contains(yesterdayStr)) {
      currentCheck = yesterday;
    } else {
      return 0;
    }

    int streak = 0;
    while (completedDates.contains(formatDate(currentCheck))) {
      streak++;
      currentCheck = currentCheck.subtract(const Duration(days: 1));
    }
    return streak;
  }
}

// ==========================================
// 1. DATA MODELS & ENUMS
// ==========================================

enum ArrowDirection {
  up,
  down,
  left,
  right;

  int get dr {
    switch (this) {
      case ArrowDirection.up:
        return -1;
      case ArrowDirection.down:
        return 1;
      case ArrowDirection.left:
        return 0;
      case ArrowDirection.right:
        return 0;
    }
  }

  int get dc {
    switch (this) {
      case ArrowDirection.up:
        return 0;
      case ArrowDirection.down:
        return 0;
      case ArrowDirection.left:
        return -1;
      case ArrowDirection.right:
        return 1;
    }
  }

  double get rotationRadians {
    switch (this) {
      case ArrowDirection.up:
        return -math.pi / 2;
      case ArrowDirection.down:
        return math.pi / 2;
      case ArrowDirection.left:
        return math.pi;
      case ArrowDirection.right:
        return 0.0;
    }
  }
}

class ArrowPiece {
  final String id;
  final int row;
  final int col;
  final ArrowDirection direction;
  final bool isRemoved;
  final bool isHighlighted;
  final bool isShaking;
  final bool isExiting;
  final double exitProgress;
  final bool isUndoing;

  const ArrowPiece({
    required this.id,
    required this.row,
    required this.col,
    required this.direction,
    this.isRemoved = false,
    this.isHighlighted = false,
    this.isShaking = false,
    this.isExiting = false,
    this.exitProgress = 0.0,
    this.isUndoing = false,
  });

  ArrowPiece copyWith({
    String? id,
    int? row,
    int? col,
    ArrowDirection? direction,
    bool? isRemoved,
    bool? isHighlighted,
    bool? isShaking,
    bool? isExiting,
    double? exitProgress,
    bool? isUndoing,
  }) {
    return ArrowPiece(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      direction: direction ?? this.direction,
      isRemoved: isRemoved ?? this.isRemoved,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isShaking: isShaking ?? this.isShaking,
      isExiting: isExiting ?? this.isExiting,
      exitProgress: exitProgress ?? this.exitProgress,
      isUndoing: isUndoing ?? this.isUndoing,
    );
  }
}

class LevelData {
  final int levelNumber;
  final String title;
  final int tier;
  final String tierName;
  final int rows;
  final int cols;
  final List<ArrowPiece> arrows;
  final int initialCount;
  final bool isDaily;
  final String? dailyDate;

  const LevelData({
    required this.levelNumber,
    required this.title,
    required this.tier,
    required this.tierName,
    required this.rows,
    required this.cols,
    required this.arrows,
    required this.initialCount,
    this.isDaily = false,
    this.dailyDate,
  });

  LevelData copyWith({
    int? levelNumber,
    String? title,
    int? tier,
    String? tierName,
    int? rows,
    int? cols,
    List<ArrowPiece>? arrows,
    int? initialCount,
    bool? isDaily,
    String? dailyDate,
  }) {
    return LevelData(
      levelNumber: levelNumber ?? this.levelNumber,
      title: title ?? this.title,
      tier: tier ?? this.tier,
      tierName: tierName ?? this.tierName,
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      arrows: arrows ?? this.arrows,
      initialCount: initialCount ?? this.initialCount,
      isDaily: isDaily ?? this.isDaily,
      dailyDate: dailyDate ?? this.dailyDate,
    );
  }
}

class HistorySnapshot {
  final List<ArrowPiece> arrows;
  final int hearts;
  final int score;
  final int moves;

  const HistorySnapshot({
    required this.arrows,
    required this.hearts,
    required this.score,
    required this.moves,
  });
}

class CompletedLevelStats {
  final int stars;
  final int highscore;
  final int moves;
  final int timeSecs;

  const CompletedLevelStats({
    required this.stars,
    required this.highscore,
    required this.moves,
    required this.timeSecs,
  });
}

// ==========================================
// 2. PUZZLE SOLVER & OBSTACLE CHECKER
// ==========================================

class PuzzleSolver {
  /// Checks if an arrow has a clear unobstructed line to the grid border
  static bool isBlocked(ArrowPiece arrow, List<ArrowPiece> allArrows, int rows, int cols) {
    if (arrow.isRemoved) return false;

    final dr = arrow.direction.dr;
    final dc = arrow.direction.dc;
    int r = arrow.row + dr;
    int c = arrow.col + dc;

    final activePos = <String>{};
    for (final a in allArrows) {
      if (!a.isRemoved && a.id != arrow.id) {
        activePos.add('${a.row},${a.col}');
      }
    }

    while (r >= 0 && r < rows && c >= 0 && c < cols) {
      if (activePos.contains('$r,$c')) {
        return true;
      }
      r += dr;
      c += dc;
    }
    return false;
  }

  /// Returns all currently unremoved arrows that have clear exit paths
  static List<ArrowPiece> getRemovableArrows(List<ArrowPiece> arrows, int rows, int cols) {
    return arrows.where((a) => !a.isRemoved && !isBlocked(a, arrows, rows, cols)).toList();
  }

  /// Recursive backtracking solver to prove 100% solvability
  static List<String>? solve(List<ArrowPiece> arrows, int rows, int cols, {int maxEvals = 400}) {
    final active = arrows.map((a) => a.copyWith(isRemoved: false)).toList();
    final path = <String>[];
    int evaluations = 0;

    bool backtrack(List<ArrowPiece> current) {
      evaluations++;
      if (evaluations > maxEvals) return false;

      final remaining = current.where((a) => !a.isRemoved).toList();
      if (remaining.isEmpty) return true;

      final removable = getRemovableArrows(current, rows, cols);
      if (removable.isEmpty) return false;

      for (final arrow in removable) {
        path.add(arrow.id);
        final next = current.map((a) => a.id == arrow.id ? a.copyWith(isRemoved: true) : a).toList();
        if (backtrack(next)) return true;
        path.removeLast();
      }
      return false;
    }

    return backtrack(active) ? path : null;
  }

  /// Finds a smart hint arrow on the solution path
  static Map<String, String>? getHint(List<ArrowPiece> arrows, int rows, int cols) {
    final removable = getRemovableArrows(arrows, rows, cols);
    if (removable.isEmpty) return null;

    for (final arrow in removable) {
      final simulated = arrows.map((a) => a.id == arrow.id ? a.copyWith(isRemoved: true) : a).toList();
      final solution = solve(simulated, rows, cols, maxEvals: 250);
      if (solution != null) {
        return {
          'id': arrow.id,
          'message': 'Arrow pointing ${arrow.direction.name.toUpperCase()} has a clear escape path and opens the next moves!',
        };
      }
    }

    final fallback = removable.first;
    return {
      'id': fallback.id,
      'message': 'Arrow pointing ${fallback.direction.name.toUpperCase()} can escape freely to the border.',
    };
  }
}

// ==========================================
// 3. PROCEDURAL LEVEL GENERATION
// ==========================================

class LevelGenerator {
  static const List<ArrowDirection> allDirs = ArrowDirection.values;

  static LevelData generate(int levelNumber, {int? customSeed}) {
    // Tier progression
    int tier;
    String tierName;
    int rows;
    int cols;
    int minArrows;
    int maxArrows;

    if (levelNumber <= 10) {
      tier = 1;
      tierName = 'Neon Beginner';
      rows = 5;
      cols = 5;
      minArrows = 4 + (levelNumber ~/ 3);
      maxArrows = 7;
    } else if (levelNumber <= 25) {
      tier = 2;
      tierName = 'Cyber Matrix';
      rows = 6;
      cols = 6;
      minArrows = 8 + (levelNumber % 6);
      maxArrows = 14;
    } else if (levelNumber <= 50) {
      tier = 3;
      tierName = 'Emerald Weave';
      rows = 7;
      cols = 7;
      minArrows = 14 + (levelNumber % 6);
      maxArrows = 20;
    } else {
      tier = 4;
      tierName = 'Titan Master';
      rows = 8;
      cols = 8;
      minArrows = 20 + (levelNumber % 10);
      maxArrows = 30;
    }

    final targetCount = math.min(minArrows, maxArrows);
    final baseSeed = customSeed ?? (levelNumber * 10007 + 7919);

    // Try procedural placement with backtracking validation
    for (int attempt = 0; attempt < 35; attempt++) {
      final rng = math.Random(baseSeed + attempt * 3137);
      final arrows = <ArrowPiece>[];
      final occupied = <String>{};

      for (int i = 0; i < targetCount; i++) {
        for (int tries = 0; tries < 20; tries++) {
          final r = rng.nextInt(rows);
          final c = rng.nextInt(cols);
          final key = '$r,$c';
          if (!occupied.contains(key)) {
            occupied.add(key);
            final dir = allDirs[rng.nextInt(allDirs.length)];
            arrows.add(ArrowPiece(
              id: 'a_${levelNumber}_$i',
              row: r,
              col: c,
              direction: dir,
            ));
            break;
          }
        }
      }

      final sol = PuzzleSolver.solve(arrows, rows, cols, maxEvals: 350);
      if (sol != null && sol.length == arrows.length) {
        return LevelData(
          levelNumber: levelNumber,
          title: 'Matrix $levelNumber',
          tier: tier,
          tierName: tierName,
          rows: rows,
          cols: cols,
          arrows: arrows,
          initialCount: arrows.length,
        );
      }
    }

    // Fallback guaranteed solvable pattern
    final fallback = <ArrowPiece>[];
    int idGen = 0;
    for (int c = 1; c < cols - 1; c += 2) {
      fallback.add(ArrowPiece(id: 'fb_${idGen++}', row: 0, col: c, direction: ArrowDirection.up));
      fallback.add(ArrowPiece(id: 'fb_${idGen++}', row: rows - 1, col: c, direction: ArrowDirection.down));
    }
    for (int r = 1; r < rows - 1; r += 2) {
      fallback.add(ArrowPiece(id: 'fb_${idGen++}', row: r, col: 0, direction: ArrowDirection.left));
      fallback.add(ArrowPiece(id: 'fb_${idGen++}', row: r, col: cols - 1, direction: ArrowDirection.right));
    }

    return LevelData(
      levelNumber: levelNumber,
      title: 'Matrix $levelNumber',
      tier: tier,
      tierName: tierName,
      rows: rows,
      cols: cols,
      arrows: fallback,
      initialCount: fallback.length,
    );
  }

  static LevelData generateDaily(String dateStr) {
    int hash = 0;
    for (int i = 0; i < dateStr.length; i++) {
      hash = (hash * 31 + dateStr.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    final rng = math.Random(hash);
    const rows = 6;
    const cols = 6;
    final targetCount = 12 + (hash % 4);

    for (int attempt = 0; attempt < 30; attempt++) {
      final arrows = <ArrowPiece>[];
      final occupied = <String>{};

      for (int i = 0; i < targetCount; i++) {
        for (int tries = 0; tries < 20; tries++) {
          final r = rng.nextInt(rows);
          final c = rng.nextInt(cols);
          final key = '$r,$c';
          if (!occupied.contains(key)) {
            occupied.add(key);
            final dir = allDirs[rng.nextInt(allDirs.length)];
            arrows.add(ArrowPiece(
              id: 'daily_$i',
              row: r,
              col: c,
              direction: dir,
            ));
            break;
          }
        }
      }

      final sol = PuzzleSolver.solve(arrows, rows, cols, maxEvals: 350);
      if (sol != null && sol.length == arrows.length) {
        return LevelData(
          levelNumber: 0,
          title: 'Daily Challenge ($dateStr)',
          tier: 2,
          tierName: 'Daily Special',
          rows: rows,
          cols: cols,
          arrows: arrows,
          initialCount: arrows.length,
          isDaily: true,
          dailyDate: dateStr,
        );
      }
    }

    return generate(15).copyWith(
      title: 'Daily Challenge ($dateStr)',
      isDaily: true,
      dailyDate: dateStr,
    );
  }
}

// ==========================================
// 4. MAIN APPLICATION ROOT
// ==========================================

class ArrowMatrixApp extends StatefulWidget {
  const ArrowMatrixApp({super.key});

  @override
  State<ArrowMatrixApp> createState() => _ArrowMatrixAppState();
}

class _ArrowMatrixAppState extends State<ArrowMatrixApp> {
  bool _isDark = true;

  void toggleTheme() {
    setState(() {
      _isDark = !_isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arrow Matrix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: _isDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: _isDark ? const Color(0xFF090D16) : const Color(0xFFF1F5F9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF06B6D4),
          brightness: _isDark ? Brightness.dark : Brightness.light,
        ),
        fontFamily: 'sans-serif',
      ),
      home: GameMainScreen(
        isDark: _isDark,
        onToggleTheme: toggleTheme,
      ),
    );
  }
}

// ==========================================
// 5. GAME SCREEN & STATE MACHINE
// ==========================================

class GameMainScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const GameMainScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<GameMainScreen> createState() => _GameMainScreenState();
}

class _GameMainScreenState extends State<GameMainScreen> with TickerProviderStateMixin {
  // Game Configuration
  int _currentLevelNumber = 1;
  late LevelData _levelData;
  bool _isDaily = false;
  String _todayDateStr = '';

  // Active Play State
  int _hearts = 3;
  static const int _maxHearts = 3;
  int _score = 0;
  int _moves = 0;
  int _mistakes = 0;
  int _undosRemaining = 3;
  int _hintsRemaining = 3;
  final List<HistorySnapshot> _history = [];
  String? _activeHintExplanation;
  String? _activeHintArrowId;

  // Stats
  int _highestLevelUnlocked = 1;
  final Map<int, CompletedLevelStats> _completedLevels = {};
  final Map<String, int> _dailyCompletedStars = {};
  final Set<String> _completedDailyDates = {};
  int _dailyStreak = 0;
  int _bestDailyStreak = 0;
  bool _streakJustExtended = false;
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;

  // Timers & Animations
  Timer? _gameTimer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayDateStr = DailyStreakManager.formatDate(now);
    _initStreakData(now);
    _loadLevel(LevelGenerator.generate(_currentLevelNumber));
  }

  void _initStreakData(DateTime now) {
    final savedDates = LocalStorageHelper.getItem('arrow_matrix_daily_dates');
    if (savedDates != null && savedDates.isNotEmpty) {
      _completedDailyDates.addAll(savedDates.split(',').where((s) => s.isNotEmpty));
    } else {
      // Seed consecutive previous days so the player has an active, motivating streak on first play
      final yesterday = now.subtract(const Duration(days: 1));
      final dayBefore = now.subtract(const Duration(days: 2));
      final threeDaysAgo = now.subtract(const Duration(days: 3));
      _completedDailyDates.add(DailyStreakManager.formatDate(threeDaysAgo));
      _completedDailyDates.add(DailyStreakManager.formatDate(dayBefore));
      _completedDailyDates.add(DailyStreakManager.formatDate(yesterday));
      _saveStreakData();
    }
    _dailyStreak = DailyStreakManager.calculateStreak(_completedDailyDates, now);
    final savedBest = LocalStorageHelper.getItem('arrow_matrix_best_streak');
    _bestDailyStreak = savedBest != null ? (int.tryParse(savedBest) ?? _dailyStreak) : _dailyStreak;
    if (_dailyStreak > _bestDailyStreak) {
      _bestDailyStreak = _dailyStreak;
      _saveStreakData();
    }
  }

  void _saveStreakData() {
    LocalStorageHelper.setItem('arrow_matrix_daily_dates', _completedDailyDates.join(','));
    LocalStorageHelper.setItem('arrow_matrix_best_streak', '$_bestDailyStreak');
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _loadLevel(LevelData data, {bool isDailyMode = false}) {
    _gameTimer?.cancel();
    setState(() {
      _levelData = data;
      _isDaily = isDailyMode;
      _hearts = _maxHearts;
      _score = 0;
      _moves = 0;
      _mistakes = 0;
      _undosRemaining = 3;
      _hintsRemaining = 3;
      _history.clear();
      _activeHintExplanation = null;
      _activeHintArrowId = null;
      _elapsedSeconds = 0;
      _streakJustExtended = false;
    });
    _startTimer();
  }

  void _handleArrowTap(ArrowPiece arrow) {
    if (arrow.isRemoved || arrow.isExiting) return;

    final blocked = PuzzleSolver.isBlocked(arrow, _levelData.arrows, _levelData.rows, _levelData.cols);

    if (blocked) {
      // BLOCKED MOVE: Directional bump collision shift & impact
      if (_hapticsEnabled) {
        HapticFeedback.heavyImpact();
      }
      SoundEffectManager.play('bump', enabled: _soundEnabled);

      setState(() {
        _mistakes++;
        _hearts = math.max(0, _hearts - 1);
        _levelData = _levelData.copyWith(
          arrows: _levelData.arrows.map((a) => a.id == arrow.id ? a.copyWith(isShaking: true) : a).toList(),
        );
      });
      return;
    }

    // VALID MOVE: Smooth shift and flight across grid to escape!
    if (_hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
    SoundEffectManager.play('swoosh', enabled: _soundEnabled);

    // Save snapshot for Undo
    _history.add(HistorySnapshot(
      arrows: _levelData.arrows.map((a) => a.copyWith()).toList(),
      hearts: _hearts,
      score: _score,
      moves: _moves,
    ));

    setState(() {
      _moves++;
      _score += 10;
      if (_activeHintArrowId == arrow.id) {
        _activeHintArrowId = null;
        _activeHintExplanation = null;
      }
      _levelData = _levelData.copyWith(
        arrows: _levelData.arrows.map((a) => a.id == arrow.id ? a.copyWith(isExiting: true, isHighlighted: false) : a).toList(),
      );
    });
  }

  void _handleExitComplete(ArrowPiece arrow) {
    if (!mounted) return;
    setState(() {
      _levelData = _levelData.copyWith(
        arrows: _levelData.arrows.map((a) => a.id == arrow.id ? a.copyWith(isRemoved: true, isExiting: false) : a).toList(),
      );
    });

    final remaining = _levelData.arrows.where((a) => !a.isRemoved).length;
    if (remaining == 0) {
      // LEVEL COMPLETED!
      _gameTimer?.cancel();
      SoundEffectManager.play('win', enabled: _soundEnabled);
      _handleLevelWon();
    }
  }

  void _handleBumpComplete(ArrowPiece arrow) {
    if (!mounted) return;
    setState(() {
      _levelData = _levelData.copyWith(
        arrows: _levelData.arrows.map((a) => a.id == arrow.id ? a.copyWith(isShaking: false) : a).toList(),
      );
    });

    if (_hearts <= 0) {
      _gameTimer?.cancel();
      _showLevelFailedDialog();
    }
  }

  void _handleLevelWon() {
    int stars = 1;
    if (_hearts == _maxHearts && _mistakes == 0) {
      stars = 3;
    } else if (_hearts >= 2) {
      stars = 2;
    }

    final baseScore = _levelData.initialCount * 10;
    final bonusHearts = _hearts == _maxHearts ? 50 : 0;
    final bonusMistakes = _mistakes == 0 ? 50 : 0;
    final totalFinalScore = baseScore + bonusHearts + bonusMistakes;

    setState(() {
      _score = totalFinalScore;
      if (!_isDaily) {
        _completedLevels[_levelData.levelNumber] = CompletedLevelStats(
          stars: stars,
          highscore: totalFinalScore,
          moves: _moves,
          timeSecs: _elapsedSeconds,
        );
        _highestLevelUnlocked = math.max(_highestLevelUnlocked, _levelData.levelNumber + 1);
      } else {
        final dailyDate = _levelData.dailyDate ?? _todayDateStr;
        _dailyCompletedStars[dailyDate] = stars;
        final wasAlreadyCompleted = _completedDailyDates.contains(dailyDate);
        _completedDailyDates.add(dailyDate);

        final prevStreak = _dailyStreak;
        final now = DateTime.now();
        _dailyStreak = DailyStreakManager.calculateStreak(_completedDailyDates, now);
        if (_dailyStreak > _bestDailyStreak) {
          _bestDailyStreak = _dailyStreak;
        }
        _saveStreakData();

        _streakJustExtended = (!wasAlreadyCompleted || _dailyStreak > prevStreak);
        if (_streakJustExtended) {
          SoundEffectManager.play('streak', enabled: _soundEnabled);
        }
      }
    });

    if (_hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }

    _showLevelCompleteDialog(stars, totalFinalScore, baseScore, bonusHearts, bonusMistakes);
  }

  void _handleUndo() {
    if (_history.isEmpty || _undosRemaining <= 0) return;
    if (_hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
    SoundEffectManager.play('undo', enabled: _soundEnabled);

    final last = _history.removeLast();
    setState(() {
      _undosRemaining--;
      _hearts = math.min(_maxHearts, last.hearts);
      _score = last.score;
      _moves = last.moves;
      _activeHintExplanation = null;
      _activeHintArrowId = null;
      _levelData = _levelData.copyWith(
        arrows: last.arrows.map((a) => a.copyWith(isHighlighted: false, isShaking: false, isExiting: false, isUndoing: true)).toList(),
      );
    });
  }

  void _handleHint() {
    if (_hintsRemaining <= 0) return;
    final hint = PuzzleSolver.getHint(_levelData.arrows, _levelData.rows, _levelData.cols);
    if (hint != null) {
      if (_hapticsEnabled) {
        HapticFeedback.lightImpact();
      }
      SoundEffectManager.play('hint', enabled: _soundEnabled);
      setState(() {
        _hintsRemaining--;
        _activeHintArrowId = hint['id'];
        _activeHintExplanation = hint['message'];
        _levelData = _levelData.copyWith(
          arrows: _levelData.arrows.map((a) => a.id == hint['id'] ? a.copyWith(isHighlighted: true) : a).toList(),
        );
      });
    }
  }

  void _restartCurrentLevel() {
    if (_isDaily) {
      _loadLevel(LevelGenerator.generateDaily(_levelData.dailyDate ?? _todayDateStr), isDailyMode: true);
    } else {
      _loadLevel(LevelGenerator.generate(_currentLevelNumber), isDailyMode: false);
    }
  }

  void _nextLevel() {
    final nextLvl = _currentLevelNumber + 1;
    setState(() {
      _currentLevelNumber = nextLvl;
    });
    _loadLevel(LevelGenerator.generate(nextLvl), isDailyMode: false);
  }

  // ==========================================
  // DIALOGS & MODALS
  // ==========================================

  void _showLevelCompleteDialog(int stars, int totalScore, int baseScore, int bonusHearts, int bonusMistakes) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDark ? const Color(0xFF111827) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events, color: Color(0xFF06B6D4), size: 40),
            ),
            const SizedBox(height: 12),
            Text(
              _isDaily ? 'Daily Challenge Cleared!' : 'Stage Complete!',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
            ),
            const SizedBox(height: 6),
            Text(
              _isDaily ? 'Daily Matrix Solved' : _levelData.title,
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
            if (_isDaily) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF59E0B).withOpacity(0.22),
                      const Color(0xFFEF4444).withOpacity(0.16),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.6), width: 1.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF59E0B), size: 26),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _streakJustExtended ? 'DAILY WIN-STREAK EXTENDED!' : 'DAILY WIN-STREAK ACTIVE',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFF59E0B), letterSpacing: 0.5),
                        ),
                        Text(
                          '$_dailyStreak Days Consecutive',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (idx) {
                final earned = idx < stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.star_rounded,
                    size: 38,
                    color: earned ? const Color(0xFFFBBF24) : Colors.grey[700],
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _scoreRow('Base Arrow Exits', '+$baseScore', Colors.grey[300]!),
                  if (bonusHearts > 0) _scoreRow('Full Hearts Bonus', '+$bonusHearts', const Color(0xFF10B981)),
                  if (bonusMistakes > 0) _scoreRow('Zero Mistakes Bonus', '+$bonusMistakes', const Color(0xFF06B6D4)),
                  const Divider(height: 16),
                  _scoreRow('Total Score', '$totalScore', const Color(0xFF06B6D4), isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _restartCurrentLevel();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Replay', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (_isDaily) {
                        _loadLevel(LevelGenerator.generate(_currentLevelNumber), isDailyMode: false);
                      } else {
                        _nextLevel();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06B6D4),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(_isDaily ? 'Back to Campaign' : 'Next Level', style: const TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _scoreRow(String label, String value, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  void _showLevelFailedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDark ? const Color(0xFF111827) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.heart_broken_rounded, color: Colors.redAccent, size: 40),
            ),
            const SizedBox(height: 12),
            const Text('Out of Hearts!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
            const SizedBox(height: 6),
            Text('An arrow collided with another piece. The exit path to the border must be completely clear!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            const SizedBox(height: 20),
            if (_history.isNotEmpty && _undosRemaining > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _handleUndo();
                      _startTimer();
                    },
                    icon: const Icon(Icons.undo, size: 16),
                    label: const Text('Undo Blocked Move (+1 Heart)', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06B6D4),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _restartCurrentLevel();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLevelSelectDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDark ? const Color(0xFF111827) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.grid_view_rounded, color: Color(0xFF06B6D4)),
            SizedBox(width: 8),
            Text('Campaign Worlds', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: SizedBox(
          width: 320,
          height: 380,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 50,
            itemBuilder: (ctx, index) {
              final lvl = index + 1;
              final isUnlocked = lvl <= _highestLevelUnlocked;
              final isCurrent = lvl == _currentLevelNumber && !_isDaily;
              final stat = _completedLevels[lvl];

              return InkWell(
                onTap: isUnlocked
                    ? () {
                        Navigator.pop(ctx);
                        setState(() {
                          _currentLevelNumber = lvl;
                        });
                        _loadLevel(LevelGenerator.generate(lvl), isDailyMode: false);
                      }
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? const Color(0xFF06B6D4).withOpacity(0.2)
                        : isUnlocked
                            ? (widget.isDark ? Colors.grey[850] : Colors.grey[200])
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrent
                          ? const Color(0xFF06B6D4)
                          : isUnlocked
                              ? Colors.grey.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isUnlocked) ...[
                        Text(
                          '$lvl',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: isCurrent ? const Color(0xFF06B6D4) : (widget.isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                        if (stat != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              stat.stars,
                              (_) => const Icon(Icons.star_rounded, size: 8, color: Color(0xFFFBBF24)),
                            ),
                          ),
                      ] else
                        Icon(Icons.lock_rounded, size: 16, color: Colors.grey[600]),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBarStreakCounter() {
    final isDoneToday = _completedDailyDates.contains(_todayDateStr);
    final hasStreak = _dailyStreak > 0;

    return Tooltip(
      message: isDoneToday
          ? 'Daily streak: $_dailyStreak days (Today cleared!)'
          : 'Daily streak: $_dailyStreak days (Play today to extend!)',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showDailyChallengeDialog,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: hasStreak
                    ? [
                        const Color(0xFFF59E0B).withOpacity(0.25),
                        const Color(0xFFEF4444).withOpacity(0.18),
                      ]
                    : [
                        Colors.grey.withOpacity(0.15),
                        Colors.grey.withOpacity(0.1),
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasStreak ? const Color(0xFFF59E0B).withOpacity(0.6) : Colors.grey.withOpacity(0.3),
                width: 1.2,
              ),
              boxShadow: hasStreak
                  ? [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withOpacity(0.2),
                        blurRadius: 6,
                        spreadRadius: 0,
                      )
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  size: 17,
                  color: hasStreak ? const Color(0xFFF59E0B) : Colors.grey[400],
                ),
                const SizedBox(width: 4),
                Text(
                  '$_dailyStreak',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: hasStreak ? const Color(0xFFF59E0B) : Colors.grey[400],
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  'STREAK',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 8.5,
                    letterSpacing: 0.5,
                    color: hasStreak ? const Color(0xFFF59E0B).withOpacity(0.9) : Colors.grey[500],
                  ),
                ),
                if (isDoneToday) ...[
                  const SizedBox(width: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDailyChallengeDialog() {
    final isDoneToday = _completedDailyDates.contains(_todayDateStr);
    final now = DateTime.now();

    // Generate past 7 days ending today
    final pastDays = List.generate(7, (i) {
      final dt = now.subtract(Duration(days: 6 - i));
      final dtStr = DailyStreakManager.formatDate(dt);
      final isToday = dtStr == _todayDateStr;
      final isCompleted = _completedDailyDates.contains(dtStr);
      const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      final dayLabel = dayNames[dt.weekday - 1];
      return {
        'date': dt,
        'dateStr': dtStr,
        'label': dayLabel,
        'dayNum': '${dt.day}',
        'isToday': isToday,
        'isCompleted': isCompleted,
      };
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDark ? const Color(0xFF111827) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.calendar_month_rounded, color: Color(0xFFF59E0B)),
            SizedBox(width: 8),
            Text('Daily Challenge & Streak', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Streak Hero Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF59E0B).withOpacity(0.2),
                    const Color(0xFFEF4444).withOpacity(0.12),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF59E0B), size: 36),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CONSECUTIVE WIN STREAK',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFF59E0B), letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('$_dailyStreak', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
                            const SizedBox(width: 4),
                            Text('Days', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[400])),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Best: $_bestDailyStreak',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Today's Status Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDoneToday ? const Color(0xFF10B981).withOpacity(0.15) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDoneToday ? const Color(0xFF10B981).withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isDoneToday ? Icons.check_circle_rounded : Icons.schedule_rounded,
                    size: 18,
                    color: isDoneToday ? const Color(0xFF10B981) : Colors.grey[400],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isDoneToday ? 'Today\'s puzzle completed! Streak secured.' : 'Solve today\'s puzzle to keep your streak alive!',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDoneToday ? const Color(0xFF10B981) : (widget.isDark ? Colors.grey[300] : Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 7-day Activity Strip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: pastDays.map((item) {
                final isToday = item['isToday'] as bool;
                final isCompleted = item['isCompleted'] as bool;
                final label = item['label'] as String;
                final dayNum = item['dayNum'] as String;

                return Column(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isToday ? const Color(0xFFF59E0B) : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFFF59E0B).withOpacity(0.2)
                            : (widget.isDark ? Colors.grey[850] : Colors.grey[200]),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isToday
                              ? const Color(0xFFF59E0B)
                              : (isCompleted ? const Color(0xFFF59E0B).withOpacity(0.5) : Colors.transparent),
                          width: isToday ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.local_fire_department_rounded, size: 16, color: Color(0xFFF59E0B))
                            : Text(
                                dayNum,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[500],
                                ),
                              ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _loadLevel(LevelGenerator.generateDaily(_todayDateStr), isDailyMode: true);
              },
              icon: Icon(isDoneToday ? Icons.refresh_rounded : Icons.play_arrow_rounded),
              label: Text(
                isDoneToday ? 'Replay Today\'s Puzzle' : 'Play Today\'s Puzzle',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: widget.isDark ? const Color(0xFF111827) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.settings_rounded, color: Color(0xFF06B6D4)),
              SizedBox(width: 8),
              Text('Settings & Guide', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Sound Effects', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Procedural audio cues', style: TextStyle(fontSize: 11)),
                value: _soundEnabled,
                activeColor: const Color(0xFF06B6D4),
                onChanged: (val) {
                  setModalState(() => _soundEnabled = val);
                  setState(() => _soundEnabled = val);
                },
              ),
              SwitchListTile(
                title: const Text('Haptic Vibration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Feedback on taps and errors', style: TextStyle(fontSize: 11)),
                value: _hapticsEnabled,
                activeColor: const Color(0xFF06B6D4),
                onChanged: (val) {
                  setModalState(() => _hapticsEnabled = val);
                  setState(() => _hapticsEnabled = val);
                },
              ),
              ListTile(
                title: const Text('Theme Appearance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(widget.isDark ? 'Cyber Dark' : 'Clean Light', style: const TextStyle(fontSize: 11)),
                trailing: IconButton(
                  icon: Icon(widget.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: const Color(0xFF06B6D4)),
                  onPressed: () {
                    widget.onToggleTheme();
                    setModalState(() {});
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.help_outline_rounded, color: Color(0xFF06B6D4)),
                title: const Text('How to Play', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Tap arrows that have clear exit paths', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showHowToPlayDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHowToPlayDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDark ? const Color(0xFF111827) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Rules & Strategy', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. An arrow escapes only if all cells in front of it in its pointing direction to the border are empty.', style: TextStyle(fontSize: 13)),
            SizedBox(height: 8),
            Text('2. Tapping a blocked arrow causes a collision, losing 1 Heart (❤️).', style: TextStyle(fontSize: 13)),
            SizedBox(height: 8),
            Text('3. Use UNDO (up to 3x) to revert moves, or HINT (up to 3x) to reveal valid arrows.', style: TextStyle(fontSize: 13)),
            SizedBox(height: 8),
            Text('4. Finish with 3 hearts and zero mistakes to earn 3 Stars (⭐⭐⭐)!', style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it!')),
        ],
      ),
    );
  }

  // ==========================================
  // 6. UI LAYOUT BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final remaining = _levelData.arrows.where((a) => !a.isRemoved).length;
    final progress = _levelData.initialCount > 0 ? (_levelData.initialCount - remaining) / _levelData.initialCount : 0.0;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                // Top Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF06B6D4).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.3)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.arrow_outward_rounded, size: 16, color: Color(0xFF06B6D4)),
                                      SizedBox(width: 4),
                                      Text('ARROW MATRIX', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF06B6D4))),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isDaily ? 'DAILY' : _levelData.tierName.toUpperCase(),
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400]),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildTopBarStreakCounter(),
                              const SizedBox(width: 2),
                              IconButton(
                                tooltip: 'Daily Challenge',
                                icon: const Icon(Icons.calendar_today_rounded, size: 20),
                                onPressed: _showDailyChallengeDialog,
                              ),
                              IconButton(
                                tooltip: 'Levels',
                                icon: const Icon(Icons.grid_view_rounded, size: 20),
                                onPressed: _showLevelSelectDialog,
                              ),
                              IconButton(
                                tooltip: 'Restart',
                                icon: const Icon(Icons.refresh_rounded, size: 20),
                                onPressed: _restartCurrentLevel,
                              ),
                              IconButton(
                                tooltip: 'Settings',
                                icon: const Icon(Icons.settings_rounded, size: 20),
                                onPressed: _showSettingsDialog,
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Status Bar: Hearts, Level Name, Score
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: widget.isDark ? const Color(0xFF111827) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(_isDaily ? 'Daily Challenge' : 'Stage ${_levelData.levelNumber}', style: const TextStyle(fontSize: 10, color: Color(0xFF06B6D4), fontWeight: FontWeight.bold)),
                                    if (_isDaily) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF59E0B).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.45), width: 0.8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.local_fire_department_rounded, size: 10, color: Color(0xFFF59E0B)),
                                            const SizedBox(width: 2),
                                            Text('$_dailyStreak STREAK', style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFFF59E0B))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(_levelData.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                              ],
                            ),
                            Row(
                              children: List.generate(_maxHearts, (i) {
                                return Icon(
                                  i < _hearts ? Icons.favorite : Icons.favorite_border,
                                  color: i < _hearts ? Colors.redAccent : Colors.grey[700],
                                  size: 22,
                                );
                              }),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Score', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                                Text('$_score', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF06B6D4))),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Hint message banner if active
                if (_activeHintExplanation != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: Color(0xFFFBBF24), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _activeHintExplanation!,
                              style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Board Matrix
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.isDark ? const Color(0xFF111827).withOpacity(0.7) : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF06B6D4).withOpacity(0.08),
                                blurRadius: 30,
                                spreadRadius: 5,
                              )
                            ],
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final size = math.min(constraints.maxWidth, constraints.maxHeight);
                              final rows = _levelData.rows;
                              final cols = _levelData.cols;
                              const spacing = 6.0;
                              final cellW = (size - (cols - 1) * spacing) / cols;
                              final cellH = (size - (rows - 1) * spacing) / rows;
                              final cellSize = math.min(cellW, cellH);

                              final actualBoardW = cols * cellSize + (cols - 1) * spacing;
                              final actualBoardH = rows * cellSize + (rows - 1) * spacing;
                              final startX = (constraints.maxWidth - actualBoardW) / 2;
                              final startY = (constraints.maxHeight - actualBoardH) / 2;

                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // 1. Static Grid Slots
                                  ...List.generate(rows * cols, (index) {
                                    final r = index ~/ cols;
                                    final c = index % cols;
                                    return Positioned(
                                      left: startX + c * (cellSize + spacing),
                                      top: startY + r * (cellSize + spacing),
                                      width: cellSize,
                                      height: cellSize,
                                      child: _buildGridSlot(r, c, cellSize),
                                    );
                                  }),

                                  // 2. Hint Runway Corridor Beam
                                  if (_activeHintArrowId != null)
                                    ..._buildHintRunway(startX, startY, cellSize, spacing),

                                  // 3. Active Arrows with Smooth Shifting Transitions!
                                  ..._levelData.arrows.where((a) => !a.isRemoved).map((arrow) {
                                    return AnimatedPositioned(
                                      key: ValueKey(arrow.id),
                                      duration: const Duration(milliseconds: 320),
                                      curve: Curves.easeInOutCubic,
                                      left: startX + arrow.col * (cellSize + spacing),
                                      top: startY + arrow.row * (cellSize + spacing),
                                      width: cellSize,
                                      height: cellSize,
                                      child: GridArrowTile(
                                        key: ValueKey('${arrow.id}_tile'),
                                        arrow: arrow,
                                        cellSize: cellSize,
                                        spacing: spacing,
                                        totalRows: rows,
                                        totalCols: cols,
                                        isDark: widget.isDark,
                                        onTap: () => _handleArrowTap(arrow),
                                        onExitComplete: () => _handleExitComplete(arrow),
                                        onBumpComplete: () => _handleBumpComplete(arrow),
                                      ),
                                    );
                                  }),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom Controls: Progress & Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text('CLEARED (${_levelData.initialCount - remaining}/${_levelData.initialCount})', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400])),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF06B6D4)),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${(progress * 100).round()}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF06B6D4))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _history.isNotEmpty && _undosRemaining > 0 ? _handleUndo : null,
                              icon: const Icon(Icons.undo_rounded, size: 16),
                              label: Text('UNDO ($_undosRemaining)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
                                foregroundColor: const Color(0xFF06B6D4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _hintsRemaining > 0 ? _handleHint : null,
                              icon: const Icon(Icons.lightbulb_rounded, size: 16),
                              label: Text('HINT ($_hintsRemaining)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFBBF24).withOpacity(0.15),
                                foregroundColor: const Color(0xFFFBBF24),
                                side: const BorderSide(color: Color(0xFFFBBF24), width: 1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getArrowColor(ArrowDirection dir) {
    switch (dir) {
      case ArrowDirection.up:
        return const Color(0xFF38BDF8); // Cyan
      case ArrowDirection.right:
        return const Color(0xFFC084FC); // Purple
      case ArrowDirection.down:
        return const Color(0xFF34D399); // Emerald
      case ArrowDirection.left:
        return const Color(0xFFFBBF24); // Amber
    }
  }

  Widget _buildGridSlot(int r, int c, double cellSize) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A).withOpacity(0.4) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDark ? Colors.grey[850]!.withOpacity(0.5) : Colors.grey[300]!.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Center(
        child: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: widget.isDark ? Colors.grey[700]!.withOpacity(0.4) : Colors.grey[400]!.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHintRunway(double startX, double startY, double cellSize, double spacing) {
    final hintArrow = _levelData.arrows.firstWhere(
      (a) => a.id == _activeHintArrowId && !a.isRemoved,
      orElse: () => const ArrowPiece(id: 'none', row: -1, col: -1, direction: ArrowDirection.up),
    );
    if (hintArrow.id == 'none') return [];

    final dr = hintArrow.direction.dr;
    final dc = hintArrow.direction.dc;
    final widgets = <Widget>[];

    int r = hintArrow.row + dr;
    int c = hintArrow.col + dc;

    while (r >= 0 && r < _levelData.rows && c >= 0 && c < _levelData.cols) {
      widgets.add(
        Positioned(
          left: startX + c * (cellSize + spacing),
          top: startY + r * (cellSize + spacing),
          width: cellSize,
          height: cellSize,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFBBF24).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.35), width: 1.5),
            ),
            child: Center(
              child: Icon(
                hintArrow.direction == ArrowDirection.up
                    ? Icons.keyboard_arrow_up_rounded
                    : hintArrow.direction == ArrowDirection.down
                        ? Icons.keyboard_arrow_down_rounded
                        : hintArrow.direction == ArrowDirection.left
                            ? Icons.keyboard_arrow_left_rounded
                            : Icons.keyboard_arrow_right_rounded,
                color: const Color(0xFFFBBF24).withOpacity(0.6),
                size: 20,
              ),
            ),
          ),
        ),
      );
      r += dr;
      c += dc;
    }

    return widgets;
  }
}

// ==========================================
// 7. ARROW GRID TILE WITH SMOOTH ANIMATIONS
// ==========================================

class GridArrowTile extends StatefulWidget {
  final ArrowPiece arrow;
  final double cellSize;
  final double spacing;
  final int totalRows;
  final int totalCols;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onExitComplete;
  final VoidCallback onBumpComplete;

  const GridArrowTile({
    super.key,
    required this.arrow,
    required this.cellSize,
    required this.spacing,
    required this.totalRows,
    required this.totalCols,
    required this.isDark,
    required this.onTap,
    required this.onExitComplete,
    required this.onBumpComplete,
  });

  @override
  State<GridArrowTile> createState() => _GridArrowTileState();
}

class _GridArrowTileState extends State<GridArrowTile> with TickerProviderStateMixin {
  late AnimationController _exitController;
  late Animation<double> _exitAnimation;

  late AnimationController _bumpController;
  late Animation<double> _bumpAnimation;

  late AnimationController _entranceController;
  late Animation<double> _entranceAnimation;

  late AnimationController _pulseController;

  bool _isHovered = false;
  double _dragOffset = 0.0;

  @override
  void initState() {
    super.initState();

    // 1. Exit animation: smooth rapid acceleration across grid and off screen
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _exitAnimation = CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeInCubic,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onExitComplete();
        }
      });

    // 2. Collision bump animation: directional forward jolt into obstacle + elastic recoil
    _bumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _bumpAnimation = CurvedAnimation(
      parent: _bumpController,
      curve: Curves.easeInOut,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onBumpComplete();
        }
      });

    // 3. Entrance & Undo return animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutBack,
    );

    // 4. Subtle ambient pulse for highlighted/hinted arrows
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    if (widget.arrow.isUndoing) {
      _entranceController.forward(from: 0.0);
    } else {
      final delay = (widget.arrow.row + widget.arrow.col) * 25;
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) {
          _entranceController.forward(from: 0.0);
        }
      });
    }

    if (widget.arrow.isExiting) {
      _exitController.forward(from: 0.0);
    }
    if (widget.arrow.isShaking) {
      _bumpController.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(covariant GridArrowTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.arrow.isExiting && widget.arrow.isExiting) {
      _exitController.forward(from: 0.0);
    }

    if (!oldWidget.arrow.isShaking && widget.arrow.isShaking) {
      _bumpController.forward(from: 0.0);
    }

    if (!oldWidget.arrow.isUndoing && widget.arrow.isUndoing) {
      _entranceController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _exitController.dispose();
    _bumpController.dispose();
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  double _getExitDistance() {
    final dx = widget.arrow.direction.dc.toDouble();
    final dy = widget.arrow.direction.dr.toDouble();
    final cellWithSpacing = widget.cellSize + widget.spacing;

    if (dx > 0) {
      return (widget.totalCols - widget.arrow.col) * cellWithSpacing + widget.cellSize * 1.2;
    } else if (dx < 0) {
      return (widget.arrow.col + 1) * cellWithSpacing + widget.cellSize * 1.2;
    } else if (dy > 0) {
      return (widget.totalRows - widget.arrow.row) * cellWithSpacing + widget.cellSize * 1.2;
    } else {
      return (widget.arrow.row + 1) * cellWithSpacing + widget.cellSize * 1.2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dx = widget.arrow.direction.dc.toDouble();
    final dy = widget.arrow.direction.dr.toDouble();

    return AnimatedBuilder(
      animation: Listenable.merge([
        _exitAnimation,
        _bumpAnimation,
        _entranceAnimation,
        _pulseController,
      ]),
      builder: (context, child) {
        // Exit flight translation along direction vector
        final exitDist = _getExitDistance();
        final exitProg = _exitAnimation.value;
        final exitOffsetX = dx * exitDist * exitProg;
        final exitOffsetY = dy * exitDist * exitProg;

        // Bump collision translation along direction vector + lateral tremor
        final bumpProg = _bumpAnimation.value;
        final forwardBump = math.sin(bumpProg * math.pi) * (widget.cellSize * 0.32);
        final lateralJitter = math.sin(bumpProg * 6 * math.pi) * (1 - bumpProg) * 3.5;
        final bumpOffsetX = dx * forwardBump - dy * lateralJitter;
        final bumpOffsetY = dy * forwardBump + dx * lateralJitter;

        // Hover & tactile drag translation
        final hoverOffset = _isHovered ? 3.5 : 0.0;
        final tactileTotal = hoverOffset + _dragOffset;
        final tactileOffsetX = dx * tactileTotal;
        final tactileOffsetY = dy * tactileTotal;

        // Undo entrance translation
        final entranceVal = _entranceAnimation.value;
        final undoReverseShift = (1.0 - entranceVal) * (widget.cellSize * 0.4);
        final undoOffsetX = -dx * undoReverseShift;
        final undoOffsetY = -dy * undoReverseShift;

        final totalX = exitOffsetX + bumpOffsetX + tactileOffsetX + undoOffsetX;
        final totalY = exitOffsetY + bumpOffsetY + tactileOffsetY + undoOffsetY;

        // Dynamic scale & opacity during flight
        double scale = entranceVal;
        if (_exitController.isAnimating) {
          scale = 1.0 + math.sin(exitProg * math.pi) * 0.12;
        } else if (_bumpController.isAnimating) {
          scale = 1.0 - math.sin(bumpProg * math.pi) * 0.08;
        } else if (_isHovered) {
          scale = 1.04;
        }

        double opacity = 1.0;
        if (_exitController.isAnimating && exitProg > 0.65) {
          opacity = ((1.0 - exitProg) / 0.35).clamp(0.0, 1.0);
        }

        final color = _getArrowColor(widget.arrow.direction);

        return Transform.translate(
          offset: Offset(totalX, totalY),
          child: Transform.scale(
            scale: scale.clamp(0.01, 1.3),
            child: Opacity(
              opacity: opacity,
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: widget.onTap,
                  onPanStart: (_) {
                    setState(() => _dragOffset = 0.0);
                  },
                  onPanUpdate: (details) {
                    final projected = details.delta.dx * dx + details.delta.dy * dy;
                    setState(() {
                      _dragOffset = (_dragOffset + projected).clamp(0.0, widget.cellSize * 0.4);
                    });
                  },
                  onPanEnd: (details) {
                    if (_dragOffset >= widget.cellSize * 0.22) {
                      widget.onTap();
                    }
                    setState(() => _dragOffset = 0.0);
                  },
                  child: Container(
                    width: widget.cellSize,
                    height: widget.cellSize,
                    decoration: BoxDecoration(
                      color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.arrow.isHighlighted
                            ? const Color(0xFFFBBF24)
                            : widget.arrow.isShaking
                                ? Colors.redAccent
                                : _isHovered
                                    ? color.withOpacity(0.8)
                                    : (widget.isDark ? Colors.grey[700]!.withOpacity(0.5) : Colors.grey[300]!),
                        width: (widget.arrow.isHighlighted || widget.arrow.isShaking || _isHovered) ? 2.0 : 1.2,
                      ),
                      boxShadow: [
                        if (widget.arrow.isHighlighted)
                          BoxShadow(
                            color: const Color(0xFFFBBF24).withOpacity(0.4 + _pulseController.value * 0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          )
                        else if (widget.arrow.isShaking)
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          )
                        else if (_isHovered)
                          BoxShadow(
                            color: color.withOpacity(0.35),
                            blurRadius: 10,
                            spreadRadius: 1,
                          )
                        else
                          BoxShadow(
                            color: Colors.black.withOpacity(widget.isDark ? 0.25 : 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: ArrowPainter(
                        direction: widget.arrow.direction,
                        isShaking: widget.arrow.isShaking,
                        isHighlighted: widget.arrow.isHighlighted,
                        isExiting: _exitController.isAnimating,
                        exitProgress: exitProg,
                        bumpProgress: bumpProg,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getArrowColor(ArrowDirection dir) {
    switch (dir) {
      case ArrowDirection.up:
        return const Color(0xFF38BDF8); // Cyan
      case ArrowDirection.right:
        return const Color(0xFFC084FC); // Purple
      case ArrowDirection.down:
        return const Color(0xFF34D399); // Emerald
      case ArrowDirection.left:
        return const Color(0xFFFBBF24); // Amber
    }
  }
}

// ==========================================
// 8. ARROW VECTOR CUSTOM PAINTER
// ==========================================

class ArrowPainter extends CustomPainter {
  final ArrowDirection direction;
  final bool isShaking;
  final bool isHighlighted;
  final bool isExiting;
  final double exitProgress;
  final double bumpProgress;
  final Color color;

  ArrowPainter({
    required this.direction,
    required this.isShaking,
    required this.isHighlighted,
    required this.isExiting,
    required this.exitProgress,
    this.bumpProgress = 0.0,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.save();
    canvas.translate(cx, cy);

    // Apply rotation based on pointing direction
    canvas.rotate(direction.rotationRadians);

    final arrowColor = isShaking
        ? Colors.redAccent
        : isHighlighted
            ? const Color(0xFFFBBF24)
            : color;

    // Draw motion trail / speed streaks when shifting and exiting
    if (isExiting && exitProgress > 0.05) {
      final trailPaint = Paint()
        ..color = arrowColor.withOpacity((1.0 - exitProgress).clamp(0.0, 0.7))
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final trailLen = size.width * (0.35 + exitProgress * 0.75);
      final shaftStartX = -size.width * 0.28;

      // Top streak
      trailPaint.strokeWidth = 2.0;
      canvas.drawLine(
        Offset(shaftStartX, -size.width * 0.08),
        Offset(shaftStartX - trailLen * 0.75, -size.width * 0.08),
        trailPaint,
      );

      // Center main streak
      trailPaint.strokeWidth = 3.0;
      canvas.drawLine(
        Offset(shaftStartX, 0),
        Offset(shaftStartX - trailLen, 0),
        trailPaint,
      );

      // Bottom streak
      trailPaint.strokeWidth = 2.0;
      canvas.drawLine(
        Offset(shaftStartX, size.width * 0.08),
        Offset(shaftStartX - trailLen * 0.75, size.width * 0.08),
        trailPaint,
      );
    }

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.28)
      ..style = PaintingStyle.fill;

    final shaftW = size.width * 0.16;
    final shaftL = size.width * 0.38;
    final headW = size.width * 0.44;
    final headL = size.width * 0.32;

    // Background drop shadow
    final shaftShadowRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(-size.width * 0.1, 2), width: shaftL, height: shaftW),
      const Radius.circular(6),
    );
    canvas.drawRRect(shaftShadowRect, shadowPaint);

    final arrowPaint = Paint()
      ..color = arrowColor
      ..style = PaintingStyle.fill;

    // Shaft body
    final shaftRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(-size.width * 0.1, 0), width: shaftL, height: shaftW),
      const Radius.circular(6),
    );
    canvas.drawRRect(shaftRect, arrowPaint);

    // Arrowhead Triangle
    final headPath = Path();
    final startX = -size.width * 0.1 + shaftL / 2 - 2;
    headPath.moveTo(startX, -headW / 2);
    headPath.lineTo(startX + headL, 0);
    headPath.lineTo(startX, headW / 2);
    headPath.close();

    final headShadowPath = headPath.shift(const Offset(0, 2));
    canvas.drawPath(headShadowPath, shadowPaint);
    canvas.drawPath(headPath, arrowPaint);

    // Specular center accent
    final specPaint = Paint()
      ..color = Colors.white.withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(-size.width * 0.22, 0),
      Offset(startX + headL * 0.4, 0),
      specPaint,
    );

    // Collision impact sparks on blocked bump
    if (isShaking && bumpProgress > 0.2 && bumpProgress < 0.8) {
      final sparkTipX = startX + headL + 2;
      final sparkIntensity = math.sin((bumpProgress - 0.2) / 0.6 * math.pi);
      final sparkPaint = Paint()
        ..color = Colors.amberAccent.withOpacity(sparkIntensity)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.8;

      for (int i = -2; i <= 2; i++) {
        final angle = i * 0.35;
        final sparkDist = 8.0 * sparkIntensity;
        canvas.drawLine(
          Offset(sparkTipX, 0),
          Offset(sparkTipX + math.cos(angle) * sparkDist, math.sin(angle) * sparkDist),
          sparkPaint,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ArrowPainter oldDelegate) {
    return oldDelegate.direction != direction ||
        oldDelegate.isShaking != isShaking ||
        oldDelegate.isHighlighted != isHighlighted ||
        oldDelegate.isExiting != isExiting ||
        oldDelegate.exitProgress != exitProgress ||
        oldDelegate.bumpProgress != bumpProgress ||
        oldDelegate.color != color;
  }
}
