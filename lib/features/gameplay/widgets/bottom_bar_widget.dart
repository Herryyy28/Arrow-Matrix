import 'package:flutter/material.dart';
import '../../../game/board/board_controller.dart';
import '../../../models/game_state.dart';
import '../../../widgets/interactive_button.dart';

class BottomBarWidget extends StatelessWidget {
  final BoardController controller;

  const BottomBarWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // UNDO Button
              _ActionButton(
                icon: Icons.undo_rounded,
                label: 'UNDO',
                badgeText: '×${controller.undoCount}',
                enabled: controller.canUndo,
                onPressed: () => controller.performUndo(),
              ),

              // RESTART Button
              _ActionButton(
                icon: Icons.refresh_rounded,
                label: 'RESTART',
                enabled: controller.state == GameStateEnum.playing,
                onPressed: () => controller.restartLevel(),
              ),

              // HINT Button
              _ActionButton(
                icon: Icons.lightbulb_outline_rounded,
                label: 'HINT',
                badgeText: '×${controller.hintCount}',
                enabled: controller.canUseHint,
                onPressed: () => controller.useHint(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badgeText;
  final bool enabled;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.badgeText,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InteractiveButton(
      onPressed: enabled ? onPressed : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: enabled
                      ? primaryColor.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.1),
                  boxShadow: [
                    if (enabled)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                  border: Border.all(
                    color: enabled
                        ? primaryColor.withValues(alpha: 0.4)
                        : Colors.grey.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: Icon(
                  icon,
                  size: 26,
                  color: enabled ? primaryColor : Colors.grey,
                ),
              ),
              if (badgeText != null)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: enabled ? primaryColor : Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      badgeText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: enabled ? Theme.of(context).colorScheme.onSurface : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
