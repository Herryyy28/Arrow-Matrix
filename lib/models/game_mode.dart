enum GameMode {
  classic,
  daily,
  zen,
  timed,
  challenge,
}

extension GameModeExtension on GameMode {
  String get displayName {
    switch (this) {
      case GameMode.classic:
        return 'CLASSIC';
      case GameMode.daily:
        return 'DAILY CHALLENGE';
      case GameMode.zen:
        return 'ZEN MODE';
      case GameMode.timed:
        return 'TIMED RUSH';
      case GameMode.challenge:
        return 'CHALLENGE';
    }
  }

  String get description {
    switch (this) {
      case GameMode.classic:
        return 'Progress through standard levels at your own pace.';
      case GameMode.daily:
        return 'A unique puzzle every day. Keep your streak alive!';
      case GameMode.zen:
        return 'No heart loss. Infinite moves to solve at peace.';
      case GameMode.timed:
        return 'Beat the clock before time runs out!';
      case GameMode.challenge:
        return 'Strict move limits and high precision.';
    }
  }

  bool get hasHearts => this != GameMode.zen;
  bool get hasTimer => this == GameMode.timed;
}
