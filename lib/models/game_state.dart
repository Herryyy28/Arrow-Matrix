enum GameStateEnum {
  home,
  playing,
  paused,
  levelComplete,
  levelFailed,
}

class GameSnapshot {
  final List<dynamic> arrowsState;
  final int score;
  final int hearts;
  final int movesCount;
  final int mistakesCount;

  const GameSnapshot({
    required this.arrowsState,
    required this.score,
    required this.hearts,
    required this.movesCount,
    required this.mistakesCount,
  });
}
