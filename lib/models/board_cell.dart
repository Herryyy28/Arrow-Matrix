import 'arrow_piece.dart';

class BoardCell {
  final int row;
  final int column;
  final ArrowPiece? arrow;

  const BoardCell({
    required this.row,
    required this.column,
    this.arrow,
  });

  bool get isEmpty => arrow == null || arrow!.isRemoved;
  bool get isOccupied => !isEmpty;

  BoardCell copyWith({
    int? row,
    int? column,
    ArrowPiece? arrow,
    bool clearArrow = false,
  }) {
    return BoardCell(
      row: row ?? this.row,
      column: column ?? this.column,
      arrow: clearArrow ? null : (arrow ?? this.arrow),
    );
  }
}
