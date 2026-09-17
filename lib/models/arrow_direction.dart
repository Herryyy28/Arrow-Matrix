import 'dart:math' as math;

enum ArrowDirection {
  up,
  down,
  left,
  right;

  int get dr {
    switch (this) {
      case ArrowDirection.up:
        return -1;
      case ArrowDirection.down:
        return 1;
      case ArrowDirection.left:
        return 0;
      case ArrowDirection.right:
        return 0;
    }
  }

  int get dc {
    switch (this) {
      case ArrowDirection.up:
        return 0;
      case ArrowDirection.down:
        return 0;
      case ArrowDirection.left:
        return -1;
      case ArrowDirection.right:
        return 1;
    }
  }

  double get rotationRadians {
    switch (this) {
      case ArrowDirection.up:
        return -math.pi / 2;
      case ArrowDirection.down:
        return math.pi / 2;
      case ArrowDirection.left:
        return math.pi;
      case ArrowDirection.right:
        return 0;
    }
  }

  static ArrowDirection fromString(String val) {
    switch (val.toLowerCase()) {
      case 'up':
        return ArrowDirection.up;
      case 'down':
        return ArrowDirection.down;
      case 'left':
        return ArrowDirection.left;
      case 'right':
      default:
        return ArrowDirection.right;
    }
  }
}
