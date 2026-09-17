import 'package:flutter/material.dart';
import '../../models/achievement_model.dart';
import '../../services/storage_service.dart';

class AchievementsScreen extends StatelessWidget {
  final StorageService storageService;

  const AchievementsScreen({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    final unlockedIds = storageService.getUnlockedAchievements();
    final all = AchievementModel.allAchievements;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ACHIEVEMENTS',
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
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: all.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = all[index];
                    final isUnlocked = unlockedIds.contains(item.id);

                    return _AchievementTile(
                      achievement: item,
                      isUnlocked: isUnlocked,
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final AchievementModel achievement;
  final bool isUnlocked;

  const _AchievementTile({
    required this.achievement,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? primary.withValues(alpha: 0.5) : (isDark ? Colors.white12 : Colors.black12),
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnlocked ? primary.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.icon,
              color: isUnlocked ? primary : Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? (isDark ? Colors.white : Colors.black) : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isUnlocked ? (isDark ? Colors.white70 : Colors.black87) : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 24)
          else
            const Icon(Icons.lock_rounded, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}
