import 'dart:math';
import 'arrow_piece.dart';

/// Represents explicit states of an arrow node in the connected logic engine.
enum ArrowState {
  available,
  blocked,
  selected,
  moving,
  exiting,
  cleared,
  locked,
}

/// Explicit occupancy system tracking cell and segment claims across the board grid.
class ArrowOccupancyModel {
  final Map<Point<int>, String> _occupiedCells = {};

  ArrowOccupancyModel();

  /// Checks if (r, c) is occupied by an active arrow other than currentArrowId.
  bool isCellOccupied(int r, int c, String currentArrowId) {
    final occupantId = _occupiedCells[Point(r, c)];
    return occupantId != null && occupantId != currentArrowId;
  }

  /// Claims grid cell occupancy along an arrow piece's path.
  void claimOccupancy(String arrowId, List<Point<int>> pathCells) {
    for (final cell in pathCells) {
      _occupiedCells[cell] = arrowId;
    }
  }

  /// Releases grid cell occupancy for a cleared arrow.
  void releaseOccupancy(String arrowId) {
    _occupiedCells.removeWhere((_, id) => id == arrowId);
  }

  /// Clears all claimed occupancy mappings.
  void clear() {
    _occupiedCells.clear();
  }

  /// Rebuilds occupancy map from a list of active arrows and board geometry.
  static ArrowOccupancyModel buildFromArrows(List<ArrowPiece> arrows) {
    final model = ArrowOccupancyModel();
    for (final arrow in arrows) {
      if (!arrow.isRemoved && !arrow.isMoving) {
        model.claimOccupancy(arrow.id, [Point(arrow.row, arrow.column)]);
      }
    }
    return model;
  }
}
