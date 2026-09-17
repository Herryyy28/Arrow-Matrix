import 'arrow_direction.dart';
import 'arrow_state.dart';

class ArrowPiece {
  final String id;
  final int row;
  final int column;
  final ArrowDirection direction;
  final List<ArrowDirection>? pathPattern;
  final int length;
  final ArrowState state;
  final bool isMoving;
  final bool isRemoved;
  final bool isHighlighted;
  final bool isLocked;
  final bool isStartArrow;
  final bool isKeyArrow;
  final bool isTransformedToKey;
  final String? lockId;
  final double rotationDegrees;

  const ArrowPiece({
    required this.id,
    required this.row,
    required this.column,
    required this.direction,
    this.pathPattern,
    this.length = 1,
    this.state = ArrowState.available,
    this.isMoving = false,
    this.isRemoved = false,
    this.isHighlighted = false,
    this.isLocked = false,
    this.isStartArrow = false,
    this.isKeyArrow = false,
    this.isTransformedToKey = false,
    this.lockId,
    this.rotationDegrees = 0.0,
  });

  List<ArrowDirection> get effectivePathPattern => pathPattern ?? [direction];

  ArrowState get effectiveState {
    if (isRemoved) return ArrowState.cleared;
    if (isLocked) return ArrowState.locked;
    if (isMoving) return ArrowState.moving;
    return state;
  }

  ArrowPiece copyWith({
    String? id,
    int? row,
    int? column,
    ArrowDirection? direction,
    List<ArrowDirection>? pathPattern,
    int? length,
    ArrowState? state,
    bool? isMoving,
    bool? isRemoved,
    bool? isHighlighted,
    bool? isLocked,
    bool? isStartArrow,
    bool? isKeyArrow,
    bool? isTransformedToKey,
    String? lockId,
    double? rotationDegrees,
  }) {
    return ArrowPiece(
      id: id ?? this.id,
      row: row ?? this.row,
      column: column ?? this.column,
      direction: direction ?? this.direction,
      pathPattern: pathPattern ?? this.pathPattern,
      length: length ?? this.length,
      state: state ?? this.state,
      isMoving: isMoving ?? this.isMoving,
      isRemoved: isRemoved ?? this.isRemoved,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isLocked: isLocked ?? this.isLocked,
      isStartArrow: isStartArrow ?? this.isStartArrow,
      isKeyArrow: isKeyArrow ?? this.isKeyArrow,
      isTransformedToKey: isTransformedToKey ?? this.isTransformedToKey,
      lockId: lockId ?? this.lockId,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'row': row,
        'column': column,
        'direction': direction.name,
        'pathPattern': pathPattern?.map((d) => d.name).toList(),
        'length': length,
        'state': effectiveState.name,
        'isMoving': isMoving,
        'isRemoved': isRemoved,
        'isHighlighted': isHighlighted,
        'isLocked': isLocked,
        'isStartArrow': isStartArrow,
        'isKeyArrow': isKeyArrow,
        'isTransformedToKey': isTransformedToKey,
        'lockId': lockId,
        'rotationDegrees': rotationDegrees,
      };

  factory ArrowPiece.fromJson(Map<String, dynamic> json) => ArrowPiece(
        id: json['id'] as String,
        row: json['row'] as int,
        column: json['column'] as int,
        direction: ArrowDirection.fromString(json['direction'] as String),
        pathPattern: (json['pathPattern'] as List<dynamic>?)
            ?.map((e) => ArrowDirection.fromString(e as String))
            .toList(),
        length: (json['length'] as int?) ?? 1,
        state: json['state'] != null
            ? ArrowState.values.firstWhere(
                (e) => e.name == json['state'],
                orElse: () => ArrowState.available,
              )
            : ArrowState.available,
        isMoving: json['isMoving'] as bool? ?? false,
        isRemoved: json['isRemoved'] as bool? ?? false,
        isHighlighted: json['isHighlighted'] as bool? ?? false,
        isLocked: json['isLocked'] as bool? ?? false,
        isStartArrow: json['isStartArrow'] as bool? ?? false,
        isKeyArrow: json['isKeyArrow'] as bool? ?? false,
        isTransformedToKey: json['isTransformedToKey'] as bool? ?? false,
        lockId: json['lockId'] as String?,
        rotationDegrees: (json['rotationDegrees'] as num?)?.toDouble() ?? 0.0,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArrowPiece &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          row == other.row &&
          column == other.column &&
          direction == other.direction &&
          isMoving == other.isMoving &&
          isRemoved == other.isRemoved &&
          isHighlighted == other.isHighlighted &&
          isLocked == other.isLocked &&
          isStartArrow == other.isStartArrow &&
          isKeyArrow == other.isKeyArrow &&
          isTransformedToKey == other.isTransformedToKey &&
          lockId == other.lockId &&
          rotationDegrees == other.rotationDegrees;

  @override
  int get hashCode =>
      id.hashCode ^
      row.hashCode ^
      column.hashCode ^
      direction.hashCode ^
      isMoving.hashCode ^
      isRemoved.hashCode ^
      isHighlighted.hashCode ^
      isLocked.hashCode ^
      isStartArrow.hashCode ^
      isKeyArrow.hashCode ^
      isTransformedToKey.hashCode ^
      lockId.hashCode ^
      rotationDegrees.hashCode;
}
