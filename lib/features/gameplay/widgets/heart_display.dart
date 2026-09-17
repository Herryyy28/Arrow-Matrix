import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class HeartDisplay extends StatelessWidget {
  final int hearts;

  const HeartDisplay({
    super.key,
    required this.hearts,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(AppConstants.maxHearts, (index) {
        final isActive = index < hearts;
        return AnimatedScale(
          scale: isActive ? 1.0 : 0.7,
          duration: const Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Icon(
              isActive ? Icons.favorite : Icons.favorite_border,
              color: isActive ? AppColors.error : AppColors.lightTextSecondary.withValues(alpha: 0.4),
              size: 24,
            ),
          ),
        );
      }),
    );
  }
}
