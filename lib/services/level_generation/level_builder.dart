
import '../../models/level.dart';
import 'difficulty_config.dart';
import 'layout_generator.dart';
import 'level_difficulty_analyzer.dart';
import 'level_validator.dart';
import 'passenger_generator.dart';
import 'seeded_random.dart';

class LevelBuilder {
  LevelBuilder._();

  /// Viimeksi valitun kentän vaikeusanalyysin tulos.
  static LevelDifficultyResult? lastDifficultyResult;

  /// Kuinka monta vaihtoehtoa generaattori enintään kokeilee.
  static const int maxGenerationAttempts = 50;

  /// Kuinka lähellä tavoitepisteitä tuloksen pitää olla,
  /// jotta lisäyrityksiä ei enää tarvita.
  static const int acceptableDifficultyDifference = 3;

  static Level build(int levelNumber) {
    if (levelNumber < 1) {
      throw ArgumentError.value(
        levelNumber,
        'levelNumber',
        'Level number must be at least 1.',
      );
    }

    lastDifficultyResult = null;

    final difficulty = difficultyForLevel(levelNumber);
    final targetScore = difficulty.targetDifficultyScore;

    Level? bestLevel;
    LevelDifficultyResult? bestResult;
    var bestDifference = 101;

    for (var attempt = 0;
        attempt < maxGenerationAttempts;
        attempt++) {
      final seed = (
        levelNumber * 7919 +
        104729 +
        attempt * 1047293
      ) & 0xFFFFFFFF;

      final random = SeededRandom(seed);

      final layout = LayoutGenerator.generate(
        level: levelNumber,
        random: random,
      );

      if (layout == null) {
        continue;
      }

      final generated = PassengerGenerator.generate(
        layout: layout,
        level: levelNumber,
        random: random,
      );

      final isValid = LevelValidator.validate(
        layout: layout,
        buses: generated.buses,
        queueA: generated.queueA,
        queueB: generated.queueB,
      );

      if (!isValid) {
        continue;
      }

      final difficultyResult = LevelDifficultyAnalyzer.analyze(
        buses: generated.buses,
        boardSize: difficulty.boardSize,
        exitOrder: layout.exitOrder,
        queueA: generated.queueA,
        queueB: generated.queueB,
      );

      final difference =
          (difficultyResult.score - targetScore).abs();

      if (difference < bestDifference) {
        bestDifference = difference;
        bestResult = difficultyResult;

        bestLevel = Level(
          number: levelNumber,
          boardSize: difficulty.boardSize,
          buses: generated.buses,
          queueA: generated.queueA,
          queueB: generated.queueB,
        );
      }

      if (difference <= acceptableDifficultyDifference) {
        break;
      }
    }

    if (bestLevel == null || bestResult == null) {
      throw StateError(
        'Could not generate a playable level: $levelNumber',
      );
    }

    lastDifficultyResult = bestResult;

    return bestLevel;
  }
}
