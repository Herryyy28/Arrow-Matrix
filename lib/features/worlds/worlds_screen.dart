import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/world_model.dart';
import '../../services/storage_service.dart';
import '../gameplay/game_screen.dart';

class WorldsScreen extends StatelessWidget {
  final StorageService storageService;

  const WorldsScreen({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    final highestUnlocked = storageService.getHighestUnlockedLevel();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SELECT WORLD',
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
                  itemCount: WorldModel.allWorlds.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final world = WorldModel.allWorlds[index];
                    final isUnlocked = highestUnlocked >= world.startLevel;

                    return _WorldCard(
                      world: world,
                      isUnlocked: isUnlocked,
                      highestUnlocked: highestUnlocked,
                      onTap: () {
                        if (isUnlocked) {
                          _showLevelPickerModal(context, world, highestUnlocked);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Reach Level ${world.startLevel} to unlock ${world.name}!'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
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

  void _showLevelPickerModal(BuildContext context, WorldModel world, int highestUnlocked) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LevelPickerModal(
        world: world,
        highestUnlocked: highestUnlocked,
        storageService: storageService,
      ),
    );
  }
}

class _WorldCard extends StatelessWidget {
  final WorldModel world;
  final bool isUnlocked;
  final int highestUnlocked;
  final VoidCallback onTap;

  const _WorldCard({
    required this.world,
    required this.isUnlocked,
    required this.highestUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnlocked
                ? world.primaryColor.withValues(alpha: 0.5)
                : (isDark ? AppColors.gridBorderDark : AppColors.gridBorderLight),
            width: isUnlocked ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? world.primaryColor.withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isUnlocked ? world.icon : Icons.lock_rounded,
                color: isUnlocked ? world.primaryColor : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    world.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked
                          ? (isDark ? Colors.white : AppColors.lightTextPrimary)
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    world.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Levels ${world.startLevel} – ${world.endLevel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isUnlocked ? world.primaryColor : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _LevelPickerModal extends StatelessWidget {
  final WorldModel world;
  final int highestUnlocked;
  final StorageService storageService;

  const _LevelPickerModal({
    required this.world,
    required this.highestUnlocked,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalLevelsInWorld = world.endLevel - world.startLevel + 1;

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : AppColors.lightBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(world.icon, color: world.primaryColor, size: 24),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    world.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.0,
              ),
              itemCount: totalLevelsInWorld,
              itemBuilder: (context, index) {
                final levelNum = world.startLevel + index;
                final isLvlUnlocked = levelNum <= highestUnlocked;
                final stars = storageService.getLevelStars(levelNum);

                return InkWell(
                  onTap: () {
                    if (isLvlUnlocked) {
                      Navigator.pop(context); // Close modal
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameScreen(
                            levelNumber: levelNum,
                            storageService: storageService,
                          ),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isLvlUnlocked
                          ? (isDark ? AppColors.darkSurface : AppColors.lightSurface)
                          : (isDark ? Colors.grey.shade900 : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isLvlUnlocked ? world.primaryColor.withValues(alpha: 0.4) : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLvlUnlocked) ...[
                          Text(
                            '$levelNum',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (starIdx) {
                              return Icon(
                                starIdx < stars ? Icons.star_rounded : Icons.star_border_rounded,
                                size: 12,
                                color: starIdx < stars ? AppColors.warning : Colors.grey,
                              );
                            }),
                          ),
                        ] else ...[
                          const Icon(Icons.lock_rounded, size: 18, color: Colors.grey),
                          const SizedBox(height: 2),
                          Text(
                            '$levelNum',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
