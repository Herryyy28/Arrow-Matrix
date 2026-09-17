import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../game/board/board_controller.dart';
import '../../services/ads_service.dart';

class LevelFailedDialog extends StatelessWidget {
  final BoardController controller;
  final AdsService adsService;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  const LevelFailedDialog({
    super.key,
    required this.controller,
    required this.adsService,
    required this.onRetry,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final adAvailable = adsService.isAdAvailable();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.heart_broken_rounded,
              color: AppColors.error,
              size: 56,
            ),
            const SizedBox(height: 12),
            const Text(
              'LEVEL FAILED',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You ran out of hearts!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Retry Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('RETRY LEVEL'),
              ),
            ),
            const SizedBox(height: 12),

            // Watch Ad for Extra Life (Disabled/Graceful offline fallback)
            if (adAvailable) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final rewardGranted = await adsService.showRewardedAd();
                    if (rewardGranted) {
                      // Granted extra heart logic
                    }
                  },
                  icon: const Icon(Icons.ondemand_video_rounded),
                  label: const Text('WATCH AD (+1 HEART)'),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Home Button
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
