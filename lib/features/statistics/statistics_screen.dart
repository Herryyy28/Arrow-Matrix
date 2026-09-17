import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../widgets/interactive_button.dart';

class StatisticsScreen extends StatelessWidget {
  final StorageService storageService;

  const StatisticsScreen({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    final highestLevel = storageService.getHighestUnlockedLevel();
    final gamesPlayed = storageService.getTotalGamesPlayed();
    final arrowsCleared = storageService.getTotalArrowsCleared();
    final perfectRuns = storageService.getPerfectRunsCount();
    final streak = storageService.getDailyStreak();
    final totalMistakes = storageService.getTotalMistakes();

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PLAYER STATISTICS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    _StatCard(
                      icon: Icons.emoji_events_rounded,
                      title: 'Highest Level Unlocked',
                      value: '$highestLevel',
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.gamepad_rounded,
                      title: 'Total Games Played',
                      value: '$gamesPlayed',
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.arrow_outward_rounded,
                      title: 'Total Arrows Cleared',
                      value: '$arrowsCleared',
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.stars_rounded,
                      title: 'Perfect Runs (Zero Mistakes)',
                      value: '$perfectRuns',
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.local_fire_department_rounded,
                      title: 'Best Daily Streak',
                      value: '$streak Days',
                      color: Colors.deepOrange,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.heart_broken_rounded,
                      title: 'Total Mistakes Made',
                      value: '$totalMistakes',
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 24),
                    InteractiveButton(
                      onPressed: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'BACK TO MENU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
