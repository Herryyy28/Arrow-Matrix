# Arrow Escape - 2D Flutter Puzzle Game

An original, offline-first 2D arrow-grid escape puzzle game built with Flutter and Dart.

## Project Overview

**Arrow Escape** is a sleek, modern puzzle game where players clear directional arrows from a grid board. An arrow can only exit the board when its entire path toward the outer boundary is completely unobstructed by other arrows.

- **100% Offline**: Zero external server, REST API, database, or authentication requirements.
- **Procedural & Guaranteed Solvable**: Features a reverse level generation engine and backtracking `PuzzleSolver` to guarantee 100% solvability for all levels and daily challenges.
- **Sleek Custom Visuals**: Built using pure Flutter native rendering (`CustomPainter` and Flutter `AnimationController`) for instant startup and fluid 60 FPS performance on mid-range Android devices.

---

## Features

- **100 Levels & Procedural Generator**: Progressive grid scaling (5x5 to 8x8) and difficulty depth.
- **Daily Challenge Engine**: Deterministic daily puzzle generation based on local calendar seed (`YYYY-MM-DD`) with streak tracking.
- **Heart & Life System**: 3 hearts per level, -1 heart on invalid moves (tapping blocked arrows).
- **Real Undo System**: Snapshot stack allowing up to 3 step restorations per level.
- **Hint System**: Integrates backtracking solver to highlight removable target arrows (up to 3 hints per level).
- **Full Settings & Dark Mode**: Responsive light & dark themes, audio, music, haptic vibration, and progress reset options.
- **Responsive Layout**: Designed with `SafeArea`, `LayoutBuilder`, and `MediaQuery` for phone and tablet screen support.

---

## Technical Stack & Architecture

- **Framework**: Flutter 3.x / Dart 3.x
- **State Management**: Clean `ChangeNotifier` pattern (`BoardController`)
- **Persistence**: `SharedPreferences` via `StorageService`
- **Vector Rendering**: Flutter `CustomPainter` (`ArrowPainter`)
- **Package ID**: `com.example.arrowescape`

---

## Quick Start & Run Commands

### 1. Fetch Dependencies
```bash
flutter pub get
```

### 2. Run Static Analyzer
```bash
flutter analyze
```

### 3. Run Unit & Widget Tests
```bash
flutter test
```

### 4. Run Application
```bash
flutter run
```

### 5. Build Release Android APK & App Bundle
```bash
flutter build apk --release
flutter build appbundle --release
```

---

## Project Structure

```text
lib/
├── core/
│   ├── constants/    # AppColors, AppConstants, GameConstants
│   ├── theme/        # AppTheme (Light & Dark mode)
│   └── utils/        # DailySeed generator
├── models/           # ArrowDirection, ArrowPiece, Board, LevelData, GameState
├── game/
│   ├── board/        # BoardController state machine
│   ├── generator/    # Solvability-guaranteed LevelGenerator
│   ├── solver/       # Backtracking PuzzleSolver
│   ├── arrows/       # Vector ArrowPainter
│   └── scoring/      # ScoreCalculator & star ratings
├── services/         # StorageService, AudioService, HapticService, AdsService
├── features/
│   ├── home/         # HomeScreen UI & stats
│   ├── gameplay/     # GameScreen, BoardWidget, TopBar, BottomBar, Pause
│   ├── level_complete/# LevelCompleteDialog celebration
│   ├── level_failed/ # LevelFailedDialog retry options
│   ├── daily_challenge/# DailyChallengeScreen
│   └── settings/     # SettingsScreen & progress reset
└── main.dart
```
