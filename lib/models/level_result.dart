class LevelResult {
  final int levelNumber;
  final int score;
  final int stars;
  final int moves;
  final int mistakes;
  final bool isDaily;

  const LevelResult({
    required this.levelNumber,
    required this.score,
    required this.stars,
    required this.moves,
    required this.mistakes,
    this.isDaily = false,
  });
}
