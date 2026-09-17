import 'dart:math';
import 'arrow_direction.dart';
import 'arrow_piece.dart';
import 'arrow_state.dart';
import 'puzzle_element.dart';
import 'shape_definition.dart';
import 'pattern_definition.dart';
import 'arrow_network.dart';

class ArrowExitPath {
  final bool isExitValid;
  final List<Point<int>> pathCells;
  final ArrowPiece? blockedByArrow;
  final GateElement? blockedByGate;
  final ObstacleElement? blockedByObstacle;
  final MovingWall? blockedByMovingWall;
  final bool blockedByLock;
  final List<SwitchElement> triggeredSwitches;
  final List<KeyElement> collectedKeys;
  final List<PortalElement> portalsTraversed;

  const ArrowExitPath({
    required this.isExitValid,
    required this.pathCells,
    this.blockedByArrow,
    this.blockedByGate,
    this.blockedByObstacle,
    this.blockedByMovingWall,
    this.blockedByLock = false,
    this.triggeredSwitches = const [],
    this.collectedKeys = const [],
    this.portalsTraversed = const [],
  });
}

class Board {
  final int rows;
  final int cols;
  final ShapeDefinition? shapeDefinition;
  final PatternDefinition? patternDefinition;
  final ArrowNetwork? network;
  final List<ArrowPiece> arrows;
  final List<GateElement> gates;
  final List<SwitchElement> switches;
  final List<KeyElement> keys;
  final List<PortalElement> portals;
  final List<IceCell> iceCells;
  final List<ObstacleElement> obstacles;
  final List<MovingWall> movingWalls;
  final List<RotatingSection> rotatingSections;

  Board({
    required this.rows,
    required this.cols,
    this.shapeDefinition,
    this.patternDefinition,
    this.network,
    required this.arrows,
    this.gates = const [],
    this.switches = const [],
    this.keys = const [],
    this.portals = const [],
    this.iceCells = const [],
    this.obstacles = const [],
    this.movingWalls = const [],
    this.rotatingSections = const [],
  });

  /// Build occupancy model representing current active board claims.
  ArrowOccupancyModel get occupancyModel => ArrowOccupancyModel.buildFromArrows(arrows);

  /// Checks if a given cell belongs to the active playable silhouette or pattern mask.
  bool isCellPlayable(int r, int c) {
    if (!isWithinBounds(r, c)) return false;
    if (patternDefinition != null) {
      return patternDefinition!.isPlayable(r, c);
    }
    if (shapeDefinition != null) {
      return shapeDefinition!.isPlayable(r, c);
    }
    return true;
  }

  /// Checks if a given row and column are within board bounds.
  bool isWithinBounds(int r, int c) {
    return r >= 0 && r < rows && c >= 0 && c < cols;
  }

  /// Gets the non-removed arrow piece at the specified row and column.
  ArrowPiece? getArrowAt(int r, int c) {
    for (final arrow in arrows) {
      if (!arrow.isRemoved && arrow.row == r && arrow.column == c) {
        return arrow;
      }
    }
    return null;
  }

  /// Gets closed gate at (r, c).
  GateElement? getClosedGateAt(int r, int c) {
    for (final g in gates) {
      if (!g.isOpen && g.row == r && g.col == c) {
        return g;
      }
    }
    return null;
  }

  /// Gets obstacle at (r, c).
  ObstacleElement? getObstacleAt(int r, int c) {
    for (final o in obstacles) {
      if (o.row == r && o.col == c) {
        return o;
      }
    }
    return null;
  }

  /// Gets uncollected key at (r, c).
  KeyElement? getUncollectedKeyAt(int r, int c) {
    for (final k in keys) {
      if (!k.isCollected && k.row == r && k.col == c) {
        return k;
      }
    }
    return null;
  }

  /// Gets switch at (r, c).
  SwitchElement? getSwitchAt(int r, int c) {
    for (final s in switches) {
      if (s.row == r && s.col == c) {
        return s;
      }
    }
    return null;
  }

  /// Gets portal at (r, c).
  PortalElement? getPortalAt(int r, int c) {
    for (final p in portals) {
      if (p.row == r && p.col == c) {
        return p;
      }
    }
    return null;
  }

  /// Checks if (r, c) is ice.
  bool isIceAt(int r, int c) {
    return iceCells.any((ice) => ice.row == r && ice.col == c);
  }

  /// Calculates complete exit trajectory for an arrow, supporting polyline bent paths.
  ArrowExitPath calculateArrowPath(ArrowPiece arrow) {
    if (arrow.isRemoved) {
      return const ArrowExitPath(isExitValid: false, pathCells: []);
    }

    if (arrow.isLocked) {
      return ArrowExitPath(
        isExitValid: false,
        pathCells: [Point(arrow.row, arrow.column)],
        blockedByLock: true,
      );
    }

    final pathCells = <Point<int>>[Point(arrow.row, arrow.column)];
    final triggeredSwitches = <SwitchElement>[];
    final collectedKeys = <KeyElement>[];
    final portalsTraversed = <PortalElement>[];

    int currR = arrow.row;
    int currC = arrow.column;
    final directions = arrow.effectivePathPattern;

    int steps = 0;
    const maxSteps = 100; // prevent infinite loops in broken portal configs

    for (final dir in directions) {
      ArrowDirection currDir = dir;
      bool segmentEnded = false;

      while (!segmentEnded && steps < maxSteps) {
        steps++;
        currR += currDir.dr;
        currC += currDir.dc;

        if (!isWithinBounds(currR, currC)) {
          // Exited board bound along this direction segment!
          segmentEnded = true;
          break;
        }

        // Check blockers at current cell
        final blockingArrow = getArrowAt(currR, currC);
        if (blockingArrow != null && blockingArrow.id != arrow.id) {
          return ArrowExitPath(
            isExitValid: false,
            pathCells: pathCells,
            blockedByArrow: blockingArrow,
            triggeredSwitches: triggeredSwitches,
            collectedKeys: collectedKeys,
            portalsTraversed: portalsTraversed,
          );
        }

        final closedGate = getClosedGateAt(currR, currC);
        if (closedGate != null) {
          return ArrowExitPath(
            isExitValid: false,
            pathCells: pathCells,
            blockedByGate: closedGate,
            triggeredSwitches: triggeredSwitches,
            collectedKeys: collectedKeys,
            portalsTraversed: portalsTraversed,
          );
        }

        final obstacle = getObstacleAt(currR, currC);
        if (obstacle != null) {
          return ArrowExitPath(
            isExitValid: false,
            pathCells: pathCells,
            blockedByObstacle: obstacle,
            triggeredSwitches: triggeredSwitches,
            collectedKeys: collectedKeys,
            portalsTraversed: portalsTraversed,
          );
        }

        final movingWall = getMovingWallAt(currR, currC);
        if (movingWall != null) {
          return ArrowExitPath(
            isExitValid: false,
            pathCells: pathCells,
            blockedByMovingWall: movingWall,
            triggeredSwitches: triggeredSwitches,
            collectedKeys: collectedKeys,
            portalsTraversed: portalsTraversed,
          );
        }

        // Record path step
        pathCells.add(Point(currR, currC));

        // Trigger switch if present
        final sw = getSwitchAt(currR, currC);
        if (sw != null && !triggeredSwitches.any((s) => s.id == sw.id)) {
          triggeredSwitches.add(sw);
        }

        // Collect key if present
        final key = getUncollectedKeyAt(currR, currC);
        if (key != null && !collectedKeys.any((k) => k.id == key.id)) {
          collectedKeys.add(key);
        }

        // Handle Portal warp
        final portal = getPortalAt(currR, currC);
        if (portal != null && !portalsTraversed.any((p) => p.id == portal.id)) {
          portalsTraversed.add(portal);
          final destPortal = portals.firstWhere(
            (p) => p.id == portal.targetPortalId,
            orElse: () => portal,
          );
          currR = destPortal.row;
          currC = destPortal.col;
          currDir = destPortal.exitDirection;
          pathCells.add(Point(currR, currC));
        }

        // If polyline has multiple segments, switch segment after 1 grid cell advance
        if (directions.length > 1) {
          segmentEnded = true;
        }
      }
    }

    return ArrowExitPath(
      isExitValid: true,
      pathCells: pathCells,
      triggeredSwitches: triggeredSwitches,
      collectedKeys: collectedKeys,
      portalsTraversed: portalsTraversed,
    );
  }

  /// Gets moving wall at (r, c) based on its current position state.
  MovingWall? getMovingWallAt(int r, int c) {
    for (final wall in movingWalls) {
      if (wall.currentDirectionRow == r && wall.currentDirectionCol == c) {
        return wall;
      }
    }
    return null;
  }

  /// Gets rotating section at (r, c).
  RotatingSection? getRotatingSectionAt(int r, int c) {
    for (final sec in rotatingSections) {
      if (sec.row == r && sec.col == c) {
        return sec;
      }
    }
    return null;
  }

  /// Checks whether an arrow at the given position can exit the board cleanly.
  bool canArrowExit(ArrowPiece arrow) {
    if (network != null) {
      final node = network!.nodes.firstWhere(
        (n) => n.id == arrow.id,
        orElse: () => ArrowNode(
          id: arrow.id,
          row: arrow.row,
          col: arrow.column,
          direction: arrow.direction,
        ),
      );

      for (final depId in node.dependsOnIds) {
        final depArrow = arrows.firstWhere(
          (a) => a.id == depId,
          orElse: () => arrow,
        );
        if (!depArrow.isRemoved && depArrow.id != arrow.id) {
          return false; // Prerequisite dependent arrow still blocked!
        }
      }
    }

    return calculateArrowPath(arrow).isExitValid;
  }

  /// Returns a list of all currently removable arrows on the board.
  List<ArrowPiece> getRemovableArrows() {
    final removable = <ArrowPiece>[];
    for (final arrow in arrows) {
      if (!arrow.isRemoved && canArrowExit(arrow)) {
        removable.add(arrow);
      }
    }
    return removable;
  }

  /// Checks if all arrows on the board have been removed.
  bool get isCleared {
    return arrows.every((arrow) => arrow.isRemoved);
  }

  /// Number of remaining active arrows on the board.
  int get activeArrowCount {
    return arrows.where((arrow) => !arrow.isRemoved).length;
  }

  /// Returns designated or first active start arrow.
  ArrowPiece? get startArrow {
    final active = arrows.where((a) => !a.isRemoved).toList();
    if (active.isEmpty) return null;
    return active.firstWhere((a) => a.isStartArrow, orElse: () => active.first);
  }

  /// Returns final key arrow (or remaining arrow if only 1 arrow left).
  ArrowPiece? get finalKeyArrow {
    final active = arrows.where((a) => !a.isRemoved).toList();
    if (active.isEmpty) return null;
    return active.firstWhere(
      (a) => a.isKeyArrow || a.isTransformedToKey,
      orElse: () => active.last,
    );
  }

  /// Mark arrow as removed and trigger key transformation when 1 arrow remains.
  Board removeArrow(String arrowId) {
    final updatedArrows = arrows.map((a) {
      if (a.id == arrowId) {
        return a.copyWith(isRemoved: true, isMoving: false);
      }
      return a;
    }).toList();

    final remaining = updatedArrows.where((a) => !a.isRemoved).toList();
    if (remaining.length == 1) {
      final keyIndex = updatedArrows.indexWhere((a) => a.id == remaining.first.id);
      if (keyIndex != -1) {
        updatedArrows[keyIndex] = updatedArrows[keyIndex].copyWith(
          isKeyArrow: true,
          isTransformedToKey: true,
        );
      }
    }

    return copyWith(arrows: updatedArrows);
  }

  /// Creates a deep copy of the board state.
  Board copyWith({
    int? rows,
    int? cols,
    ShapeDefinition? shapeDefinition,
    PatternDefinition? patternDefinition,
    ArrowNetwork? network,
    List<ArrowPiece>? arrows,
    List<GateElement>? gates,
    List<SwitchElement>? switches,
    List<KeyElement>? keys,
    List<PortalElement>? portals,
    List<IceCell>? iceCells,
    List<ObstacleElement>? obstacles,
    List<MovingWall>? movingWalls,
    List<RotatingSection>? rotatingSections,
  }) {
    return Board(
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      shapeDefinition: shapeDefinition ?? this.shapeDefinition,
      patternDefinition: patternDefinition ?? this.patternDefinition,
      network: network ?? this.network,
      arrows: arrows != null
          ? arrows.map((a) => a.copyWith()).toList()
          : this.arrows.map((a) => a.copyWith()).toList(),
      gates: gates != null
          ? gates.map((g) => g.copyWith()).toList()
          : this.gates.map((g) => g.copyWith()).toList(),
      switches: switches != null
          ? switches.map((s) => s.copyWith()).toList()
          : this.switches.map((s) => s.copyWith()).toList(),
      keys: keys != null
          ? keys.map((k) => k.copyWith()).toList()
          : this.keys.map((k) => k.copyWith()).toList(),
      portals: portals != null
          ? portals.map((p) => p.copyWith()).toList()
          : this.portals.map((p) => p.copyWith()).toList(),
      iceCells: iceCells != null ? List<IceCell>.from(iceCells) : List<IceCell>.from(this.iceCells),
      obstacles: obstacles != null
          ? obstacles.map((o) => ObstacleElement(id: o.id, row: o.row, col: o.col)).toList()
          : List<ObstacleElement>.from(this.obstacles),
      movingWalls: movingWalls != null
          ? movingWalls.map((mw) => mw.copyWith()).toList()
          : this.movingWalls.map((mw) => mw.copyWith()).toList(),
      rotatingSections: rotatingSections != null
          ? rotatingSections.map((rs) => rs.copyWith()).toList()
          : this.rotatingSections.map((rs) => rs.copyWith()).toList(),
    );
  }
}
