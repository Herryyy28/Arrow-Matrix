import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AmazeLogoWidget extends StatelessWidget {
  final double size;
  final bool isCompact;
  final bool isDark;

  const AmazeLogoWidget({
    super.key,
    this.size = 120.0,
    this.isCompact = false,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _AmazeLogoPainter(isDark: isDark),
          ),
        ),
        if (!isCompact) ...[
          const SizedBox(height: 12),
          Text(
            'ARROW MATRIX',
            style: TextStyle(
              fontSize: size * 0.18,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ],
    );
  }
}

class _AmazeLogoPainter extends CustomPainter {
  final bool isDark;

  _AmazeLogoPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // 1. Outer rounded tile box with drop shadow & border
    final tileRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(width * 0.08, height * 0.08, width * 0.84, height * 0.84),
      Radius.circular(width * 0.22),
    );

    // Inner tile gradient fill
    final tileGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
          : [const Color(0xFFFFFFFF), const Color(0xFFF1F5F9)],
    );
    canvas.drawRRect(
      tileRect,
      Paint()
        ..shader = tileGradient.createShader(Rect.fromLTWH(0, 0, width, height))
        ..style = PaintingStyle.fill,
    );

    // Tile border
    canvas.drawRRect(
      tileRect,
      Paint()
        ..color = isDark ? AppColors.primary.withValues(alpha: 0.4) : AppColors.primary.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * 0.04,
    );

    // 2. Subtle Maze Grid Lines inside Tile
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 1; i <= 3; i++) {
      final pos = width * (0.1 + i * 0.2);
      canvas.drawLine(Offset(pos, height * 0.15), Offset(pos, height * 0.85), gridPaint);
      canvas.drawLine(Offset(width * 0.15, pos), Offset(width * 0.85, pos), gridPaint);
    }

    // 3. Dynamic Escaping Arrow (Bursting outwards to top-right)
    final arrowPath = Path();
    arrowPath.moveTo(width * 0.24, height * 0.68);
    arrowPath.lineTo(width * 0.50, height * 0.42);
    arrowPath.lineTo(width * 0.40, height * 0.30);
    arrowPath.lineTo(width * 0.80, height * 0.20); // Head Tip
    arrowPath.lineTo(width * 0.70, height * 0.60);
    arrowPath.lineTo(width * 0.58, height * 0.50);
    arrowPath.lineTo(width * 0.32, height * 0.76);
    arrowPath.close();

    final arrowGradient = LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: const [
        AppColors.primary,
        AppColors.secondary,
        AppColors.warning,
      ],
    );

    canvas.drawPath(
      arrowPath,
      Paint()
        ..shader = arrowGradient.createShader(Rect.fromLTWH(0, 0, width, height))
        ..style = PaintingStyle.fill,
    );

    // Arrow edge highlight line
    final highlightPath = Path();
    highlightPath.moveTo(width * 0.50, height * 0.42);
    highlightPath.lineTo(width * 0.80, height * 0.20);
    highlightPath.lineTo(width * 0.70, height * 0.60);
    canvas.drawPath(
      highlightPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );

    // 4. Motion Burst Sparkles
    final sparkPaint = Paint()
      ..color = AppColors.warning
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(width * 0.86, height * 0.14), width * 0.035, sparkPaint);
    canvas.drawCircle(Offset(width * 0.76, height * 0.10), width * 0.02, sparkPaint);
  }

  @override
  bool shouldRepaint(covariant _AmazeLogoPainter oldDelegate) => oldDelegate.isDark != isDark;
}
