import 'arrow_direction.dart';

enum PuzzleElementType {
  gate,
  switchElement,
  keyElement,
  portal,
  ice,
  obstacle,
}

class GateElement {
  final String id;
  final int row;
  final int col;
  final bool isOpen;
  final String? linkedSwitchId;

  const GateElement({
    required this.id,
    required this.row,
    required this.col,
    this.isOpen = false,
    this.linkedSwitchId,
  });

  GateElement copyWith({
    String? id,
    int? row,
    int? col,
    bool? isOpen,
    String? linkedSwitchId,
  }) {
    return GateElement(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      isOpen: isOpen ?? this.isOpen,
      linkedSwitchId: linkedSwitchId ?? this.linkedSwitchId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'row': row,
        'col': col,
        'isOpen': isOpen,
        'linkedSwitchId': linkedSwitchId,
      };

  factory GateElement.fromJson(Map<String, dynamic> json) => GateElement(
        id: json['id'] as String,
        row: json['row'] as int,
        col: json['col'] as int,
        isOpen: json['isOpen'] as bool? ?? false,
        linkedSwitchId: json['linkedSwitchId'] as String?,
      );
}

class SwitchElement {
  final String id;
  final int row;
  final int col;
  final bool isActivated;
  final String targetGateId;

  const SwitchElement({
    required this.id,
    required this.row,
    required this.col,
    this.isActivated = false,
    required this.targetGateId,
  });

  SwitchElement copyWith({
    String? id,
    int? row,
    int? col,
    bool? isActivated,
    String? targetGateId,
  }) {
    return SwitchElement(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      isActivated: isActivated ?? this.isActivated,
      targetGateId: targetGateId ?? this.targetGateId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'row': row,
        'col': col,
        'isActivated': isActivated,
        'targetGateId': targetGateId,
      };

  factory SwitchElement.fromJson(Map<String, dynamic> json) => SwitchElement(
        id: json['id'] as String,
        row: json['row'] as int,
        col: json['col'] as int,
        isActivated: json['isActivated'] as bool? ?? false,
        targetGateId: json['targetGateId'] as String,
      );
}

class KeyElement {
  final String id;
  final int row;
  final int col;
  final bool isCollected;
  final String targetLockId;

  const KeyElement({
    required this.id,
    required this.row,
    required this.col,
    this.isCollected = false,
    required this.targetLockId,
  });

  KeyElement copyWith({
    String? id,
    int? row,
    int? col,
    bool? isCollected,
    String? targetLockId,
  }) {
    return KeyElement(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      isCollected: isCollected ?? this.isCollected,
      targetLockId: targetLockId ?? this.targetLockId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'row': row,
        'col': col,
        'isCollected': isCollected,
        'targetLockId': targetLockId,
      };

  factory KeyElement.fromJson(Map<String, dynamic> json) => KeyElement(
        id: json['id'] as String,
        row: json['row'] as int,
        col: json['col'] as int,
        isCollected: json['isCollected'] as bool? ?? false,
        targetLockId: json['targetLockId'] as String,
      );
}

class PortalElement {
  final String id;
  final int row;
  final int col;
  final String targetPortalId;
  final ArrowDirection exitDirection;

  const PortalElement({
    required this.id,
    required this.row,
    required this.col,
    required this.targetPortalId,
    required this.exitDirection,
  });

  PortalElement copyWith({
    String? id,
    int? row,
    int? col,
    String? targetPortalId,
    ArrowDirection? exitDirection,
  }) {
    return PortalElement(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      targetPortalId: targetPortalId ?? this.targetPortalId,
      exitDirection: exitDirection ?? this.exitDirection,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'row': row,
        'col': col,
        'targetPortalId': targetPortalId,
        'exitDirection': exitDirection.name,
      };

  factory PortalElement.fromJson(Map<String, dynamic> json) => PortalElement(
        id: json['id'] as String,
        row: json['row'] as int,
        col: json['col'] as int,
        targetPortalId: json['targetPortalId'] as String,
        exitDirection: ArrowDirection.fromString(json['exitDirection'] as String),
      );
}

class IceCell {
  final int row;
  final int col;

  const IceCell({
    required this.row,
    required this.col,
  });

  Map<String, dynamic> toJson() => {'row': row, 'col': col};

  factory IceCell.fromJson(Map<String, dynamic> json) => IceCell(
        row: json['row'] as int,
        col: json['col'] as int,
      );
}

class ObstacleElement {
  final String id;
  final int row;
  final int col;

  const ObstacleElement({
    required this.id,
    required this.row,
    required this.col,
  });

  Map<String, dynamic> toJson() => {'id': id, 'row': row, 'col': col};

  factory ObstacleElement.fromJson(Map<String, dynamic> json) => ObstacleElement(
        id: json['id'] as String,
        row: json['row'] as int,
        col: json['col'] as int,
      );
}

class MovingWall {
  final String id;
  final int startRow;
  final int startCol;
  final int targetRow;
  final int targetCol;
  final bool isMoved;
  final String? linkedSwitchId;

  const MovingWall({
    required this.id,
    required this.startRow,
    required this.startCol,
    required this.targetRow,
    required this.targetCol,
    this.isMoved = false,
    this.linkedSwitchId,
  });

  int get currentDirectionRow => isMoved ? targetRow : startRow;
  int get currentDirectionCol => isMoved ? targetCol : startCol;

  MovingWall copyWith({
    String? id,
    int? startRow,
    int? startCol,
    int? targetRow,
    int? targetCol,
    bool? isMoved,
    String? linkedSwitchId,
  }) {
    return MovingWall(
      id: id ?? this.id,
      startRow: startRow ?? this.startRow,
      startCol: startCol ?? this.startCol,
      targetRow: targetRow ?? this.targetRow,
      targetCol: targetCol ?? this.targetCol,
      isMoved: isMoved ?? this.isMoved,
      linkedSwitchId: linkedSwitchId ?? this.linkedSwitchId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startRow': startRow,
        'startCol': startCol,
        'targetRow': targetRow,
        'targetCol': targetCol,
        'isMoved': isMoved,
        'linkedSwitchId': linkedSwitchId,
      };

  factory MovingWall.fromJson(Map<String, dynamic> json) => MovingWall(
        id: json['id'] as String,
        startRow: json['startRow'] as int,
        startCol: json['startCol'] as int,
        targetRow: json['targetRow'] as int,
        targetCol: json['targetCol'] as int,
        isMoved: json['isMoved'] as bool? ?? false,
        linkedSwitchId: json['linkedSwitchId'] as String?,
      );
}

class RotatingSection {
  final String id;
  final int row;
  final int col;
  final int angleDegrees; // 0, 90, 180, 270
  final String? linkedSwitchId;

  const RotatingSection({
    required this.id,
    required this.row,
    required this.col,
    this.angleDegrees = 0,
    this.linkedSwitchId,
  });

  RotatingSection copyWith({
    String? id,
    int? row,
    int? col,
    int? angleDegrees,
    String? linkedSwitchId,
  }) {
    return RotatingSection(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      angleDegrees: angleDegrees ?? this.angleDegrees,
      linkedSwitchId: linkedSwitchId ?? this.linkedSwitchId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'row': row,
        'col': col,
        'angleDegrees': angleDegrees,
        'linkedSwitchId': linkedSwitchId,
      };

  factory RotatingSection.fromJson(Map<String, dynamic> json) => RotatingSection(
        id: json['id'] as String,
        row: json['row'] as int,
        col: json['col'] as int,
        angleDegrees: json['angleDegrees'] as int? ?? 0,
        linkedSwitchId: json['linkedSwitchId'] as String?,
      );
}
