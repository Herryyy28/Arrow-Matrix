enum ArrowSpecialType {
  normal,
  locked,  // Requires prerequisite arrow or key to be cleared first
  ice,     // Covered in ice layer; requires 2 taps to break and escape
  rotator, // Rotates clockwise 90 degrees on tap before escaping
  switchArrow, // Toggles state/direction of adjacent arrows on exit
  portal,  // Teleports exit trajectory to matching portal cell
}

extension ArrowSpecialTypeExtension on ArrowSpecialType {
  String get displayName {
    switch (this) {
      case ArrowSpecialType.normal:
        return 'Normal Arrow';
      case ArrowSpecialType.locked:
        return 'Locked Arrow 🔒';
      case ArrowSpecialType.ice:
        return 'Ice Arrow 🧊';
      case ArrowSpecialType.rotator:
        return 'Rotator Arrow 🔄';
      case ArrowSpecialType.switchArrow:
        return 'Switch Arrow ⚡';
      case ArrowSpecialType.portal:
        return 'Portal Arrow 🌀';
    }
  }

  int get requiredWorld {
    switch (this) {
      case ArrowSpecialType.normal:
        return 1;
      case ArrowSpecialType.locked:
        return 2;
      case ArrowSpecialType.ice:
        return 3;
      case ArrowSpecialType.rotator:
        return 4;
      case ArrowSpecialType.switchArrow:
        return 5;
      case ArrowSpecialType.portal:
        return 6;
    }
  }
}
