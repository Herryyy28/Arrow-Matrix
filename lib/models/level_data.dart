import 'arrow_piece.dart';
import 'board.dart';
import 'puzzle_element.dart';
import 'shape_definition.dart';
import 'pattern_definition.dart';
import 'arrow_network.dart';

class LevelData {
  final int levelNumber;
  final int rows;
  final int cols;
  final ShapeDefinition? shapeDefinition;
  final PatternDefinition? patternDefinition;
  final ArrowNetwork? network;
  final List<ArrowPiece> initialArrows;
  final List<GateElement> initialGates;
  final List<SwitchElement> initialSwitches;
  final List<KeyElement> initialKeys;
  final List<PortalElement> initialPortals;
  final List<IceCell> initialIceCells;
  final List<ObstacleElement> initialObstacles;
  final List<MovingWall> initialMovingWalls;
  final List<RotatingSection> initialRotatingSections;
  final String title;
  final int worldNumber;
  final String difficultyLabel;

  const LevelData({
    required this.levelNumber,
    required this.rows,
    required this.cols,
    this.shapeDefinition,
    this.patternDefinition,
    this.network,
    required this.initialArrows,
    this.initialGates = const [],
    this.initialSwitches = const [],
    this.initialKeys = const [],
    this.initialPortals = const [],
    this.initialIceCells = const [],
    this.initialObstacles = const [],
    this.initialMovingWalls = const [],
    this.initialRotatingSections = const [],
    this.title = '',
    this.worldNumber = 1,
    this.difficultyLabel = 'EASY',
  });

  Board createInitialBoard() {
    return Board(
      rows: rows,
      cols: cols,
      shapeDefinition: shapeDefinition,
      patternDefinition: patternDefinition,
      network: network,
      arrows: initialArrows.map((a) => a.copyWith(isRemoved: false, isMoving: false)).toList(),
      gates: initialGates.map((g) => g.copyWith()).toList(),
      switches: initialSwitches.map((s) => s.copyWith()).toList(),
      keys: initialKeys.map((k) => k.copyWith()).toList(),
      portals: initialPortals.map((p) => p.copyWith()).toList(),
      iceCells: List<IceCell>.from(initialIceCells),
      obstacles: initialObstacles.map((o) => ObstacleElement(id: o.id, row: o.row, col: o.col)).toList(),
      movingWalls: initialMovingWalls.map((mw) => mw.copyWith()).toList(),
      rotatingSections: initialRotatingSections.map((rs) => rs.copyWith()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'levelNumber': levelNumber,
        'rows': rows,
        'cols': cols,
        'shapeDefinition': shapeDefinition?.toJson(),
        'patternDefinition': patternDefinition?.toJson(),
        'network': network?.toJson(),
        'title': title,
        'worldNumber': worldNumber,
        'difficultyLabel': difficultyLabel,
        'initialArrows': initialArrows.map((a) => a.toJson()).toList(),
        'initialGates': initialGates.map((g) => g.toJson()).toList(),
        'initialSwitches': initialSwitches.map((s) => s.toJson()).toList(),
        'initialKeys': initialKeys.map((k) => k.toJson()).toList(),
        'initialPortals': initialPortals.map((p) => p.toJson()).toList(),
        'initialIceCells': initialIceCells.map((i) => i.toJson()).toList(),
        'initialObstacles': initialObstacles.map((o) => o.toJson()).toList(),
        'initialMovingWalls': initialMovingWalls.map((mw) => mw.toJson()).toList(),
        'initialRotatingSections': initialRotatingSections.map((rs) => rs.toJson()).toList(),
      };

  factory LevelData.fromJson(Map<String, dynamic> json) => LevelData(
        levelNumber: json['levelNumber'] as int,
        rows: json['rows'] as int,
        cols: json['cols'] as int,
        shapeDefinition: json['shapeDefinition'] != null
            ? ShapeDefinition.fromJson(json['shapeDefinition'] as Map<String, dynamic>)
            : null,
        patternDefinition: json['patternDefinition'] != null
            ? PatternDefinition.fromJson(json['patternDefinition'] as Map<String, dynamic>)
            : null,
        network: json['network'] != null
            ? ArrowNetwork.fromJson(json['network'] as Map<String, dynamic>)
            : null,
        title: json['title'] as String? ?? '',
        worldNumber: json['worldNumber'] as int? ?? 1,
        difficultyLabel: json['difficultyLabel'] as String? ?? 'EASY',
        initialArrows: (json['initialArrows'] as List<dynamic>)
            .map((item) => ArrowPiece.fromJson(item as Map<String, dynamic>))
            .toList(),
        initialGates: ((json['initialGates'] as List<dynamic>?) ?? [])
            .map((item) => GateElement.fromJson(item as Map<String, dynamic>))
            .toList(),
        initialSwitches: ((json['initialSwitches'] as List<dynamic>?) ?? [])
            .map((item) => SwitchElement.fromJson(item as Map<String, dynamic>))
            .toList(),
        initialKeys: ((json['initialKeys'] as List<dynamic>?) ?? [])
            .map((item) => KeyElement.fromJson(item as Map<String, dynamic>))
            .toList(),
        initialPortals: ((json['initialPortals'] as List<dynamic>?) ?? [])
            .map((item) => PortalElement.fromJson(item as Map<String, dynamic>))
            .toList(),
        initialIceCells: ((json['initialIceCells'] as List<dynamic>?) ?? [])
            .map((item) => IceCell.fromJson(item as Map<String, dynamic>))
            .toList(),
        initialObstacles: ((json['initialObstacles'] as List<dynamic>?) ?? [])
            .map((item) => ObstacleElement.fromJson(item as Map<String, dynamic>))
            .toList(),
        initialMovingWalls: ((json['initialMovingWalls'] as List<dynamic>?) ?? [])
            .map((item) => MovingWall.fromJson(item as Map<String, dynamic>))
            .toList(),
        initialRotatingSections: ((json['initialRotatingSections'] as List<dynamic>?) ?? [])
            .map((item) => RotatingSection.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}
