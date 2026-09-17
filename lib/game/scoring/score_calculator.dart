import '../../core/constants/app_constants.dart';

class ScoreCalculator {
  /// Calculates final level completion score.
  static int calculateFinalScore({
    required int arrowCount,
    required int mistakes,
    required int remainingHearts,
  }) {
    int total = arrowCount * AppConstants.scorePerArrow + AppConstants.scoreLevelComplete;

    if (mistakes == 0) {
      total += AppConstants.scoreNoMistakesBonus;
    }
    if (remainingHearts == AppConstants.maxHearts) {
      total += AppConstants.scoreFullHeartsBonus;
    }

    return total;
  }

  /// Evaluates star rating (1 to 3 stars).
  static int calculateStars({
    required int remainingHearts,
    required int mistakes,
  }) {
    if (remainingHearts >= 3 && mistakes == 0) {
      return 3;
    } else if (remainingHearts >= 2) {
      return 2;
    }
    return 1;
  }
}
