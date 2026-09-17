import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../game/board/board_controller.dart';

class LevelCompleteDialog extends StatelessWidget {
  final BoardController controller;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onHome;
  final bool isLastLevel;

  const LevelCompleteDialog({
    super.key,
    required this.controller,
    required this.onNextLevel,
    required this.onReplay,
    required this.onHome,
    this.isLastLevel = false,
  });

  @override
  Widget build(BuildContext context) {
    final stars = controller.starsEarned;
    final targetMoves = controller.board?.arrows.length ?? 0;
    final isMasterLine = controller.movesCount <= targetMoves && targetMoves > 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Text with Network Solved Title
            const Text(
              'PACKED PATTERN COMPLETE!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppColors.primary,
              ),
            ),
            if (isMasterLine) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning, width: 1),
                ),
                child: const Text(
                  '★ MASTER LINE ACHIEVED ★',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Stars Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final isEarned = index < stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(
                    isEarned ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isEarned ? AppColors.warning : Colors.grey.shade400,
                    size: index == 1 ? 48 : 36, // Center star slightly bigger
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Score & Stats Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _StatRow(label: 'Total Score', value: '${controller.score}'),
                  const Divider(height: 16),
                  _StatRow(label: 'Moves Taken', value: '${controller.movesCount} / $targetMoves Target'),
                  const SizedBox(height: 6),
                  _StatRow(label: 'Mistakes', value: '${controller.mistakesCount}'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Congratulations on last level
            if (isLastLevel) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.workspace_premium_rounded, color: AppColors.warning, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'You conquered all 1000 levels!',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onNextLevel,
                icon: Icon(isLastLevel ? Icons.home_rounded : Icons.arrow_forward_rounded),
                label: Text(isLastLevel ? 'BACK TO HOME' : 'NEXT LEVEL'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final shape = controller.board?.shapeDefinition;
                  final levelName = shape != null
                      ? '${shape.name.toUpperCase()} SHAPE'
                      : (controller.isDailyChallenge
                          ? 'Daily Challenge'
                          : 'Level ${controller.currentLevelData?.levelNumber ?? 1}');
                  final text = '🧩 AMAZE GO!\n'
                      '$levelName - SOLVED!\n'
                      '⭐ Score: ${controller.score}\n'
                      '🎯 Moves: ${controller.movesCount} | 💔 Mistakes: ${controller.mistakesCount}\n'
                      'Can you solve this shape? #AmazeGO';

                  await Clipboard.setData(ClipboardData(text: text));

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Result copied to clipboard! 📋'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.share_rounded),
                label: const Text('SHARE RESULT'),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReplay,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('REPLAY'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onHome,
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('HOME'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
