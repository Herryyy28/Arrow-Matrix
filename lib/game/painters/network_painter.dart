import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/arrow_network.dart';

/// Canvas custom painter for vector network connection lines, branch/merge nodes,
/// and live dependency path preview overlays.
class NetworkGraphPainter extends CustomPainter {
  final ArrowNetwork? network;
  final double cellSize;
  final String? selectedNodeId;
  final String? highlightedNodeId;
  final List<String> previewChainNodeIds;
  final bool isDark;

  NetworkGraphPainter({
    required this.network,
    required this.cellSize,
    this.selectedNodeId,
    this.highlightedNodeId,
    this.previewChainNodeIds = const [],
    this.isDark = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (network == null || network!.nodes.isEmpty) return;

    final nodeMap = {for (var n in network!.nodes) n.id: n};

    // 1. Draw base connection network graph lines
    for (final node in network!.nodes) {
      final startPos = Offset(
        (node.col + 0.5) * cellSize,
        (node.row + 0.5) * cellSize,
      );

      for (final targetId in node.connectsToIds) {
        final targetNode = nodeMap[targetId];
        if (targetNode == null) continue;

        final endPos = Offset(
          (targetNode.col + 0.5) * cellSize,
          (targetNode.row + 0.5) * cellSize,
        );

        final isHighlighted = (selectedNodeId == node.id && selectedNodeId != null) ||
            previewChainNodeIds.contains(node.id) && previewChainNodeIds.contains(targetId);

        _drawConnectionLine(
          canvas: canvas,
          start: startPos,
          end: endPos,
          isHighlighted: isHighlighted,
          isBranch: node.isBranch,
          isMerge: targetNode.isMerge,
        );
      }
    }

    // 2. Draw branch/merge junction indicators
    for (final node in network!.nodes) {
      if (node.isBranch || node.isMerge || node.connectsToIds.length > 1) {
        final center = Offset(
          (node.col + 0.5) * cellSize,
          (node.row + 0.5) * cellSize,
        );
        _drawJunctionNode(canvas, center, isBranch: node.isBranch);
      }
    }
  }

  void _drawConnectionLine({
    required Canvas canvas,
    required Offset start,
    required Offset end,
    required bool isHighlighted,
    required bool isBranch,
    required bool isMerge,
  }) {
    final linePaint = Paint()
      ..color = isHighlighted
          ? AppColors.primary
          : Colors.transparent
      ..strokeWidth = isHighlighted ? 3.5 : 0.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(start.dx, start.dy);

    if (start.dx != end.dx && start.dy != end.dy) {
      // Draw Orthogonal L-shaped polyline bend
      final corner = Offset(end.dx, start.dy);
      path.lineTo(corner.dx, corner.dy);
      path.lineTo(end.dx, end.dy);
    } else {
      path.lineTo(end.dx, end.dy);
    }

    if (isHighlighted) {
      // Glow effect for highlighted connection
      final glowPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.4)
        ..strokeWidth = 7.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, linePaint);

      // Draw directional vector arrowhead marker along the path segment
      final mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
      final dx = end.dx - start.dx;
      final dy = end.dy - start.dy;
      final angle = math.atan2(dy, dx);

      canvas.save();
      canvas.translate(mid.dx, mid.dy);
      canvas.rotate(angle);

      final arrowHeadPath = Path()
        ..moveTo(4, 0)
        ..lineTo(-4, -3.5)
        ..lineTo(-2, 0)
        ..lineTo(-4, 3.5)
        ..close();

      final arrowPaint = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.fill;

      canvas.drawPath(arrowHeadPath, arrowPaint);
      canvas.restore();
    }
  }

  void _drawJunctionNode(Canvas canvas, Offset center, {required bool isBranch}) {
    // Only draw junction markers when highlighted
    final fillPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = isDark ? Colors.white : Colors.black
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, 3.0, fillPaint);
    canvas.drawCircle(center, 3.0, borderPaint);
  }

  @override
  bool shouldRepaint(covariant NetworkGraphPainter oldDelegate) {
    return oldDelegate.network != network ||
        oldDelegate.cellSize != cellSize ||
        oldDelegate.selectedNodeId != selectedNodeId ||
        oldDelegate.highlightedNodeId != highlightedNodeId ||
        oldDelegate.previewChainNodeIds != previewChainNodeIds ||
        oldDelegate.isDark != isDark;
  }
}
