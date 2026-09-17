import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/arrow_direction.dart';

class ArrowPainter extends CustomPainter {
  final ArrowDirection direction;
  final bool isHighlighted;
  final bool isInvalid;
  final bool isDark;
  final bool isStartArrow;
  final bool isKeyArrow;
  final bool isTransformedToKey;

  ArrowPainter({
    required this.direction,
    this.isHighlighted = false,
    this.isInvalid = false,
    this.isDark = false,
    this.isStartArrow = false,
    this.isKeyArrow = false,
    this.isTransformedToKey = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    final isKeyMode = isKeyArrow || isTransformedToKey;

    // Start Arrow glow ring effect
    if (isStartArrow && !isKeyMode) {
      final startGlowPaint = Paint()
        ..color = AppColors.secondary.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      canvas.drawCircle(center, radius + 2, startGlowPaint);
    }

    // Key Arrow golden glow ring effect
    if (isKeyMode) {
      final keyGlowPaint = Paint()
        ..color = AppColors.warning.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
      canvas.drawCircle(center, radius + 3, keyGlowPaint);
    }

    // Special state indicators (Invalid tap pulse highlight)
    if (isInvalid) {
      final invalidGlowPaint = Paint()
        ..color = AppColors.error.withValues(alpha: 0.7)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
      canvas.drawCircle(center, radius * 0.5, invalidGlowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ArrowPainter oldDelegate) {
    return oldDelegate.direction != direction ||
        oldDelegate.isHighlighted != isHighlighted ||
        oldDelegate.isInvalid != isInvalid ||
        oldDelegate.isDark != isDark ||
        oldDelegate.isStartArrow != isStartArrow ||
        oldDelegate.isKeyArrow != isKeyArrow ||
        oldDelegate.isTransformedToKey != isTransformedToKey;
  }
}
