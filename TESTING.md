# Testing Strategy & Execution Guide

## Test Suite Overview

Arrow Escape features comprehensive test coverage including unit tests for core game logic, solvers, models, daily seeds, and widget tests for UI screens.

---

## Test Files

1. **`test/models_test.dart`**:
   - Direction vectors (`dr`, `dc`) and string conversions.
   - Unobstructed vs blocked path detection logic on grid.
   - Board cleared check.
   - Deterministic daily seed generation (`YYYY-MM-DD`).

2. **`test/puzzle_solver_test.dart`**:
   - Solvability verification algorithm.
   - Hint arrow calculation.
   - Level generator solvability checks for levels 1–100.

3. **`test/board_controller_test.dart`**:
   - Level loading and initialization.
   - Invalid move heart loss (-1 heart).
   - Valid move score increment (+10 pts) and undo history snapshots.
   - Score and star rating calculation.

4. **`test/widget_test.dart`**:
   - Home screen title, play button, and settings navigation.
   - Settings screen toggles and UI layout.

---

## Running Tests

Execute all tests via Flutter CLI:
```bash
flutter test
```

Execute specific test file:
```bash
flutter test test/board_controller_test.dart
```
