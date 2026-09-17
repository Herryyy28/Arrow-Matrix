import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_escape/services/storage_service.dart';
import 'package:arrow_escape/game/puzzle/repository/puzzle_repository.dart';
import 'package:arrow_escape/game/solver/puzzle_solver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;
  late PuzzleRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storageService = await StorageService.init();
    repository = PuzzleRepository(storageService: storageService);
  });

  group('PuzzleRepository & Engine Caching Tests', () {
    test('First install repository init generates and caches Levels 1 to 50', () async {
      expect(storageService.hasCachedLevelJson(1), isFalse);

      await repository.init();

      expect(repository.isInitialized, isTrue);
      expect(storageService.hasCachedLevelJson(1), isTrue);
      expect(storageService.hasCachedLevelJson(50), isTrue);

      final level1 = repository.getLevel(1);
      expect(level1.levelNumber, equals(1));
      expect(level1.initialArrows.length, greaterThanOrEqualTo(10));

      final board = level1.createInitialBoard();
      expect(PuzzleSolver.isSolvable(board), isTrue);
    });

    test('Deterministic seed reproducibility across restarts', () async {
      await repository.init();
      final levelA = repository.getLevel(25);

      // Re-instantiate repository simulating app restart
      final repoRestart = PuzzleRepository(storageService: storageService);
      final levelB = repoRestart.getLevel(25);

      expect(levelA.initialArrows.length, equals(levelB.initialArrows.length));
      expect(levelA.network?.startArrowId, equals(levelB.network?.startArrowId));
      expect(levelA.network?.keyArrowId, equals(levelB.network?.keyArrowId));
    });

    test('On-demand generation and solvability for Level 750 (Expert Packed)', () {
      final expertLevel = repository.getLevel(750);
      expect(expertLevel.levelNumber, equals(750));
      expect(expertLevel.initialArrows.length, greaterThanOrEqualTo(30));

      final board = expertLevel.createInitialBoard();
      expect(PuzzleSolver.isSolvable(board), isTrue);
    });
  });
}
