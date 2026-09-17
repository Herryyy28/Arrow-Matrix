import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../game/arrows/arrow_painter.dart';
import '../../../game/board/board_controller.dart';
import '../../../game/painters/element_painters.dart';
import '../../../game/painters/network_painter.dart';
import '../../../models/board.dart';
import '../../../models/shape_definition.dart';

import '../../../widgets/game_particle_overlay.dart';

class BoardWidget extends StatefulWidget {
  final BoardController controller;
  final ParticleController? particleController;

  const BoardWidget({
    super.key,
    required this.controller,
    this.particleController,
  });

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late TransformationController _transformationController;
  String? _lastInvalidId;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _resetCamera() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final board = widget.controller.board;
        if (board == null) return const SizedBox.shrink();

        if (widget.controller.invalidArrowId != null && widget.controller.invalidArrowId != _lastInvalidId) {
          _lastInvalidId = widget.controller.invalidArrowId;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_shakeController.isAnimating) {
              _shakeController.forward(from: 0.0);
              final arrow = board.arrows.firstWhere(
                (a) => a.id == widget.controller.invalidArrowId,
                orElse: () => board.arrows.first,
              );
              final maxDim = math.max(1, math.max(board.rows, board.cols));
              final cellSize = 300.0 / maxDim; // Approx scale offset
              final center = Offset(
                (arrow.column + 0.5) * cellSize,
                (arrow.row + 0.5) * cellSize,
              );
              widget.particleController?.spawnInvalidImpact(center);
            }
          });
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final reduceMotion = widget.controller.storageService.isReduceMotion();
        final previewPath = widget.controller.previewPath;

        return LayoutBuilder(
          builder: (context, constraints) {
            final maxAvailable = math.min(constraints.maxWidth, constraints.maxHeight);
            final boardSize = math.max(0.0, maxAvailable);
            final maxDim = math.max(1, math.max(board.rows, board.cols));
            final cellSize = boardSize / maxDim;

            return AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final shakeOffset = math.sin(_shakeController.value * math.pi * 4) * 6.0;
                return Transform.translate(
                  offset: Offset(widget.controller.invalidArrowId != null ? shakeOffset : 0, 0),
                  child: child,
                );
              },
              child: Container(
                width: boardSize,
                height: boardSize,
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ],
                  border: Border.all(
                    color: isDark ? AppColors.gridBorderDark : AppColors.gridBorderLight,
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 0.75,
                      maxScale: 3.0,
                      boundaryMargin: const EdgeInsets.all(32),
                      clipBehavior: Clip.hardEdge,
                      child: RepaintBoundary(
                        child: GestureDetector(
                          onTapUp: (details) {
                            if (cellSize > 0) {
                              final col = (details.localPosition.dx / cellSize).floor();
                              final row = (details.localPosition.dy / cellSize).floor();
                              if (board.isWithinBounds(row, col)) {
                                final arrow = board.getArrowAt(row, col);
                                if (arrow != null && !arrow.isRemoved && !arrow.isMoving) {
                                  widget.controller.onArrowTapped(arrow);
                                }
                              }
                            }
                          },
                          behavior: HitTestBehavior.translucent,
                          child: Stack(
                            children: [
                              // 1. Grid Cells Background
                              _buildGridBackground(board, cellSize, isDark),

                              // 1b. Network Connections Layer
                              if (board.network != null)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: CustomPaint(
                                      painter: NetworkGraphPainter(
                                        network: board.network,
                                        cellSize: cellSize,
                                        selectedNodeId: widget.controller.guidanceArrowId,
                                        highlightedNodeId: widget.controller.highlightedArrowId,
                                        isDark: isDark,
                                      ),
                                    ),
                                  ),
                                ),

                              // 2. Ice Cells Layer
                        ...board.iceCells.map((ice) => Positioned(
                              left: ice.col * cellSize,
                              top: ice.row * cellSize,
                              width: cellSize,
                              height: cellSize,
                              child: IgnorePointer(
                                child: CustomPaint(painter: IcePainter(isDark: isDark)),
                              ),
                            )),

                        // 3. Switches Layer
                        ...board.switches.map((sw) => Positioned(
                              left: sw.col * cellSize,
                              top: sw.row * cellSize,
                              width: cellSize,
                              height: cellSize,
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: SwitchPainter(isActivated: sw.isActivated, isDark: isDark),
                                ),
                              ),
                            )),

                        // 4. Gates Layer
                        ...board.gates.map((gate) => Positioned(
                              left: gate.col * cellSize,
                              top: gate.row * cellSize,
                              width: cellSize,
                              height: cellSize,
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: GatePainter(isOpen: gate.isOpen, isDark: isDark),
                                ),
                              ),
                            )),

                        // 5. Keys Layer
                        ...board.keys.map((key) {
                          if (key.isCollected) return const SizedBox.shrink();
                          return Positioned(
                            left: key.col * cellSize,
                            top: key.row * cellSize,
                            width: cellSize,
                            height: cellSize,
                            child: IgnorePointer(
                              child: CustomPaint(painter: KeyPainter(isCollected: key.isCollected)),
                            ),
                          );
                        }),

                        // 6. Portals Layer
                        ...board.portals.map((portal) => Positioned(
                              left: portal.col * cellSize,
                              top: portal.row * cellSize,
                              width: cellSize,
                              height: cellSize,
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: PortalPainter(exitDirection: portal.exitDirection, isDark: isDark),
                                ),
                              ),
                            )),

                        // 6b. Moving Walls Layer
                        ...board.movingWalls.map((wall) => Positioned(
                              left: wall.currentDirectionCol * cellSize,
                              top: wall.currentDirectionRow * cellSize,
                              width: cellSize,
                              height: cellSize,
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: MovingWallPainter(isMoved: wall.isMoved, isDark: isDark),
                                ),
                              ),
                            )),

                        // 7. Path Preview Line Layer
                        if (previewPath != null)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: PathPreviewPainter(
                                  pathCells: previewPath.pathCells,
                                  cellSize: cellSize,
                                  isExitValid: previewPath.isExitValid,
                                  isDark: isDark,
                                ),
                              ),
                            ),
                          ),

                        // 8. Arrows Layer
                        ...board.arrows.map((arrow) {
                          if (arrow.isRemoved) return const SizedBox.shrink();

                          final isInvalid = widget.controller.invalidArrowId == arrow.id;
                          final isHighlighted = widget.controller.highlightedArrowId == arrow.id;
                          final isGuidanceActive = widget.controller.guidanceArrowId == arrow.id;
                          final guidanceClear = widget.controller.guidancePathClear;

                          double targetX = arrow.column * cellSize;
                          double targetY = arrow.row * cellSize;

                          if (arrow.isMoving) {
                            targetX += arrow.direction.dc * cellSize * (board.cols + 1);
                            targetY += arrow.direction.dr * cellSize * (board.rows + 1);
                          }

                          return AnimatedPositioned(
                            key: ValueKey(arrow.id),
                            duration: reduceMotion
                                ? Duration.zero
                                : Duration(milliseconds: arrow.isMoving ? 280 : 0),
                            curve: Curves.easeOutCubic,
                            left: targetX,
                            top: targetY,
                            width: cellSize,
                            height: cellSize,
                            child: GestureDetector(
                              onTap: () {
                                widget.controller.onArrowTapped(arrow);
                                final origin = Offset(
                                  (arrow.column + 0.5) * cellSize,
                                  (arrow.row + 0.5) * cellSize,
                                );
                                final dirVector = Offset(arrow.direction.dc.toDouble(), arrow.direction.dr.toDouble());
                                widget.particleController?.spawnExitTrail(
                                  origin,
                                  dirVector,
                                  isDark ? AppColors.warning : AppColors.primary,
                                );
                              },
                              onLongPressStart: (_) => widget.controller.showGuidance(arrow),
                              onLongPressEnd: (_) => widget.controller.clearGuidance(),
                              onLongPressCancel: () => widget.controller.clearGuidance(),
                              behavior: HitTestBehavior.opaque,
                              child: AnimatedScale(
                                scale: (!reduceMotion && arrow.isMoving)
                                    ? 1.12
                                    : ((!reduceMotion && (isHighlighted || isGuidanceActive)) ? 1.10 : 1.0),
                                duration: reduceMotion
                                    ? Duration.zero
                                    : const Duration(milliseconds: 150),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: RepaintBoundary(
                                        child: CustomPaint(
                                          size: Size(cellSize - 6, cellSize - 6),
                                          painter: ArrowPainter(
                                            direction: arrow.direction,
                                            isHighlighted: isHighlighted || (isGuidanceActive && (guidanceClear == true)),
                                            isInvalid: isInvalid || (isGuidanceActive && (guidanceClear == false)),
                                            isDark: isDark,
                                            isStartArrow: arrow.isStartArrow,
                                            isKeyArrow: arrow.isKeyArrow,
                                            isTransformedToKey: arrow.isTransformedToKey,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (arrow.isLocked)
                                      Positioned(
                                        right: 2,
                                        top: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade700,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.lock_rounded,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black54 : Colors.white70),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.center_focus_strong_rounded, size: 20),
                    tooltip: 'Fit Pattern / Reset Camera',
                    onPressed: _resetCamera,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
},
);
}

  Widget _buildGridBackground(Board board, double cellSize, bool isDark) {
    return RepaintBoundary(
      child: Stack(
        children: [
          CustomPaint(
            size: Size(cellSize * board.cols, cellSize * board.rows),
            painter: _BoardGridPainter(
              rows: board.rows,
              cols: board.cols,
              cellSize: cellSize,
              isDark: isDark,
              shapeDefinition: board.shapeDefinition,
            ),
          ),
          if (board.shapeDefinition != null)
            CustomPaint(
              size: Size(cellSize * board.cols, cellSize * board.rows),
              painter: ShapeSilhouettePainter(
                shapeDefinition: board.shapeDefinition!,
                cellSize: cellSize,
                isDark: isDark,
              ),
            ),
        ],
      ),
    );
  }
}

class _BoardGridPainter extends CustomPainter {
  final int rows;
  final int cols;
  final double cellSize;
  final bool isDark;
  final ShapeDefinition? shapeDefinition;

  _BoardGridPainter({
    required this.rows,
    required this.cols,
    required this.cellSize,
    required this.isDark,
    this.shapeDefinition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Simple Grid View: Render subtle clean cell outlines for 5x5 to 8x8 grid board
    final paint = Paint()
      ..color = (isDark ? AppColors.gridBorderDark : AppColors.gridBorderLight).withValues(alpha: 0.15)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (shapeDefinition != null && !shapeDefinition!.isPlayable(r, c)) {
          continue; // Skip grid lines outside the shape silhouette
        }
        final rect = Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize);
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BoardGridPainter oldDelegate) {
    return oldDelegate.rows != rows ||
        oldDelegate.cols != cols ||
        oldDelegate.cellSize != cellSize ||
        oldDelegate.isDark != isDark ||
        oldDelegate.shapeDefinition?.id != shapeDefinition?.id;
  }
}
