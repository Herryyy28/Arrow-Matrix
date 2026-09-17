import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/daily_seed.dart';
import '../../game/generator/level_generator.dart';
import '../../models/level_data.dart';
import '../../services/storage_service.dart';
import '../gameplay/game_screen.dart';

class DailyChallengeScreen extends StatefulWidget {
  final StorageService storageService;

  const DailyChallengeScreen({
    super.key,
    required this.storageService,
  });

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  late final String _dateStr;
  late final int _seed;
  late final int _streak;
  late final bool _isCompletedToday;
  LevelData? _dailyLevel;

  @override
  void initState() {
    super.initState();
    _dateStr = DailySeed.getDateString();
    _seed = DailySeed.getSeedFromDate();
    _streak = widget.storageService.getDailyStreak();
    final lastDate = widget.storageService.getLastDailyDate();
    _isCompletedToday = lastDate == _dateStr;

    // Generate daily level ONCE during state initialization (outside build)
    _dailyLevel = LevelGenerator.generateLevel(999, customSeed: _seed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DAILY CHALLENGE'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),

              // Calendar Hero Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                _dateStr,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                _isCompletedToday
                    ? '🎉 Daily challenge completed today!'
                    : 'A unique daily puzzle generated for today.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: _isCompletedToday ? AppColors.success : Colors.grey,
                  fontWeight: _isCompletedToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 24),

              // Streak Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: AppColors.primary, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Current Streak: $_streak Days',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Start Daily Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: _dailyLevel == null
                      ? null
                      : () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GameScreen(
                                levelNumber: 999,
                                customLevel: _dailyLevel,
                                isDaily: true,
                                storageService: widget.storageService,
                              ),
                            ),
                          );
                        },
                  icon: const Icon(Icons.play_arrow_rounded, size: 28),
                  label: Text(_isCompletedToday ? 'REPLAY DAILY CHALLENGE' : 'START DAILY CHALLENGE'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
