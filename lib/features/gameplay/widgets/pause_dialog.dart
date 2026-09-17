import 'package:flutter/material.dart';
import '../../../game/board/board_controller.dart';

class PauseDialog extends StatelessWidget {
  final BoardController controller;
  final VoidCallback onHome;

  const PauseDialog({
    super.key,
    required this.controller,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME PAUSED',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 24),

            // Resume
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.togglePause();
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('RESUME'),
              ),
            ),
            const SizedBox(height: 12),

            // Restart
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  controller.restartLevel();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('RESTART LEVEL'),
              ),
            ),
            const SizedBox(height: 12),

            // Home
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onHome,
                icon: const Icon(Icons.home_rounded),
                label: const Text('HOME'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
