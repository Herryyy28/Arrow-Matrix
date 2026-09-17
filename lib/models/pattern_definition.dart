import 'package:flutter/material.dart';

/// Categories/Families for Pattern Engine 4.0 puzzles.
enum PatternFamily {
  organic,
  objects,
  symbols,
  abstract,
  letters,
  composite,
}

extension PatternFamilyExtension on PatternFamily {
  String get displayName {
    switch (this) {
      case PatternFamily.organic:
        return 'Organic Patterns';
      case PatternFamily.objects:
        return 'Object Silhouettes';
      case PatternFamily.symbols:
        return 'Symbolic Puzzles';
      case PatternFamily.abstract:
        return 'Abstract & Labyrinths';
      case PatternFamily.letters:
        return 'Alphabet & Numbers';
      case PatternFamily.composite:
        return 'Master Compositions';
    }
  }

  IconData get icon {
    switch (this) {
      case PatternFamily.organic:
        return Icons.pets_rounded;
      case PatternFamily.objects:
        return Icons.category_rounded;
      case PatternFamily.symbols:
        return Icons.stars_rounded;
      case PatternFamily.abstract:
        return Icons.all_inclusive_rounded;
      case PatternFamily.letters:
        return Icons.sort_by_alpha_rounded;
      case PatternFamily.composite:
        return Icons.workspace_premium_rounded;
    }
  }
}

/// Defines a vector pattern definition & cell topology mask for Pattern Engine 4.0.
class PatternDefinition {
  final String id;
  final String name;
  final PatternFamily family;
  final int rows;
  final int cols;
  final List<List<bool>> playableMask;
  final double complexityScore;
  final int targetDependencyDepth;
  final String difficulty;

  const PatternDefinition({
    required this.id,
    required this.name,
    required this.family,
    required this.rows,
    required this.cols,
    required this.playableMask,
    this.complexityScore = 5.0,
    this.targetDependencyDepth = 3,
    this.difficulty = 'Medium',
  });

  bool isPlayable(int r, int c) {
    if (r < 0 || r >= rows || c < 0 || c >= cols) return false;
    return playableMask[r][c];
  }

  factory PatternDefinition.fromAscii({
    required String id,
    required String name,
    required PatternFamily family,
    required List<String> asciiRows,
    double complexityScore = 5.0,
    int targetDependencyDepth = 3,
    String difficulty = 'Medium',
  }) {
    final rows = asciiRows.length;
    final cols = asciiRows.fold<int>(0, (max, line) => line.length > max ? line.length : max);
    final mask = List.generate(
      rows,
      (r) => List.generate(cols, (c) {
        if (c >= asciiRows[r].length) return false;
        final ch = asciiRows[r][c];
        return ch == '1' || ch == '#';
      }),
    );

    return PatternDefinition(
      id: id,
      name: name,
      family: family,
      rows: rows,
      cols: cols,
      playableMask: mask,
      complexityScore: complexityScore,
      targetDependencyDepth: targetDependencyDepth,
      difficulty: difficulty,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'family': family.name,
      'rows': rows,
      'cols': cols,
      'playableMask': playableMask,
      'complexityScore': complexityScore,
      'targetDependencyDepth': targetDependencyDepth,
      'difficulty': difficulty,
    };
  }

  factory PatternDefinition.fromJson(Map<String, dynamic> json) {
    final maskRaw = json['playableMask'] as List;
    final mask = maskRaw.map((row) => (row as List).map((cell) => cell as bool).toList()).toList();
    final familyName = json['family'] as String? ?? 'symbols';
    final family = PatternFamily.values.firstWhere(
      (e) => e.name == familyName,
      orElse: () => PatternFamily.symbols,
    );

    return PatternDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      family: family,
      rows: json['rows'] as int,
      cols: json['cols'] as int,
      playableMask: mask,
      complexityScore: (json['complexityScore'] as num?)?.toDouble() ?? 5.0,
      targetDependencyDepth: json['targetDependencyDepth'] as int? ?? 3,
      difficulty: json['difficulty'] as String? ?? 'Medium',
    );
  }
}

/// Hand-Crafted Pattern Engine 4.0 Library containing 20 curated dense pattern definitions.
class PatternLibrary {
  PatternLibrary._();

  // 1. Organic Dog
  static final PatternDefinition organicDog = PatternDefinition.fromAscii(
    id: 'pat_dog',
    name: 'Loyal Hound Pattern',
    family: PatternFamily.organic,
    complexityScore: 4.5,
    targetDependencyDepth: 3,
    difficulty: 'Easy',
    asciiRows: [
      '1100000',
      '1111000',
      '0111110',
      '0111111',
      '0101011',
      '0101000',
    ],
  );

  // 2. Organic Cat
  static final PatternDefinition organicCat = PatternDefinition.fromAscii(
    id: 'pat_cat',
    name: 'Feline Silhouette Pattern',
    family: PatternFamily.organic,
    complexityScore: 4.8,
    targetDependencyDepth: 3,
    difficulty: 'Easy',
    asciiRows: [
      '10001',
      '11111',
      '11111',
      '01110',
      '01111',
      '01011',
    ],
  );

  // 3. Organic Fish
  static final PatternDefinition organicFish = PatternDefinition.fromAscii(
    id: 'pat_fish',
    name: 'Ocean Reef Pattern',
    family: PatternFamily.organic,
    complexityScore: 5.0,
    targetDependencyDepth: 4,
    difficulty: 'Medium',
    asciiRows: [
      '0011100',
      '0111111',
      '1111101',
      '0111111',
      '0011100',
    ],
  );

  // 4. Organic Bird
  static final PatternDefinition organicBird = PatternDefinition.fromAscii(
    id: 'pat_bird',
    name: 'Wing Flight Pattern',
    family: PatternFamily.organic,
    complexityScore: 5.5,
    targetDependencyDepth: 4,
    difficulty: 'Medium',
    asciiRows: [
      '000110',
      '011110',
      '111110',
      '001110',
      '000111',
      '000011',
    ],
  );

  // 5. Organic Butterfly
  static final PatternDefinition organicButterfly = PatternDefinition.fromAscii(
    id: 'pat_butterfly',
    name: 'Butterfly Monarch Pattern',
    family: PatternFamily.organic,
    complexityScore: 6.8,
    targetDependencyDepth: 6,
    difficulty: 'Hard',
    asciiRows: [
      '1001001',
      '1101011',
      '1111111',
      '0111110',
      '1111111',
      '1101011',
      '1001001',
    ],
  );

  // 6. Object Rocket
  static final PatternDefinition objectRocket = PatternDefinition.fromAscii(
    id: 'pat_rocket',
    name: 'Cosmic Rocket Pattern',
    family: PatternFamily.objects,
    complexityScore: 6.2,
    targetDependencyDepth: 5,
    difficulty: 'Hard',
    asciiRows: [
      '00100',
      '01110',
      '01110',
      '01110',
      '11111',
      '10101',
    ],
  );

  // 7. Object Car
  static final PatternDefinition objectCar = PatternDefinition.fromAscii(
    id: 'pat_car',
    name: 'Speed Cruiser Pattern',
    family: PatternFamily.objects,
    complexityScore: 5.2,
    targetDependencyDepth: 4,
    difficulty: 'Medium',
    asciiRows: [
      '0011100',
      '0111110',
      '1111111',
      '1111111',
      '0100010',
    ],
  );

  // 8. Object House
  static final PatternDefinition objectHouse = PatternDefinition.fromAscii(
    id: 'pat_house',
    name: 'Architect House Pattern',
    family: PatternFamily.objects,
    complexityScore: 5.8,
    targetDependencyDepth: 4,
    difficulty: 'Medium',
    asciiRows: [
      '0001000',
      '0011100',
      '0111110',
      '1111111',
      '0111110',
      '0111110',
      '0111110',
    ],
  );

  // 9. Object Key
  static final PatternDefinition objectKey = PatternDefinition.fromAscii(
    id: 'pat_key',
    name: 'Golden Key Pattern',
    family: PatternFamily.objects,
    complexityScore: 7.0,
    targetDependencyDepth: 6,
    difficulty: 'Hard',
    asciiRows: [
      '01110',
      '10001',
      '10001',
      '01110',
      '00100',
      '00110',
      '00100',
      '00110',
    ],
  );

  // 10. Object Crown
  static final PatternDefinition objectCrown = PatternDefinition.fromAscii(
    id: 'pat_crown',
    name: 'Imperial Crown Pattern',
    family: PatternFamily.objects,
    complexityScore: 6.5,
    targetDependencyDepth: 5,
    difficulty: 'Hard',
    asciiRows: [
      '10101',
      '11111',
      '11111',
      '01110',
      '11111',
    ],
  );

  // 11. Symbol Heart
  static final PatternDefinition symbolHeart = PatternDefinition.fromAscii(
    id: 'pat_heart',
    name: 'Crystal Heart Pattern',
    family: PatternFamily.symbols,
    complexityScore: 4.2,
    targetDependencyDepth: 3,
    difficulty: 'Easy',
    asciiRows: [
      '0110110',
      '1111111',
      '1111111',
      '0111110',
      '0011100',
      '0001000',
    ],
  );

  // 12. Symbol Star
  static final PatternDefinition symbolStar = PatternDefinition.fromAscii(
    id: 'pat_star',
    name: 'Radiant Star Pattern',
    family: PatternFamily.symbols,
    complexityScore: 4.6,
    targetDependencyDepth: 3,
    difficulty: 'Easy',
    asciiRows: [
      '0001000',
      '0011100',
      '1111111',
      '0111110',
      '0110110',
      '1100011',
    ],
  );

  // 13. Symbol Lightning
  static final PatternDefinition symbolLightning = PatternDefinition.fromAscii(
    id: 'pat_lightning',
    name: 'Electric Pulse Pattern',
    family: PatternFamily.symbols,
    complexityScore: 6.6,
    targetDependencyDepth: 5,
    difficulty: 'Hard',
    asciiRows: [
      '00011',
      '00110',
      '01100',
      '11111',
      '00110',
      '01100',
      '11000',
    ],
  );

  // 14. Symbol Music Note
  static final PatternDefinition symbolMusicNote = PatternDefinition.fromAscii(
    id: 'pat_music_note',
    name: 'Symphony Clef Pattern',
    family: PatternFamily.symbols,
    complexityScore: 6.0,
    targetDependencyDepth: 4,
    difficulty: 'Medium',
    asciiRows: [
      '00011',
      '00011',
      '00010',
      '00010',
      '01110',
      '11110',
      '01100',
    ],
  );

  // 15. Abstract Spiral Labyrinth
  static final PatternDefinition abstractSpiral = PatternDefinition.fromAscii(
    id: 'pat_spiral',
    name: 'Spiral Labyrinth Pattern',
    family: PatternFamily.abstract,
    complexityScore: 8.2,
    targetDependencyDepth: 8,
    difficulty: 'Expert',
    asciiRows: [
      '1111111',
      '1000001',
      '1011101',
      '1010101',
      '1011101',
      '1000001',
      '1111111',
    ],
  );

  // 16. Abstract Infinite Knot
  static final PatternDefinition abstractKnot = PatternDefinition.fromAscii(
    id: 'pat_knot',
    name: 'Infinite Knot Pattern',
    family: PatternFamily.abstract,
    complexityScore: 8.6,
    targetDependencyDepth: 9,
    difficulty: 'Expert',
    asciiRows: [
      '0110110',
      '1111111',
      '1101011',
      '0111110',
      '1101011',
      '1111111',
      '0110110',
    ],
  );

  // 17. Letter A
  static final PatternDefinition letterA = PatternDefinition.fromAscii(
    id: 'pat_letter_a',
    name: 'Alpha A Pattern',
    family: PatternFamily.letters,
    complexityScore: 5.0,
    targetDependencyDepth: 3,
    difficulty: 'Easy',
    asciiRows: [
      '00100',
      '01010',
      '01110',
      '10001',
      '10001',
    ],
  );

  // 18. Letter M
  static final PatternDefinition letterM = PatternDefinition.fromAscii(
    id: 'pat_letter_m',
    name: 'Matrix M Pattern',
    family: PatternFamily.letters,
    complexityScore: 5.6,
    targetDependencyDepth: 4,
    difficulty: 'Medium',
    asciiRows: [
      '10001',
      '11011',
      '10101',
      '10001',
      '10001',
    ],
  );

  // 19. Composite Dual Heart Arrow
  static final PatternDefinition compositeHeartArrow = PatternDefinition.fromAscii(
    id: 'pat_dual_heart_arrow',
    name: 'Cupid Arrow & Heart',
    family: PatternFamily.composite,
    complexityScore: 9.0,
    targetDependencyDepth: 10,
    difficulty: 'Expert',
    asciiRows: [
      '001101100',
      '011111110',
      '111111111',
      '011111110',
      '001111100',
      '000111000',
      '000010000',
    ],
  );

  // 20. Master Composite Dragon
  static final PatternDefinition masterDragon = PatternDefinition.fromAscii(
    id: 'pat_master_dragon',
    name: 'Grand Dragon Sovereign',
    family: PatternFamily.composite,
    complexityScore: 9.8,
    targetDependencyDepth: 12,
    difficulty: 'Master',
    asciiRows: [
      '00011100',
      '00111110',
      '11111111',
      '01111110',
      '00111100',
      '01111110',
      '11111111',
      '11011011',
    ],
  );

  /// All 20 curated patterns in order.
  static final List<PatternDefinition> allPatterns = [
    symbolHeart,
    symbolStar,
    organicFish,
    organicBird,
    organicDog,
    organicCat,
    objectCar,
    objectHouse,
    objectKey,
    objectCrown,
    objectRocket,
    symbolLightning,
    symbolMusicNote,
    letterA,
    letterM,
    organicButterfly,
    abstractSpiral,
    abstractKnot,
    compositeHeartArrow,
    masterDragon,
  ];

  static PatternDefinition? getById(String id) {
    try {
      return allPatterns.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<PatternDefinition> getByFamily(PatternFamily family) {
    return allPatterns.where((p) => p.family == family).toList();
  }
}
