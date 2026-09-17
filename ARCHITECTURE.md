# Architecture & Technical Design - Arrow Escape

## System Overview

Arrow Escape is built as a pure offline Flutter application using clean architecture principles and a feature-first folder organization.

```text
               +-----------------------+
               |     HomeScreen /      |
               |     GameScreen        |
               +-----------+-----------+
                           |
                           v
               +-----------------------+
               |    BoardController    |
               |   (ChangeNotifier)    |
               +-----+-----+-----+-----+
                     |     |     |
         +-----------+     |     +-----------+
         v                 v                 v
  +--------------+  +--------------+  +--------------+
  | PuzzleSolver |  | LevelGenerator| |StorageService|
  +--------------+  +--------------+  +--------------+
```

---

## Key Modules

### 1. Board & Raycasting Engine (`lib/models/board.dart`)
Path detection checks raycast vectors along `arrow.direction.dr` and `arrow.direction.dc` from the arrow's coordinates up to the board edge boundary `(0 <= r < rows)` and `(0 <= c < cols)`. If any active arrow exists in the ray, `canArrowExit()` returns `false`.

### 2. Solvability Solver (`lib/game/solver/puzzle_solver.dart`)
Uses recursive backtracking search to verify whether a board layout has at least one valid sequence of moves that clears all arrows.

### 3. Procedural Level Generator (`lib/game/generator/level_generator.dart`)
Generates arrow placements using reverse placement logic (placing arrows in reverse removal dependency order) and validates solvability using `PuzzleSolver.isSolvable()`.

### 4. Vector Renderer (`lib/game/arrows/arrow_painter.dart`)
Custom `CustomPainter` drawing scalable rounded pill containers, shafts, arrowheads, selection glows, and directional rotations.

### 5. Services Layer
- **`StorageService`**: `SharedPreferences` persistent storage wrapper.
- **`AudioService`**: Sound playback wrapper using system audio feedback.
- **`HapticService`**: Flutter haptics interface for vibration effects.
- **`AdsService`**: Modular interface ready for Google Mobile Ads integration.
