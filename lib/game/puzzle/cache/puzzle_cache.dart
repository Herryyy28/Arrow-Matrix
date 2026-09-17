import 'dart:convert';
import '../../../models/level_data.dart';
import '../../../services/storage_service.dart';

class PuzzleCache {
  final StorageService storageService;

  PuzzleCache(this.storageService);

  /// Checks if a validated level is stored in local cache.
  bool hasLevel(int levelNumber) {
    return storageService.hasCachedLevelJson(levelNumber);
  }

  /// Retrieves cached level data from local persistence, or null if cache miss.
  LevelData? getLevel(int levelNumber) {
    final jsonStr = storageService.getCachedLevelJson(levelNumber);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return LevelData.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Persists a validated level into local cache.
  Future<bool> saveLevel(LevelData level) async {
    final jsonStr = jsonEncode(level.toJson());
    return await storageService.saveCachedLevelJson(level.levelNumber, jsonStr);
  }
}
