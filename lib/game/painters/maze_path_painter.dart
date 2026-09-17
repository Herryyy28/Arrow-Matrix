import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/arrow_direction.dart';
import '../../models/arrow_piece.dart';
import '../../models/board.dart';

class ActivePathAnimation {
  final List<Offset> points;
  final double progress; // 0.0 to 1.0
  final Color color;
  final bool isReverse;

  const ActivePathAnimation({
    required this.points,
    required this.progress,
    required this.color,
    this.isReverse = false,
  });
}

class MazePathPainter extends CustomPainter {
  final Board board;
  final double cellSize;
  final String? selectedArrowId;
  final String? guidanceArrowId;
  final String? invalidArrowId;
  final List<String>? unlockedArrowIds;
  final ActivePathAnimation? activeAnimation;
  final bool isDark;
  final bool developerDebugMode;

  MazePathPainter({
    required this.board,
    required this.cellSize,
    this.selectedArrowId,
    this.guidanceArrowId,
    this.invalidArrowId,
    this.unlockedArrowIds,
    this.activeAnimation,
    this.isDark = true,
    this.developerDebugMode = false,
  });

  static const List<Color> _regionColors = [
    Color(0xFFFF6B4A), // Electric Orange
    Color(0xFF00E5FF), // Luminous Cyan
    Color(0xFF76FF03), // Lime Green
    Color(0xFFE040FB), // Magenta Purple
    Color(0xFFFFD700), // Amber Gold
  ];

  Color _getRegionColor(int row, int col) {
    final index = (row + col * 2) % _regionColors.length;
    return _regionColors[index];
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (cellSize <= 0) return;

    // 0. Render Glowing Silhouette Shape Contour Outer Boundary
    _drawSilhouetteContour(canvas, size);

    final arrows = board.arrows.where((a) => !a.isRemoved).toList();

    // 1. Render Continuous Glowing Directional Paths with Integrated Arrowheads
    for (final arrow in arrows) {
      final isHighlighted = selectedArrowId == arrow.id || guidanceArrowId == arrow.id || (unlockedArrowIds?.contains(arrow.id) ?? false);
      final isInvalid = invalidArrowId == arrow.id;
      final regionColor = _getRegionColor(arrow.row, arrow.column);
      final color = isInvalid ? const Color(0xFFFF5252) : (isHighlighted ? const Color(0xFFFFD700) : regionColor);

      _drawDirectionalPathPrimitive(
        canvas: canvas,
        arrow: arrow,
        color: color,
        isHighlighted: isHighlighted,
        isInvalid: isInvalid,
      );
    }

    // 2. Render Active Moving Path & Traveling Energy Highlight (Snake Animation)
    if (activeAnimation != null && activeAnimation!.points.length >= 2) {
      _drawActivePathMovement(canvas);
    }

    // 3. Render Developer Debug Overlay (if developerDebugMode is enabled)
    if (developerDebugMode && board.network != null) {
      _drawDeveloperDebugOverlay(canvas, size);
    }
  }

  void _drawDeveloperDebugOverlay(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    for (final node in board.network!.nodes) {
      final start = Offset((node.col + 0.5) * cellSize, (node.row + 0.5) * cellSize);
      for (final targetId in node.connectsToIds) {
        final targetNode = board.network!.nodes.firstWhere((n) => n.id == targetId, orElse: () => node);
        if (targetNode.id != node.id) {
          final end = Offset((targetNode.col + 0.5) * cellSize, (targetNode.row + 0.5) * cellSize);
          canvas.drawLine(start, end, linePaint);
        }
      }
    }
  }

  /// Renders a unified directional path primitive (line + integrated arrowheads).
  void _drawDirectionalPathPrimitive({
    required Canvas canvas,
    required ArrowPiece arrow,
    required Color color,
    required bool isHighlighted,
    bool isInvalid = false,
  }) {
    int currR = arrow.row;
    int currC = arrow.column;
    final directions = arrow.effectivePathPattern;

    for (int d = 0; d < directions.length; d++) {
      final dir = directions[d];

      final nudgeDx = isInvalid ? dir.dc * 4.0 : 0.0;
      final nudgeDy = isInvalid ? dir.dr * 4.0 : 0.0;

      final startPos = Offset(
        (currC + 0.5) * cellSize + nudgeDx,
        (currR + 0.5) * cellSize + nudgeDy,
      );

      // Advance along dir until hitting board edge, non-playable cell, or blocking arrow
      int nextR = currR;
      int nextC = currC;

      while (true) {
        final r = nextR + dir.dr;
        final c = nextC + dir.dc;

        if (!board.isWithinBounds(r, c) || !board.isCellPlayable(r, c)) break;

        // Check blocking arrow
        final blocker = board.getArrowAt(r, c);
        if (blocker != null && blocker.id != arrow.id && !blocker.isRemoved) break;

        nextR = r;
        nextC = c;
      }

      final endPos = Offset(
        (nextC + 0.5) * cellSize,
        (nextR + 0.5) * cellSize,
      );

      // 1a. Layer 1: Restrained Soft Ambient Glow Halo
      final haloPaint = Paint()
        ..color = color.withValues(alpha: isHighlighted ? 0.60 : 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isHighlighted ? 7.5 : 5.5
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

      canvas.drawLine(startPos, endPos, haloPaint);

      // 1b. Layer 2: Base Region Color Stroke
      final basePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = isHighlighted ? 4.2 : 3.4
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(startPos, endPos, basePaint);

      // 1c. Layer 3: Crisp Core Line
      final corePaint = Paint()
        ..color = isHighlighted ? Colors.white : Colors.white.withValues(alpha: 0.88)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isHighlighted ? 2.0 : 1.4
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(startPos, endPos, corePaint);

      // 1d. Master Integrated Arrowheads (repeat naturally on long segments)
      final segLength = (endPos - startPos).distance;
      if (segLength < cellSize * 0.2) {
        // Single cell path - draw 1 arrowhead at start position
        _drawMasterArrowhead(
          canvas: canvas,
          center: startPos,
          direction: dir,
          color: color,
          isHighlighted: isHighlighted,
        );
      } else {
        // Multi-cell path segment: space arrowheads naturally along path length
        final stepDist = cellSize * 1.8;
        final arrowCount = math.max(1, (segLength / stepDist).round());

        for (int i = 0; i < arrowCount; i++) {
          final t = arrowCount == 1 ? 0.0 : (i / arrowCount);
          final arrowPos = Offset.lerp(startPos, endPos, t)!;

          _drawMasterArrowhead(
            canvas: canvas,
            center: arrowPos,
            direction: dir,
            color: color,
            isHighlighted: isHighlighted,
          );
        }
      }

      // Update current cell position for next path direction segment
      currR = nextR;
      currC = nextC;
    }
  }

  void _drawActivePathMovement(Canvas canvas) {
    final pts = activeAnimation!.points;
    final t = activeAnimation!.progress.clamp(0.0, 1.0);
    final color = activeAnimation!.color;
    final isReverse = activeAnimation!.isReverse;

    // Calculate total length of polyline
    double totalLength = 0.0;
    final segmentLengths = <double>[];
    for (int i = 0; i < pts.length - 1; i++) {
      final len = (pts[i + 1] - pts[i]).distance;
      segmentLengths.add(len);
      totalLength += len;
    }

    if (totalLength <= 0) return;

    final progressRatio = isReverse ? (1.0 - t) : t;
    final targetDist = totalLength * progressRatio;
    double accumulated = 0.0;
    Offset currentPos = pts.first;
    double currentAngle = 0.0;

    final activePath = Path();
    activePath.moveTo(pts.first.dx, pts.first.dy);

    for (int i = 0; i < pts.length - 1; i++) {
      final segLen = segmentLengths[i];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final dx = p2.dx - p1.dx;
      final dy = p2.dy - p1.dy;
      final angle = math.atan2(dy, dx);

      if (accumulated + segLen >= targetDist) {
        final remain = targetDist - accumulated;
        final ratio = segLen > 0 ? (remain / segLen) : 0.0;
        currentPos = Offset(p1.dx + dx * ratio, p1.dy + dy * ratio);
        currentAngle = angle;
        activePath.lineTo(currentPos.dx, currentPos.dy);
        break;
      } else {
        accumulated += segLen;
        activePath.lineTo(p2.dx, p2.dy);
        currentPos = p2;
        currentAngle = angle;
      }
    }

    // 2a. Traveling Energy Highlight Outer Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
    canvas.drawPath(activePath, glowPaint);

    // 2b. Core White Traveling Energy Segment
    final corePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(activePath, corePaint);

    // 2c. Moving Arrowhead leading the energy path (The Snake Head)
    final size = cellSize * 0.44;
    canvas.save();
    canvas.translate(currentPos.dx, currentPos.dy);
    canvas.rotate(currentAngle);

    final arrowPath = Path();
    arrowPath.moveTo(-size * 0.35, -size * 0.35);
    arrowPath.lineTo(size * 0.40, 0);
    arrowPath.lineTo(-size * 0.35, size * 0.35);
    arrowPath.lineTo(-size * 0.15, 0);
    arrowPath.close();

    final headGlow = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
    canvas.drawPath(arrowPath, headGlow);

    final headFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(arrowPath, headFill);

    final headCore = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawPath(arrowPath, headCore);

    canvas.restore();
  }

  void _drawSilhouetteContour(Canvas canvas, Size size) {
    final contourPaint = Paint()
      ..color = const Color(0x2500E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    for (int r = 0; r < board.rows; r++) {
      for (int c = 0; c < board.cols; c++) {
        if (!board.isCellPlayable(r, c)) continue;

        final left = c * cellSize;
        final top = r * cellSize;
        final right = (c + 1) * cellSize;
        final bottom = (r + 1) * cellSize;

        // Draw boundary edges facing non-playable space
        if (r == 0 || !board.isCellPlayable(r - 1, c)) {
          canvas.drawLine(Offset(left, top), Offset(right, top), contourPaint);
        }
        if (r == board.rows - 1 || !board.isCellPlayable(r + 1, c)) {
          canvas.drawLine(Offset(left, bottom), Offset(right, bottom), contourPaint);
        }
        if (c == 0 || !board.isCellPlayable(r, c - 1)) {
          canvas.drawLine(Offset(left, top), Offset(left, bottom), contourPaint);
        }
        if (c == board.cols - 1 || !board.isCellPlayable(r, c + 1)) {
          canvas.drawLine(Offset(right, top), Offset(right, bottom), contourPaint);
        }
      }
    }
  }

  void _drawMasterArrowhead({
    required Canvas canvas,
    required Offset center,
    required ArrowDirection direction,
    required Color color,
    required bool isHighlighted,
  }) {
    final size = cellSize * 0.38;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(direction.rotationRadians);

    // Integrated Geometric Arrowhead Path (Line flows through Arrowhead tip)
    final arrowPath = Path();
    arrowPath.moveTo(-size * 0.35, -size * 0.35);
    arrowPath.lineTo(size * 0.38, 0); // Sharp tip
    arrowPath.lineTo(-size * 0.35, size * 0.35);
    arrowPath.lineTo(-size * 0.15, 0); // Inward notch connecting to path centerline
    arrowPath.close();

    // 1. Soft Glow Halo (matching line halo)
    final haloPaint = Paint()
      ..color = color.withValues(alpha: isHighlighted ? 0.65 : 0.28)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);
    canvas.drawPath(arrowPath, haloPaint);

    // 2. Base Color Fill
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(arrowPath, fillPaint);

    // 3. Crisp Core Edge Highlight
    final corePaint = Paint()
      ..color = isHighlighted ? Colors.white : Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawPath(arrowPath, corePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MazePathPainter oldDelegate) {
    return oldDelegate.board != board ||
        oldDelegate.cellSize != cellSize ||
        oldDelegate.selectedArrowId != selectedArrowId ||
        oldDelegate.guidanceArrowId != guidanceArrowId ||
        oldDelegate.invalidArrowId != invalidArrowId ||
        oldDelegate.unlockedArrowIds != unlockedArrowIds ||
        oldDelegate.activeAnimation != activeAnimation ||
        oldDelegate.isDark != isDark ||
        oldDelegate.developerDebugMode != developerDebugMode;
  }
}

