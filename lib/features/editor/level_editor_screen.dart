import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../models/arrow_direction.dart';
import '../../models/arrow_piece.dart';
import '../../models/board.dart';
import '../../models/level_data.dart';
import '../../models/puzzle_element.dart';
import '../../models/shape_definition.dart';
import '../../models/pattern_definition.dart';
import '../../game/solver/puzzle_solver.dart';
import '../../game/solver/puzzle_validator.dart';
import '../../game/solver/difficulty_analyzer.dart';
import '../../services/storage_service.dart';
import '../gameplay/game_screen.dart';
import '../../game/painters/element_painters.dart';
import '../../game/arrows/arrow_painter.dart';

enum EditorTool {
  arrowUp,
  arrowDown,
  arrowLeft,
  arrowRight,
  lockedArrow,
  switchItem,
  gateItem,
  keyItem,
  portalItem,
  iceItem,
  eraser,
}

class LevelEditorScreen extends StatefulWidget {
  final StorageService storageService;

  const LevelEditorScreen({
    super.key,
    required this.storageService,
  });

  @override
  State<LevelEditorScreen> createState() => _LevelEditorScreenState();
}

class _LevelEditorScreenState extends State<LevelEditorScreen> {
  int _gridSize = 5;
  ShapeDefinition? _selectedShape;
  PatternDefinition? _selectedPattern;
  EditorTool _selectedTool = EditorTool.arrowUp;

  final List<ArrowPiece> _arrows = [];
  final List<GateElement> _gates = [];
  final List<SwitchElement> _switches = [];
  final List<KeyElement> _keys = [];
  final List<PortalElement> _portals = [];
  final List<IceCell> _iceCells = [];

  int _elementIdCounter = 1;

  bool _showGraphView = false;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return Scaffold(
        body: Center(
          child: Text('Level Editor is available in Debug Mode only.',
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_showGraphView ? 'GRAPH VIEW INSPECTOR' : 'NETWORK LEVEL EDITOR'),
        actions: [
          IconButton(
            icon: Icon(_showGraphView ? Icons.grid_view_rounded : Icons.hub_rounded),
            tooltip: _showGraphView ? 'Show Canvas' : 'Show Graph Inspector',
            onPressed: () => setState(() => _showGraphView = !_showGraphView),
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow_rounded),
            tooltip: 'Play Preview',
            onPressed: _playPreview,
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded),
            tooltip: 'Validate Solver',
            onPressed: _validateSolver,
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copy Level JSON',
            onPressed: _copyJson,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Clear Grid',
            onPressed: _clearGrid,
          ),
        ],
      ),
      body: Column(
        children: [
          // Grid Size & Shape Selector Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Text('Shape: ', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<ShapeDefinition?>(
                  value: _selectedShape,
                  hint: const Text('Square Matrix'),
                  items: [
                    const DropdownMenuItem<ShapeDefinition?>(
                      value: null,
                      child: Text('Standard Square Grid'),
                    ),
                    ...ShapeLibrary.allShapes.map((shape) => DropdownMenuItem<ShapeDefinition?>(
                          value: shape,
                          child: Text('${shape.name} (${shape.rows}x${shape.cols})'),
                        )),
                  ],
                  onChanged: (shape) {
                    setState(() {
                      _selectedShape = shape;
                      if (shape != null) {
                        _gridSize = shape.rows > shape.cols ? shape.rows : shape.cols;
                      }
                      _clearGrid();
                    });
                  },
                ),
                const SizedBox(width: 16),
                Text('Items: ${_arrows.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Main Interactive Board Canvas or Graph View Inspector
          Expanded(
            child: _showGraphView
                ? _buildGraphViewOverlay(isDark)
                : Center(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final boardSize = constraints.maxWidth;
                          final cellSize = boardSize / _gridSize;

                          return Container(
                            margin: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.gridBorderLight, width: 2),
                            ),
                            child: GestureDetector(
                              onTapUp: (details) => _handleGridTap(details.localPosition, cellSize),
                              child: Stack(
                                children: [
                                  // Grid lines
                                  _buildGridLines(_gridSize, cellSize, isDark),

                                  if (_selectedShape != null)
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: ShapeSilhouettePainter(
                                          shapeDefinition: _selectedShape!,
                                          cellSize: cellSize,
                                          isDark: isDark,
                                        ),
                                      ),
                                    ),

                                  // Ice cells
                                  ..._iceCells.map((ice) => Positioned(
                                        left: ice.col * cellSize,
                                        top: ice.row * cellSize,
                                        width: cellSize,
                                        height: cellSize,
                                        child: CustomPaint(painter: IcePainter(isDark: isDark)),
                                      )),

                                  // Switches
                                  ..._switches.map((sw) => Positioned(
                                        left: sw.col * cellSize,
                                        top: sw.row * cellSize,
                                        width: cellSize,
                                        height: cellSize,
                                        child: CustomPaint(painter: SwitchPainter(isActivated: sw.isActivated, isDark: isDark)),
                                      )),

                                  // Gates
                                  ..._gates.map((g) => Positioned(
                                        left: g.col * cellSize,
                                        top: g.row * cellSize,
                                        width: cellSize,
                                        height: cellSize,
                                        child: CustomPaint(painter: GatePainter(isOpen: g.isOpen, isDark: isDark)),
                                      )),

                                  // Keys
                                  ..._keys.map((k) => Positioned(
                                        left: k.col * cellSize,
                                        top: k.row * cellSize,
                                        width: cellSize,
                                        height: cellSize,
                                        child: CustomPaint(painter: KeyPainter(isCollected: k.isCollected)),
                                      )),

                                  // Portals
                                  ..._portals.map((p) => Positioned(
                                        left: p.col * cellSize,
                                        top: p.row * cellSize,
                                        width: cellSize,
                                        height: cellSize,
                                        child: CustomPaint(painter: PortalPainter(exitDirection: p.exitDirection, isDark: isDark)),
                                      )),

                                  // Arrows
                                  ..._arrows.map((a) => Positioned(
                                        left: a.column * cellSize,
                                        top: a.row * cellSize,
                                        width: cellSize,
                                        height: cellSize,
                                        child: Stack(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: CustomPaint(
                                                painter: ArrowPainter(direction: a.direction, isDark: isDark),
                                              ),
                                            ),
                                            if (a.isLocked)
                                              const Positioned(
                                                right: 2,
                                                top: 2,
                                                child: Icon(Icons.lock_rounded, size: 14, color: Colors.red),
                                              ),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),

          // Tool Selector Toolbar
          Container(
            height: 85,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildToolButton(EditorTool.arrowUp, Icons.arrow_upward_rounded, 'Up'),
                _buildToolButton(EditorTool.arrowRight, Icons.arrow_forward_rounded, 'Right'),
                _buildToolButton(EditorTool.arrowDown, Icons.arrow_downward_rounded, 'Down'),
                _buildToolButton(EditorTool.arrowLeft, Icons.arrow_back_rounded, 'Left'),
                _buildToolButton(EditorTool.lockedArrow, Icons.lock_rounded, 'Lock Arrow'),
                _buildToolButton(EditorTool.switchItem, Icons.toggle_on_rounded, 'Switch'),
                _buildToolButton(EditorTool.gateItem, Icons.door_sliding_rounded, 'Gate'),
                _buildToolButton(EditorTool.keyItem, Icons.key_rounded, 'Key'),
                _buildToolButton(EditorTool.portalItem, Icons.adjust_rounded, 'Portal'),
                _buildToolButton(EditorTool.iceItem, Icons.ac_unit_rounded, 'Ice'),
                _buildToolButton(EditorTool.eraser, Icons.cleaning_services_rounded, 'Erase'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(EditorTool tool, IconData icon, String label) {
    final isSelected = _selectedTool == tool;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        avatar: Icon(icon, size: 18, color: isSelected ? Colors.white : AppColors.primary),
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedTool = tool),
      ),
    );
  }

  void _handleGridTap(Offset localPos, double cellSize) {
    final col = (localPos.dx / cellSize).floor().clamp(0, _gridSize - 1);
    final row = (localPos.dy / cellSize).floor().clamp(0, _gridSize - 1);

    setState(() {
      // Clear existing item at cell
      _arrows.removeWhere((a) => a.row == row && a.column == col);
      _gates.removeWhere((g) => g.row == row && g.col == col);
      _switches.removeWhere((s) => s.row == row && s.col == col);
      _keys.removeWhere((k) => k.row == row && k.col == col);
      _portals.removeWhere((p) => p.row == row && p.col == col);
      _iceCells.removeWhere((i) => i.row == row && i.col == col);

      final id = 'elem_${_elementIdCounter++}';

      switch (_selectedTool) {
        case EditorTool.arrowUp:
          _arrows.add(ArrowPiece(id: id, row: row, column: col, direction: ArrowDirection.up));
          break;
        case EditorTool.arrowRight:
          _arrows.add(ArrowPiece(id: id, row: row, column: col, direction: ArrowDirection.right));
          break;
        case EditorTool.arrowDown:
          _arrows.add(ArrowPiece(id: id, row: row, column: col, direction: ArrowDirection.down));
          break;
        case EditorTool.arrowLeft:
          _arrows.add(ArrowPiece(id: id, row: row, column: col, direction: ArrowDirection.left));
          break;
        case EditorTool.lockedArrow:
          _arrows.add(ArrowPiece(id: id, row: row, column: col, direction: ArrowDirection.right, isLocked: true, lockId: 'lock_1'));
          break;
        case EditorTool.switchItem:
          _switches.add(SwitchElement(id: id, row: row, col: col, targetGateId: 'gate_1'));
          break;
        case EditorTool.gateItem:
          _gates.add(GateElement(id: 'gate_1', row: row, col: col, isOpen: false));
          break;
        case EditorTool.keyItem:
          _keys.add(KeyElement(id: id, row: row, col: col, targetLockId: 'lock_1'));
          break;
        case EditorTool.portalItem:
          _portals.add(PortalElement(id: id, row: row, col: col, targetPortalId: 'p2', exitDirection: ArrowDirection.right));
          break;
        case EditorTool.iceItem:
          _iceCells.add(IceCell(row: row, col: col));
          break;
        case EditorTool.eraser:
          break;
      }
    });
  }

  void _clearGrid() {
    setState(() {
      _arrows.clear();
      _gates.clear();
      _switches.clear();
      _keys.clear();
      _portals.clear();
      _iceCells.clear();
    });
  }

  Board _createBoard() {
    return Board(
      rows: _selectedPattern?.rows ?? _selectedShape?.rows ?? _gridSize,
      cols: _selectedPattern?.cols ?? _selectedShape?.cols ?? _gridSize,
      shapeDefinition: _selectedShape,
      patternDefinition: _selectedPattern,
      arrows: List.from(_arrows),
      gates: List.from(_gates),
      switches: List.from(_switches),
      keys: List.from(_keys),
      portals: List.from(_portals),
      iceCells: List.from(_iceCells),
    );
  }

  LevelData _createLevelData() {
    return LevelData(
      levelNumber: 999,
      rows: _selectedPattern?.rows ?? _selectedShape?.rows ?? _gridSize,
      cols: _selectedPattern?.cols ?? _selectedShape?.cols ?? _gridSize,
      shapeDefinition: _selectedShape,
      patternDefinition: _selectedPattern,
      initialArrows: List.from(_arrows),
      initialGates: List.from(_gates),
      initialSwitches: List.from(_switches),
      initialKeys: List.from(_keys),
      initialPortals: List.from(_portals),
      initialIceCells: List.from(_iceCells),
      title: _selectedPattern != null
          ? '${_selectedPattern!.name} Custom'
          : (_selectedShape != null ? '${_selectedShape!.name} Custom' : 'Custom Editor Level'),
    );
  }

  void _validateSolver() {
    final board = _createBoard();
    final result = PuzzleValidator.validate(board);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isValid
              ? '✅ VALID (${result.difficulty.label})! Steps: ${result.stepCount} [${result.solutionPath?.join(" -> ")}]'
              : '❌ INVALID! ${result.reason}',
        ),
        backgroundColor: result.isValid ? AppColors.success : AppColors.error,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _playPreview() {
    final levelData = _createLevelData();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          levelNumber: 999,
          customLevel: levelData,
          storageService: widget.storageService,
        ),
      ),
    );
  }

  void _copyJson() {
    final levelData = _createLevelData();
    final jsonStr = levelData.toJson().toString();
    Clipboard.setData(ClipboardData(text: jsonStr));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Level JSON copied to Clipboard!')),
    );
  }

  Widget _buildGraphViewOverlay(bool isDark) {
    final board = _createBoard();
    final result = PuzzleValidator.validate(board);
    final network = board.network;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hub_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'NETWORK GRAPH METRICS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: result.isValid ? AppColors.success : AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  result.isValid ? 'SOLVABLE' : 'UNSOLVABLE',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricChip('Nodes', '${_arrows.length}', isDark),
              _buildMetricChip('Depth', network != null ? '${network.chainDepth}' : '1', isDark),
              _buildMetricChip('Branches', network != null ? '${network.branchCount}' : '0', isDark),
              _buildMetricChip('Crossings', network != null ? '${network.crossingCount}' : '0', isDark),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'SOLUTION SEQUENCE (${result.stepCount} moves):',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.black38 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  result.solutionPath != null && result.solutionPath!.isNotEmpty
                      ? result.solutionPath!.join(' ➔ ')
                      : (result.reason ?? 'No valid solution path detected.'),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
        Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54)),
      ],
    );
  }

  Widget _buildGridLines(int size, double cellSize, bool isDark) {
    final paint = Paint()
      ..color = (isDark ? Colors.white12 : Colors.black12)
      ..strokeWidth = 1;

    return CustomPaint(
      size: Size(cellSize * size, cellSize * size),
      painter: _GridLinePainter(size: size, cellSize: cellSize, linePaint: paint),
    );
  }
}

class _GridLinePainter extends CustomPainter {
  final int size;
  final double cellSize;
  final Paint linePaint;

  _GridLinePainter({required this.size, required this.cellSize, required this.linePaint});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    for (int i = 0; i <= size; i++) {
      canvas.drawLine(Offset(i * cellSize, 0), Offset(i * cellSize, canvasSize.height), linePaint);
      canvas.drawLine(Offset(0, i * cellSize), Offset(canvasSize.width, i * cellSize), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
