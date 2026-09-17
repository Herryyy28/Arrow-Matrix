import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../game/board/board_controller.dart';
import '../../models/game_state.dart';
import '../../models/level_data.dart';
import '../../services/ads_service.dart';
import '../../services/audio_service.dart';
import '../../services/haptic_service.dart';
import '../../services/storage_service.dart';
import '../level_complete/level_complete_dialog.dart';
import '../level_failed/level_failed_dialog.dart';
import 'widgets/board_widget.dart';
import 'widgets/bottom_bar_widget.dart';
import 'widgets/pause_dialog.dart';
import 'widgets/top_bar_widget.dart';

import '../../widgets/game_environment_widget.dart';
import '../../widgets/game_particle_overlay.dart';

class GameScreen extends StatefulWidget {
  final int levelNumber;
  final LevelData? customLevel;
  final bool isDaily;
  final StorageService storageService;

  const GameScreen({
    super.key,
    required this.levelNumber,
    required this.storageService,
    this.customLevel,
    this.isDaily = false,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late BoardController _boardController;
  late AdsService _adsService;
  late ParticleController _particleController;
  late int _currentLevelNumber;
  bool _hasSpawnedVictoryBurst = false;

  @override
  void initState() {
    super.initState();
    _currentLevelNumber = widget.levelNumber;
    _particleController = ParticleController();

    final audioService = AudioService(widget.storageService);
    final hapticService = HapticService(widget.storageService);
    _adsService = OfflineAdsService();

    _boardController = BoardController(
      storageService: widget.storageService,
      audioService: audioService,
      hapticService: hapticService,
    );

    _boardController.loadLevel(
      _currentLevelNumber,
      customLevel: widget.customLevel,
      isDaily: widget.isDaily,
    );
  }

  @override
  void dispose() {
    _particleController.dispose();
    _boardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (_boardController.state == GameStateEnum.playing) {
            _boardController.togglePause();
          } else {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        body: GameEnvironmentWidget(
          isDark: isDark,
          child: SafeArea(
            child: GameParticleOverlay(
              controller: _particleController,
              child: ListenableBuilder(
                listenable: _boardController,
                builder: (context, _) {
                  final state = _boardController.state;
                  final activeLevel = _boardController.currentLevelData?.levelNumber ?? _currentLevelNumber;

                  if (state == GameStateEnum.levelComplete && !_hasSpawnedVictoryBurst) {
                    _hasSpawnedVictoryBurst = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _particleController.spawnVictoryBurst(MediaQuery.of(context).size);
                      }
                    });
                  } else if (state == GameStateEnum.playing) {
                    _hasSpawnedVictoryBurst = false;
                  }

                  return Stack(
                    children: [
                      // Main Game Responsive Layout
                      Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 550),
                          child: Column(
                            children: [
                              TopBarWidget(controller: _boardController),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  child: Center(
                                    child: BoardWidget(
                                      controller: _boardController,
                                      particleController: _particleController,
                                    ),
                                  ),
                                ),
                              ),
                              BottomBarWidget(controller: _boardController),
                            ],
                          ),
                        ),
                      ),

                  // Pause Overlay Dialog
                  if (state == GameStateEnum.paused)
                    PauseDialog(
                      controller: _boardController,
                      onHome: () => Navigator.pop(context),
                    ),

                  // Level Complete Dialog
                  if (state == GameStateEnum.levelComplete)
                    LevelCompleteDialog(
                      controller: _boardController,
                      isLastLevel: activeLevel >= AppConstants.totalLevels,
                      onNextLevel: () {
                        if (activeLevel >= AppConstants.totalLevels) {
                          // All levels conquered — go home
                          Navigator.pop(context);
                        } else {
                          final nextLvl = activeLevel + 1;
                          setState(() {
                            _currentLevelNumber = nextLvl;
                          });
                          _boardController.loadLevel(nextLvl);
                        }
                      },
                      onReplay: () {
                        _boardController.restartLevel();
                      },
                      onHome: () => Navigator.pop(context),
                    ),

                  // Level Failed Dialog
                  if (state == GameStateEnum.levelFailed)
                    LevelFailedDialog(
                      controller: _boardController,
                      adsService: _adsService,
                      onRetry: () {
                        _boardController.restartLevel();
                      },
                      onHome: () => Navigator.pop(context),
                    ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
