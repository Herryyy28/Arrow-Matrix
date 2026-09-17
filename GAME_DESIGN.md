# Game Design Document - Arrow Escape

## Core Concept
In **Arrow Escape**, the game board contains directional arrows pointing UP, DOWN, LEFT, or RIGHT. Players must clear all arrows from the board in the correct sequential order.

### Movement & Blocking Rules
1. **Clear Path**: An arrow can exit the board if every cell in front of it along its pointing vector to the grid boundary is empty.
2. **Blocked Path**: If any occupied cell or another arrow lies in front of it, the arrow is blocked.
3. **Invalid Taps**: Tapping a blocked arrow triggers a red shake feedback animation, plays an error sound/haptic, and decrements 1 heart.

---

## Game Loop & Systems

### 1. Heart System
- Each level starts with **3 Hearts** (`❤️ ❤️ ❤️`).
- Valid move: Arrow exits, board updates, no heart loss.
- Invalid move: -1 heart.
- Reaching 0 hearts triggers **Level Failed**.

### 2. Undo System
- Allows restoring previous board state snapshots.
- Up to **3 Undo charges** per level (`UNDO ×3`).
- Restores arrow positions, score, hearts, and move counts.

### 3. Hint System
- Up to **3 Hint charges** per level (`HINT ×3`).
- Uses `PuzzleSolver` to analyze the current board state and highlight a valid removable arrow.

### 4. Scoring & Star Ratings
- **Arrow Exit**: +10 pts
- **Level Complete**: +100 pts
- **No Mistakes Bonus**: +50 pts
- **Full Hearts Bonus**: +50 pts

**Star Ratings**:
- ⭐⭐⭐ **3 Stars**: Completed with 0 mistakes and 3 hearts remaining.
- ⭐⭐ **2 Stars**: Completed with 2 hearts remaining.
- ⭐ **1 Star**: Level completed.

---

## Difficulty Progression

- **Levels 1–25**: 5x5 Grid (Introductory & basic dependencies)
- **Levels 26–50**: 6x6 Grid (Intermediate depth)
- **Levels 51–75**: 7x7 Grid (Advanced multi-path dependencies)
- **Levels 76–100**: 8x8 Grid (Master dense arrow grids)
- **Daily Challenge**: 6x6 Grid with date-based seed string `YYYY-MM-DD`.
