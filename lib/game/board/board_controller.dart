import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/daily_seed.dart';
import '../../models/arrow_piece.dart';
import '../../models/board.dart';
import '../../models/game_state.dart';
import '../../models/level_data.dart';
import '../../models/puzzle_element.dart';
import '../../services/audio_service.dart';
import '../../services/haptic_service.dart';
import '../../services/storage_service.dart';
import '../generator/level_generator.dart';
import '../puzzle/repository/puzzle_repository.dart';
import '../scoring/score_calculator.dart';
import '../solver/puzzle_solver.dart';

class GameSnapshot {
  final List<dynamic> arrowsState;
  final List<dynamic> gatesState;
  final List<dynamic> switchesState;
  final List<dynamic> keysState;
  final int score;
  final int hearts;
  final int movesCount;
  final int mistakesCount;

  GameSnapshot({
    required this.arrowsState,
    required this.gatesState,
    required this.switchesState,
    required this.keysState,
    required this.score,
    required this.hearts,
    required this.movesCount,
    required this.mistakesCount,
  });
}

class BoardController extends ChangeNotifier {
  final StorageService storageService;
  final AudioService audioService;
  final HapticService hapticService;

  LevelData? _currentLevelData;
  Board? _board;
  GameStateEnum _state = GameStateEnum.home;
  int _score = 0;
  int _hearts = AppConstants.maxHearts;
  int _movesCount = 0;
  int _mistakesCount = 0;
  int _undoCount = AppConstants.maxUndos;
  int _hintCount = AppConstants.maxHints;
  bool _isDailyChallenge = false;
  int _starsEarned = 0;
  String? _invalidArrowId;
  String? _highlightedArrowId;

  String? _guidanceArrowId;
  bool? _guidancePathClear;
  ArrowExitPath? _previewPath;

  final List<GameSnapshot> _undoHistory = [];

  BoardController({
    required this.storageService,
    required this.audioService,
    required this.hapticService,
  });

  // Getters
  Board? get board => _board;
  GameStateEnum get state => _state;
  int get score => _score;
  int get hearts => _hearts;
  int get movesCount => _movesCount;
  int get mistakesCount => _mistakesCount;
  int get undoCount => _undoCount;
  int get hintCount => _hintCount;
  int get starsEarned => _starsEarned;
  bool get isDailyChallenge => _isDailyChallenge;
  String? get invalidArrowId => _invalidArrowId;
  String? get highlightedArrowId => _highlightedArrowId;
  LevelData? get currentLevelData => _currentLevelData;
  String? get guidanceArrowId => _guidanceArrowId;
  bool? get guidancePathClear => _guidancePathClear;
  ArrowExitPath? get previewPath => _previewPath;
  bool get canUndo => _undoCount > 0 && _undoHistory.isNotEmpty && _state == GameStateEnum.playing;
  bool get canUseHint => _hintCount > 0 && _state == GameStateEnum.playing;

  /// Loads a level by level number or custom generated LevelData.
  void loadLevel(int levelNumber, {LevelData? customLevel, bool isDaily = false}) {
    _isDailyChallenge = isDaily;
    final repository = PuzzleRepository(storageService: storageService);
    _currentLevelData = customLevel ?? repository.getLevel(levelNumber);
    _board = _currentLevelData!.createInitialBoard();
    _score = 0;
    _hearts = AppConstants.maxHearts;
    _movesCount = 0;
    _mistakesCount = 0;
    _undoCount = AppConstants.maxUndos;
    _hintCount = AppConstants.maxHints;
    _starsEarned = 0;
    _invalidArrowId = null;
    _highlightedArrowId = null;
    _guidanceArrowId = null;
    _guidancePathClear = null;
    _previewPath = null;
    _undoHistory.clear();
    _state = GameStateEnum.playing;
    notifyListeners();
  }

  /// Restarts the current active level.
  void restartLevel() {
    if (_currentLevelData != null) {
      loadLevel(_currentLevelData!.levelNumber, customLevel: _currentLevelData, isDaily: _isDailyChallenge);
    }
  }

  /// Toggles pause mode.
  void togglePause() {
    if (_state == GameStateEnum.playing) {
      _state = GameStateEnum.paused;
    } else if (_state == GameStateEnum.paused) {
      _state = GameStateEnum.playing;
    }
    notifyListeners();
  }

  /// Calculates and sets live path preview for an arrow.
  void showGuidance(ArrowPiece arrow) {
    if (_state != GameStateEnum.playing || _board == null) return;
    _guidanceArrowId = arrow.id;
    _previewPath = _board!.calculateArrowPath(arrow);
    _guidancePathClear = _previewPath?.isExitValid;
    hapticService.lightImpact();
    notifyListeners();
  }

  /// Clears path preview.
  void clearGuidance() {
    if (_guidanceArrowId != null) {
      _guidanceArrowId = null;
      _guidancePathClear = null;
      _previewPath = null;
      notifyListeners();
    }
  }

  /// Handles player tapping an arrow on the board.
  Future<void> onArrowTapped(ArrowPiece arrow) async {
    if (_state != GameStateEnum.playing || _board == null) return;
    if (arrow.isRemoved || arrow.isMoving) return;

    _highlightedArrowId = null;
    _previewPath = null;

    final pathInfo = _board!.calculateArrowPath(arrow);

    if (pathInfo.isExitValid) {
      // Valid Move!
      _pushUndoSnapshot();

      // Audio & Haptic
      audioService.playArrowMove();
      hapticService.mediumImpact();

      // Set moving status
      _updateArrowState(arrow.id, isMoving: true);
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 220));

      // Simulate state transitions (gate open, key collect, lock unlock)
      _board = PuzzleSolver.simulateMove(_board!, arrow);
      _score += AppConstants.scorePerArrow;
      _movesCount++;

      final isFinalKey = arrow.isKeyArrow || arrow.isTransformedToKey || _board!.activeArrowCount == 1;

      if (isFinalKey) {
        audioService.playKeyCollect();
        hapticService.heavyImpact();
      } else {
        audioService.playArrowExit();
      }

      // Check win condition
      if (_board!.isCleared) {
        await _handleLevelComplete();
      } else {
        notifyListeners();
      }
    } else {
      // Invalid Move!
      _invalidArrowId = arrow.id;
      _mistakesCount++;
      _hearts--;

      audioService.playInvalidMove();
      hapticService.errorVibration();

      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 280));
      _invalidArrowId = null;

      if (_hearts <= 0) {
        _state = GameStateEnum.levelFailed;
        audioService.playLevelFailed();
        hapticService.heavyImpact();
      }
      notifyListeners();
    }
  }

  /// Executes Undo to restore previous board state snapshot.
  void performUndo() {
    if (!canUndo || _board == null) return;

    final snapshot = _undoHistory.removeLast();
    _score = snapshot.score;
    _hearts = snapshot.hearts;
    _movesCount = snapshot.movesCount;
    _mistakesCount = snapshot.mistakesCount;

    final restoredArrows = (snapshot.arrowsState)
        .map((item) => ArrowPiece.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    final restoredGates = (snapshot.gatesState)
        .map((item) => GateElement.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    final restoredSwitches = (snapshot.switchesState)
        .map((item) => SwitchElement.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    final restoredKeys = (snapshot.keysState)
        .map((item) => KeyElement.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    _board = Board(
      rows: _board!.rows,
      cols: _board!.cols,
      shapeDefinition: _board!.shapeDefinition,
      patternDefinition: _board!.patternDefinition,
      network: _board!.network,
      arrows: restoredArrows,
      gates: restoredGates,
      switches: restoredSwitches,
      keys: restoredKeys,
      portals: _board!.portals,
      iceCells: _board!.iceCells,
      obstacles: _board!.obstacles,
    );
    _undoCount--;

    audioService.playUndo();
    hapticService.lightImpact();
    notifyListeners();
  }

  /// Request a hint for next valid arrow move.
  void useHint() {
    if (!canUseHint || _board == null) return;

    final hintId = PuzzleSolver.getHintArrowId(_board!);
    if (hintId != null) {
      _highlightedArrowId = hintId;
      _hintCount--;

      audioService.playHint();
      hapticService.lightImpact();
      notifyListeners();
    }
  }

  void _pushUndoSnapshot() {
    if (_board == null) return;

    if (_undoHistory.length >= AppConstants.maxUndos) {
      _undoHistory.removeAt(0);
    }

    final arrowsJson = _board!.arrows.map((a) => a.toJson()).toList();
    final gatesJson = _board!.gates.map((g) => g.toJson()).toList();
    final switchesJson = _board!.switches.map((s) => s.toJson()).toList();
    final keysJson = _board!.keys.map((k) => k.toJson()).toList();

    _undoHistory.add(GameSnapshot(
      arrowsState: arrowsJson,
      gatesState: gatesJson,
      switchesState: switchesJson,
      keysState: keysJson,
      score: _score,
      hearts: _hearts,
      movesCount: _movesCount,
      mistakesCount: _mistakesCount,
    ));
  }

  void _updateArrowState(String id, {bool? isMoving, bool? isRemoved}) {
    if (_board == null) return;
    final index = _board!.arrows.indexWhere((a) => a.id == id);
    if (index != -1) {
      final updated = _board!.arrows[index].copyWith(
        isMoving: isMoving ?? _board!.arrows[index].isMoving,
        isRemoved: isRemoved ?? _board!.arrows[index].isRemoved,
      );
      final newArrows = List<ArrowPiece>.from(_board!.arrows);
      newArrows[index] = updated;
      _board = _board!.copyWith(arrows: newArrows);
    }
  }

  Future<void> _handleLevelComplete() async {
    _state = GameStateEnum.levelComplete;

    _score = ScoreCalculator.calculateFinalScore(
      arrowCount: _board!.arrows.length,
      mistakes: _mistakesCount,
      remainingHearts: _hearts,
    );

    _starsEarned = ScoreCalculator.calculateStars(
      remainingHearts: _hearts,
      mistakes: _mistakesCount,
    );

    audioService.playLevelComplete();
    hapticService.heavyImpact();

    await storageService.incrementGamesPlayed();
    await storageService.addArrowsCleared(_board!.arrows.length);
    await storageService.addMistakes(_mistakesCount);

    final currentLvl = _currentLevelData?.levelNumber ?? 1;
    await storageService.unlockAchievement('first_step');

    if (currentLvl >= 10) await storageService.unlockAchievement('levels_10');
    if (currentLvl >= 25) await storageService.unlockAchievement('levels_25');
    if (currentLvl >= 50) await storageService.unlockAchievement('levels_50');
    if (currentLvl >= 100) await storageService.unlockAchievement('levels_100');
    if (currentLvl >= 101) await storageService.unlockAchievement('master_world');

    if (_mistakesCount == 0) {
      await storageService.incrementPerfectRuns();
      await storageService.unlockAchievement('perfect_run');
      if (storageService.getPerfectRunsCount() >= 10) {
        await storageService.unlockAchievement('perfect_10');
      }
    }

    if (!_isDailyChallenge && _currentLevelData != null) {
      await storageService.setBestScore(_score);
      await storageService.setLevelStars(currentLvl, _starsEarned);
      await storageService.setHighestUnlockedLevel(currentLvl + 1);
    } else if (_isDailyChallenge) {
      final todayStr = DailySeed.getDateString();
      final lastDate = storageService.getLastDailyDate();
      if (lastDate != todayStr) {
        final currentStreak = storageService.getDailyStreak();
        await storageService.setDailyStreak(currentStreak + 1);
        await storageService.setLastDailyDate(todayStr);
        if (currentStreak + 1 >= 7) await storageService.unlockAchievement('streak_7');
        if (currentStreak + 1 >= 30) await storageService.unlockAchievement('streak_30');
      }
      await storageService.setBestScore(_score);
    }

    notifyListeners();
  }
}
