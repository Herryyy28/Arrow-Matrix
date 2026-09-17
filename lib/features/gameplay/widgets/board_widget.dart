import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../game/arrows/arrow_painter.dart';
import '../../../game/board/board_controller.dart';
import '../../../game/painters/element_painters.dart';
import '../../../game/painters/network_painter.dart';
import '../../../models/board.dart';
import '../../../models/shape_definition.dart';

import '../../../game/painters/maze_path_painter.dart';
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
                padding: EdgeInsets.zero,
                color: Colors.transparent,
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

                              // 1c. Continuous Luminous Maze Path Engine
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: CustomPaint(
                                    painter: MazePathPainter(
                                      board: board,
                                      cellSize: cellSize,
                                      selectedArrowId: widget.controller.guidanceArrowId,
                                      guidanceArrowId: widget.controller.highlightedArrowId,
                                      invalidArrowId: widget.controller.invalidArrowId,
                                      unlockedArrowIds: widget.controller.unlockedArrowIds,
                                      activeAnimation: widget.controller.activePathAnimation,
                                      isDark: isDark,
                                      developerDebugMode: widget.controller.developerDebugMode,
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

                        // 8. Interactive Gesture Layer for Arrow Cells (No Overlay Icons)
                        ...board.arrows.map((arrow) {
                          if (arrow.isRemoved || arrow.isMoving) return const SizedBox.shrink();

                          return Positioned(
                            key: ValueKey(arrow.id),
                            left: arrow.column * cellSize,
                            top: arrow.row * cellSize,
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
                              child: Container(
                                color: Colors.transparent,
                                child: arrow.isLocked
                                    ? Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          margin: const EdgeInsets.all(3),
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade700,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.lock_rounded,
                                            size: 11,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    : null,
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
    // VISUAL GRID COMPLETELY REMOVED per user request.
    // The logical grid remains active in the Board engine, but is 100% invisible visually.
  }

  @override
  bool shouldRepaint(covariant _BoardGridPainter oldDelegate) => false;
}
