import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/arrow_direction.dart';
import '../../models/shape_definition.dart';

class GatePainter extends CustomPainter {
  final bool isOpen;
  final bool isDark;

  const GatePainter({
    required this.isOpen,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: size.width * 0.88, height: size.height * 0.88),
      const Radius.circular(10),
    );

    // 3D Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rect.shift(const Offset(0, 2.5)), shadowPaint);

    final color = isOpen ? (isDark ? AppColors.success : Colors.green) : (isDark ? AppColors.error : Colors.red);
    final basePaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rect, basePaint);

    // 3D Rim Bevel
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(rect, borderPaint);

    // Specular Highlight
    final specularPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rect.deflate(1.2), specularPaint);

    final barPaint = Paint()
      ..color = isOpen ? Colors.greenAccent : Colors.redAccent
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    if (!isOpen) {
      canvas.drawLine(Offset(size.width * 0.3, size.height * 0.22), Offset(size.width * 0.3, size.height * 0.78), barPaint);
      canvas.drawLine(Offset(size.width * 0.5, size.height * 0.22), Offset(size.width * 0.5, size.height * 0.78), barPaint);
      canvas.drawLine(Offset(size.width * 0.7, size.height * 0.22), Offset(size.width * 0.7, size.height * 0.78), barPaint);
    } else {
      canvas.drawCircle(center, size.width * 0.18, Paint()..color = Colors.greenAccent);
    }
  }

  @override
  bool shouldRepaint(covariant GatePainter oldDelegate) =>
      oldDelegate.isOpen != isOpen || oldDelegate.isDark != isDark;
}

class SwitchPainter extends CustomPainter {
  final bool isActivated;
  final bool isDark;

  const SwitchPainter({
    required this.isActivated,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = min(size.width, size.height) * 0.38;

    // 3D Shadow
    canvas.drawCircle(center.translate(0, 2.5), outerRadius, Paint()..color = Colors.black.withValues(alpha: 0.3));

    final color = isActivated ? AppColors.warning : (isDark ? Colors.grey.shade700 : Colors.grey.shade400);
    final outerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius, outerPaint);

    // Metallic LED Bevel
    final innerPaint = Paint()
      ..color = isActivated ? Colors.amber.shade200 : (isDark ? Colors.grey.shade900 : Colors.grey.shade200)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius * 0.62, innerPaint);

    // Specular Highlight Ring
    final specPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, outerRadius * 0.9, specPaint);
  }

  @override
  bool shouldRepaint(covariant SwitchPainter oldDelegate) =>
      oldDelegate.isActivated != isActivated || oldDelegate.isDark != isDark;
}

class KeyPainter extends CustomPainter {
  final bool isCollected;

  const KeyPainter({required this.isCollected});

  @override
  void paint(Canvas canvas, Size size) {
    if (isCollected) return;

    final center = Offset(size.width / 2, size.height / 2);

    // 3D Metallic Golden Glow
    final glowPaint = Paint()
      ..color = AppColors.warning.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.drawCircle(Offset(center.dx - size.width * 0.15, center.dy), size.width * 0.18, glowPaint);

    final paint = Paint()
      ..color = AppColors.warning
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(center.dx - size.width * 0.15, center.dy), size.width * 0.15, paint);

    final innerCut = Paint()..color = Colors.black.withValues(alpha: 0.3);
    canvas.drawCircle(Offset(center.dx - size.width * 0.15, center.dy), size.width * 0.06, innerCut);

    final shaftPaint = Paint()
      ..color = AppColors.warning
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx - size.width * 0.05, center.dy),
      Offset(center.dx + size.width * 0.25, center.dy),
      shaftPaint,
    );

    canvas.drawLine(
      Offset(center.dx + size.width * 0.15, center.dy),
      Offset(center.dx + size.width * 0.15, center.dy + size.height * 0.12),
      shaftPaint,
    );
    canvas.drawLine(
      Offset(center.dx + size.width * 0.25, center.dy),
      Offset(center.dx + size.width * 0.25, center.dy + size.height * 0.12),
      shaftPaint,
    );
  }

  @override
  bool shouldRepaint(covariant KeyPainter oldDelegate) => oldDelegate.isCollected != isCollected;
}

class PortalPainter extends CustomPainter {
  final ArrowDirection exitDirection;
  final bool isDark;

  const PortalPainter({
    required this.exitDirection,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.40;

    // 3D Vortex Shadow
    canvas.drawCircle(center.translate(0, 2), radius, Paint()..color = Colors.black26);

    final ringPaint = Paint()
      ..shader = SweepGradient(
        colors: const [
          AppColors.secondary,
          Colors.cyanAccent,
          Colors.purpleAccent,
          AppColors.secondary,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawCircle(center, radius, ringPaint);

    final innerPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.75, innerPaint);
  }

  @override
  bool shouldRepaint(covariant PortalPainter oldDelegate) =>
      oldDelegate.exitDirection != exitDirection || oldDelegate.isDark != isDark;
}

class IcePainter extends CustomPainter {
  final bool isDark;

  const IcePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
      const Radius.circular(10),
    );

    final icePaint = Paint()
      ..color = (isDark ? Colors.cyan.shade900 : Colors.cyan.shade100).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rect, icePaint);

    final borderPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant IcePainter oldDelegate) => oldDelegate.isDark != isDark;
}

class PathPreviewPainter extends CustomPainter {
  final List<Point<int>> pathCells;
  final double cellSize;
  final bool isExitValid;
  final bool isDark;

  const PathPreviewPainter({
    required this.pathCells,
    required this.cellSize,
    required this.isExitValid,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pathCells.length < 2) return;

    final linePaint = Paint()
      ..color = isExitValid
          ? (isDark ? AppColors.success : Colors.green)
          : (isDark ? AppColors.error : Colors.red)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final first = pathCells.first;
    path.moveTo(
      first.y * cellSize + cellSize / 2,
      first.x * cellSize + cellSize / 2,
    );

    for (int i = 1; i < pathCells.length; i++) {
      final pt = pathCells[i];
      path.lineTo(
        pt.y * cellSize + cellSize / 2,
        pt.x * cellSize + cellSize / 2,
      );
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant PathPreviewPainter oldDelegate) =>
      oldDelegate.pathCells != pathCells ||
      oldDelegate.cellSize != cellSize ||
      oldDelegate.isExitValid != isExitValid ||
      oldDelegate.isDark != isDark;
}

class MovingWallPainter extends CustomPainter {
  final bool isMoved;
  final bool isDark;

  const MovingWallPainter({
    required this.isMoved,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3, 3, size.width - 6, size.height - 6),
      const Radius.circular(8),
    );

    final fillPaint = Paint()
      ..color = isMoved
          ? (isDark ? Colors.indigo.shade800 : Colors.indigo.shade200)
          : (isDark ? Colors.blueGrey.shade800 : Colors.blueGrey.shade300)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rect, fillPaint);

    final borderPaint = Paint()
      ..color = isMoved ? Colors.indigoAccent : (isDark ? Colors.white30 : Colors.black26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(rect, borderPaint);

    // Draw wall icon lines
    final linePaint = Paint()
      ..color = isMoved ? Colors.white : (isDark ? Colors.white70 : Colors.black87)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(
      Offset(center.dx - size.width * 0.2, center.dy),
      Offset(center.dx + size.width * 0.2, center.dy),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size.height * 0.2),
      Offset(center.dx, center.dy + size.height * 0.2),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant MovingWallPainter oldDelegate) =>
      oldDelegate.isMoved != isMoved || oldDelegate.isDark != isDark;
}

class RotatingSectionPainter extends CustomPainter {
  final int angleDegrees;
  final bool isDark;

  const RotatingSectionPainter({
    required this.angleDegrees,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.42;

    final outerPaint = Paint()
      ..color = (isDark ? Colors.purple.shade900 : Colors.purple.shade100).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, outerPaint);

    final borderPaint = Paint()
      ..color = Colors.purpleAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant RotatingSectionPainter oldDelegate) =>
      oldDelegate.angleDegrees != angleDegrees || oldDelegate.isDark != isDark;
}

/// Vector Painter for rendering shape silhouettes and irregular board cell outlines.
class ShapeSilhouettePainter extends CustomPainter {
  final ShapeDefinition shapeDefinition;
  final double cellSize;
  final bool isDark;

  const ShapeSilhouettePainter({
    required this.shapeDefinition,
    required this.cellSize,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = (isDark ? AppColors.primary : AppColors.secondary).withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = (isDark ? AppColors.primary : AppColors.primaryHover).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final path = Path();
    final borderPath = Path();

    for (int r = 0; r < shapeDefinition.rows; r++) {
      for (int c = 0; c < shapeDefinition.cols; c++) {
        if (!shapeDefinition.isPlayable(r, c)) continue;

        final left = c * cellSize;
        final top = r * cellSize;
        final right = left + cellSize;
        final bottom = top + cellSize;

        final rect = Rect.fromLTRB(left + 1, top + 1, right - 1, bottom - 1);
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
        canvas.drawRRect(rrect, fillPaint);

        // Draw outer borders for cells adjacent to non-playable areas or grid boundaries
        if (!shapeDefinition.isPlayable(r - 1, c)) {
          borderPath.moveTo(left + 4, top);
          borderPath.lineTo(right - 4, top);
        }
        if (!shapeDefinition.isPlayable(r + 1, c)) {
          borderPath.moveTo(left + 4, bottom);
          borderPath.lineTo(right - 4, bottom);
        }
        if (!shapeDefinition.isPlayable(r, c - 1)) {
          borderPath.moveTo(left, top + 4);
          borderPath.lineTo(left, bottom - 4);
        }
        if (!shapeDefinition.isPlayable(r, c + 1)) {
          borderPath.moveTo(right, top + 4);
          borderPath.lineTo(right, bottom - 4);
        }
      }
    }

    canvas.drawPath(borderPath, glowPaint);
    canvas.drawPath(borderPath, borderPaint);

    // Draw custom smooth contour points if present
    if (shapeDefinition.customOutlinePoints != null && shapeDefinition.customOutlinePoints!.isNotEmpty) {
      final outlinePath = Path();
      final pts = shapeDefinition.customOutlinePoints!;
      outlinePath.moveTo(pts.first.dx * size.width, pts.first.dy * size.height);
      for (int i = 1; i < pts.length; i++) {
        outlinePath.lineTo(pts[i].dx * size.width, pts[i].dy * size.height);
      }
      outlinePath.close();
      canvas.drawPath(outlinePath, borderPaint..strokeWidth = 2.5);
    }
  }

  @override
  bool shouldRepaint(covariant ShapeSilhouettePainter oldDelegate) =>
      oldDelegate.shapeDefinition.id != shapeDefinition.id ||
      oldDelegate.cellSize != cellSize ||
      oldDelegate.isDark != isDark;
}

