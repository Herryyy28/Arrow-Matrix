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

    // Draw background rounded pill container for arrow
    final bgPaint = Paint()
      ..color = isInvalid
          ? AppColors.error
          : (isKeyMode
              ? AppColors.warning
              : (isHighlighted || isStartArrow
                  ? AppColors.warning
                  : (isDark ? AppColors.darkCard : AppColors.lightCard)))
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isDark ? 0.35 : 0.12)
      ..style = PaintingStyle.fill;

    // Draw 3D shadow depth
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCircle(center: center.translate(0, 3.0), radius: radius),
        Radius.circular(radius * 0.4),
      ),
      shadowPaint,
    );

    // Draw container box
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCircle(center: center, radius: radius),
        Radius.circular(radius * 0.4),
      ),
      bgPaint,
    );

    // 3D Top-edge Specular Bevel Highlight
    final specularPaint = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.18 : 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCircle(center: center.translate(0, -1.0), radius: radius - 1),
        Radius.circular((radius - 1) * 0.4),
      ),
      specularPaint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = isInvalid
          ? Colors.white
          : (isKeyMode
              ? Colors.white
              : (isHighlighted || isStartArrow
                  ? AppColors.secondary
                  : (isDark ? AppColors.gridBorderDark : AppColors.gridBorderLight)))
      ..style = PaintingStyle.stroke
      ..strokeWidth = (isStartArrow || isKeyMode) ? 2.5 : 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCircle(center: center, radius: radius),
        Radius.circular(radius * 0.4),
      ),
      borderPaint,
    );

    // Save canvas & rotate to arrow direction
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(direction.rotationRadians);

    // Arrow shaft and head color
    final arrowPaint = Paint()
      ..color = isInvalid || isKeyMode
          ? Colors.white
          : (isHighlighted || isStartArrow
              ? Colors.white
              : (isDark ? AppColors.arrowHighlight : AppColors.primary))
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final arrowPath = Path();
    final arrowLength = radius * 0.9;
    final shaftWidth = radius * 0.22;
    final headLength = radius * 0.45;
    final headWidth = radius * 0.55;

    // Build arrow geometry pointing RIGHT (rotated by canvas)
    arrowPath.moveTo(-arrowLength * 0.4, -shaftWidth / 2);
    arrowPath.lineTo(arrowLength * 0.4 - headLength, -shaftWidth / 2);
    arrowPath.lineTo(arrowLength * 0.4 - headLength, -headWidth / 2);
    arrowPath.lineTo(arrowLength * 0.4, 0); // Head Tip
    arrowPath.lineTo(arrowLength * 0.4 - headLength, headWidth / 2);
    arrowPath.lineTo(arrowLength * 0.4 - headLength, shaftWidth / 2);
    arrowPath.lineTo(-arrowLength * 0.4, shaftWidth / 2);
    arrowPath.close();

    canvas.drawPath(arrowPath, arrowPaint);
    canvas.restore();
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
