import 'package:flutter/material.dart';

/// Categories for Shape-based puzzles.
enum ShapeCategory {
  animals,
  objects,
  nature,
  symbols,
  letters,
  numbers,
  master,
}

extension ShapeCategoryExtension on ShapeCategory {
  String get displayName {
    switch (this) {
      case ShapeCategory.animals:
        return 'Animals World';
      case ShapeCategory.objects:
        return 'Objects World';
      case ShapeCategory.nature:
        return 'Nature World';
      case ShapeCategory.symbols:
        return 'Symbols World';
      case ShapeCategory.letters:
        return 'Alphabet World';
      case ShapeCategory.numbers:
        return 'Numbers World';
      case ShapeCategory.master:
        return 'Master Shapes';
    }
  }

  IconData get icon {
    switch (this) {
      case ShapeCategory.animals:
        return Icons.pets;
      case ShapeCategory.objects:
        return Icons.category;
      case ShapeCategory.nature:
        return Icons.eco;
      case ShapeCategory.symbols:
        return Icons.stars;
      case ShapeCategory.letters:
        return Icons.sort_by_alpha;
      case ShapeCategory.numbers:
        return Icons.pin;
      case ShapeCategory.master:
        return Icons.workspace_premium;
    }
  }
}

/// Defines a vector silhouette & cell mask for an irregular puzzle board.
class ShapeDefinition {
  final String id;
  final String name;
  final ShapeCategory category;
  final int rows;
  final int cols;

  /// 2D boolean mask where true indicates a cell belongs to the playable silhouette.
  final List<List<bool>> playableMask;

  /// Optional normalized silhouette points (0.0 to 1.0) for high-precision outline painting.
  final List<Offset>? customOutlinePoints;

  final String difficulty;

  const ShapeDefinition({
    required this.id,
    required this.name,
    required this.category,
    required this.rows,
    required this.cols,
    required this.playableMask,
    this.customOutlinePoints,
    this.difficulty = 'Medium',
  });

  /// Check if a cell coordinate is active in this shape.
  bool isPlayable(int r, int c) {
    if (r < 0 || r >= rows || c < 0 || c >= cols) return false;
    return playableMask[r][c];
  }

  /// Create a ShapeDefinition from ASCII art strings.
  /// '1' or '#' means playable cell, '0' or '.' or ' ' means empty non-playable cell.
  factory ShapeDefinition.fromAscii({
    required String id,
    required String name,
    required ShapeCategory category,
    required List<String> asciiRows,
    String difficulty = 'Medium',
    List<Offset>? customOutlinePoints,
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

    return ShapeDefinition(
      id: id,
      name: name,
      category: category,
      rows: rows,
      cols: cols,
      playableMask: mask,
      customOutlinePoints: customOutlinePoints,
      difficulty: difficulty,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'rows': rows,
      'cols': cols,
      'playableMask': playableMask,
      'difficulty': difficulty,
    };
  }

  factory ShapeDefinition.fromJson(Map<String, dynamic> json) {
    final maskRaw = json['playableMask'] as List;
    final mask = maskRaw.map((row) => (row as List).map((cell) => cell as bool).toList()).toList();
    final catName = json['category'] as String? ?? 'symbols';
    final category = ShapeCategory.values.firstWhere(
      (e) => e.name == catName,
      orElse: () => ShapeCategory.symbols,
    );

    return ShapeDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      category: category,
      rows: json['rows'] as int,
      cols: json['cols'] as int,
      playableMask: mask,
      difficulty: json['difficulty'] as String? ?? 'Medium',
    );
  }
}

/// Hand-crafted Shape Library containing 20 curated shape definitions.
class ShapeLibrary {
  ShapeLibrary._();

  // 1. Heart
  static final ShapeDefinition heart = ShapeDefinition.fromAscii(
    id: 'shape_heart',
    name: 'Heart',
    category: ShapeCategory.symbols,
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

  // 2. Star
  static final ShapeDefinition star = ShapeDefinition.fromAscii(
    id: 'shape_star',
    name: 'Star',
    category: ShapeCategory.symbols,
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

  // 3. Fish
  static final ShapeDefinition fish = ShapeDefinition.fromAscii(
    id: 'shape_fish',
    name: 'Fish',
    category: ShapeCategory.animals,
    difficulty: 'Easy',
    asciiRows: [
      '0011100',
      '0111111',
      '1111101',
      '0111111',
      '0011100',
    ],
  );

  // 4. Bird
  static final ShapeDefinition bird = ShapeDefinition.fromAscii(
    id: 'shape_bird',
    name: 'Bird',
    category: ShapeCategory.animals,
    difficulty: 'Medium',
    asciiRows: [
      '0001100',
      '0111110',
      '1111100',
      '0011110',
      '0001111',
      '0000110',
    ],
  );

  // 5. Dog
  static final ShapeDefinition dog = ShapeDefinition.fromAscii(
    id: 'shape_dog',
    name: 'Dog',
    category: ShapeCategory.animals,
    difficulty: 'Medium',
    asciiRows: [
      '1100000',
      '1111000',
      '0111110',
      '0111111',
      '0101011',
      '0101000',
    ],
  );

  // 6. Cat
  static final ShapeDefinition cat = ShapeDefinition.fromAscii(
    id: 'shape_cat',
    name: 'Cat',
    category: ShapeCategory.animals,
    difficulty: 'Medium',
    asciiRows: [
      '10001',
      '11111',
      '11111',
      '01110',
      '01111',
      '01011',
    ],
  );

  // 7. Flower
  static final ShapeDefinition flower = ShapeDefinition.fromAscii(
    id: 'shape_flower',
    name: 'Flower',
    category: ShapeCategory.nature,
    difficulty: 'Medium',
    asciiRows: [
      '0110110',
      '1111111',
      '0111110',
      '1111111',
      '0110110',
      '0001000',
      '0001000',
    ],
  );

  // 8. Tree
  static final ShapeDefinition tree = ShapeDefinition.fromAscii(
    id: 'shape_tree',
    name: 'Tree',
    category: ShapeCategory.nature,
    difficulty: 'Medium',
    asciiRows: [
      '0001000',
      '0011100',
      '0111110',
      '1111111',
      '0011100',
      '0001000',
      '0001000',
    ],
  );

  // 9. House
  static final ShapeDefinition house = ShapeDefinition.fromAscii(
    id: 'shape_house',
    name: 'House',
    category: ShapeCategory.objects,
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

  // 10. Car
  static final ShapeDefinition car = ShapeDefinition.fromAscii(
    id: 'shape_car',
    name: 'Car',
    category: ShapeCategory.objects,
    difficulty: 'Medium',
    asciiRows: [
      '0011100',
      '0111110',
      '1111111',
      '1111111',
      '0100010',
    ],
  );

  // 11. Rocket
  static final ShapeDefinition rocket = ShapeDefinition.fromAscii(
    id: 'shape_rocket',
    name: 'Rocket',
    category: ShapeCategory.objects,
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

  // 12. Key
  static final ShapeDefinition key = ShapeDefinition.fromAscii(
    id: 'shape_key',
    name: 'Key',
    category: ShapeCategory.objects,
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

  // 13. Crown
  static final ShapeDefinition crown = ShapeDefinition.fromAscii(
    id: 'shape_crown',
    name: 'Crown',
    category: ShapeCategory.objects,
    difficulty: 'Hard',
    asciiRows: [
      '10101',
      '11111',
      '11111',
      '01110',
      '11111',
    ],
  );

  // 14. Music Note
  static final ShapeDefinition musicNote = ShapeDefinition.fromAscii(
    id: 'shape_music_note',
    name: 'Music Note',
    category: ShapeCategory.symbols,
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

  // 15. Letter A
  static final ShapeDefinition letterA = ShapeDefinition.fromAscii(
    id: 'shape_letter_a',
    name: 'Letter A',
    category: ShapeCategory.letters,
    difficulty: 'Easy',
    asciiRows: [
      '00100',
      '01010',
      '01110',
      '10001',
      '10001',
    ],
  );

  // 16. Letter M
  static final ShapeDefinition letterM = ShapeDefinition.fromAscii(
    id: 'shape_letter_m',
    name: 'Letter M',
    category: ShapeCategory.letters,
    difficulty: 'Medium',
    asciiRows: [
      '10001',
      '11011',
      '10101',
      '10001',
      '10001',
    ],
  );

  // 17. Butterfly
  static final ShapeDefinition butterfly = ShapeDefinition.fromAscii(
    id: 'shape_butterfly',
    name: 'Butterfly',
    category: ShapeCategory.animals,
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

  // 18. Lock
  static final ShapeDefinition lock = ShapeDefinition.fromAscii(
    id: 'shape_lock',
    name: 'Lock',
    category: ShapeCategory.objects,
    difficulty: 'Hard',
    asciiRows: [
      '01110',
      '10001',
      '10001',
      '11111',
      '11111',
      '11111',
    ],
  );

  // 19. Overlapping Heart & Arrow
  static final ShapeDefinition overlappingDual = ShapeDefinition.fromAscii(
    id: 'shape_heart_arrow',
    name: 'Heart & Arrow',
    category: ShapeCategory.master,
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

  // 20. Master Composite
  static final ShapeDefinition masterComposite = ShapeDefinition.fromAscii(
    id: 'shape_master_composite',
    name: 'Master Dragon',
    category: ShapeCategory.master,
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

  // 21. 3D Giraffe Silhouette
  static final ShapeDefinition giraffe3D = ShapeDefinition.fromAscii(
    id: 'shape_giraffe_3d',
    name: '3D Giraffe',
    category: ShapeCategory.animals,
    difficulty: 'Hard',
    asciiRows: [
      '00010100',
      '00011110',
      '00001100',
      '00001100',
      '00001100',
      '01111111',
      '11111111',
      '01001001',
      '01001001',
    ],
  );

  /// All 21 curated shapes in order.
  static final List<ShapeDefinition> allShapes = [
    heart,
    star,
    fish,
    bird,
    dog,
    cat,
    flower,
    tree,
    house,
    car,
    rocket,
    key,
    crown,
    musicNote,
    letterA,
    letterM,
    butterfly,
    lock,
    overlappingDual,
    masterComposite,
    giraffe3D,
  ];

  static ShapeDefinition? getById(String id) {
    try {
      return allShapes.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<ShapeDefinition> getByCategory(ShapeCategory category) {
    return allShapes.where((s) => s.category == category).toList();
  }
}
