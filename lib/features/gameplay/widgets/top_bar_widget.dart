import 'package:flutter/material.dart';
import '../../../game/board/board_controller.dart';
import 'heart_display.dart';

class TopBarWidget extends StatelessWidget {
  final BoardController controller;

  const TopBarWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final levelNumber = controller.currentLevelData?.levelNumber ?? 1;
        final isDaily = controller.isDailyChallenge;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: (isDark ? Colors.black38 : Colors.white60),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.08),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Pause / Menu Button
              IconButton.filledTonal(
                onPressed: () => controller.togglePause(),
                icon: const Icon(Icons.pause_rounded, size: 22),
                tooltip: 'Pause',
              ),

              // Level Indicator with animated score
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    children: [
                      Text(
                        isDaily ? 'DAILY CHALLENGE' : 'LEVEL $levelNumber',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: controller.score.toDouble(), end: controller.score.toDouble()),
                        duration: const Duration(milliseconds: 300),
                        builder: (context, value, child) {
                          return Text(
                            'SCORE: ${value.toInt()}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Hearts Counter
              HeartDisplay(hearts: controller.hearts),
            ],
          ),
        );
      },
    );
  }
}
