import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../game/arrows/arrow_painter.dart';
import '../models/level_data.dart';

class MiniPuzzlePreview extends StatelessWidget {
  final LevelData levelData;
  final double size;

  const MiniPuzzlePreview({
    super.key,
    required this.levelData,
    this.size = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rows = levelData.rows;
    final cols = levelData.cols;
    final maxDim = math.max(1, math.max(rows, cols));
    final innerSize = math.max(10.0, size - 12.0);
    final cellSize = innerSize / maxDim;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppColors.gridBorderDark : AppColors.gridBorderLight).withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: innerSize,
          height: innerSize,
          child: Stack(
            children: [
              // Grid Background Lines via CustomPaint (Zero RenderFlex overflow risk)
              CustomPaint(
                size: Size(innerSize, innerSize),
                painter: _MiniGridPainter(
                  rows: rows,
                  cols: cols,
                  cellSize: cellSize,
                  isDark: isDark,
                ),
              ),

              // Mini Arrow Pieces
              ...levelData.initialArrows.take(12).map((arrow) {
                return Positioned(
                  left: arrow.column * cellSize,
                  top: arrow.row * cellSize,
                  width: cellSize,
                  height: cellSize,
                  child: Padding(
                    padding: const EdgeInsets.all(1.5),
                    child: CustomPaint(
                      size: Size(math.max(2.0, cellSize - 3), math.max(2.0, cellSize - 3)),
                      painter: ArrowPainter(
                        direction: arrow.direction,
                        isDark: isDark,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniGridPainter extends CustomPainter {
  final int rows;
  final int cols;
  final double cellSize;
  final bool isDark;

  _MiniGridPainter({
    required this.rows,
    required this.cols,
    required this.cellSize,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? AppColors.gridBorderDark : AppColors.gridBorderLight).withValues(alpha: 0.15)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final rect = Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize);
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MiniGridPainter oldDelegate) {
    return oldDelegate.rows != rows ||
        oldDelegate.cols != cols ||
        oldDelegate.cellSize != cellSize ||
        oldDelegate.isDark != isDark;
  }
}
