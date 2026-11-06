
import '../../models/level.dart';
import 'difficulty_config.dart';
import 'layout_generator.dart';
import 'level_difficulty_analyzer.dart';
import 'level_validator.dart';
import 'passenger_generator.dart';
import 'seeded_random.dart';

class LevelBuilder {
  LevelBuilder._();

  /// Viimeksi luodun tason vaikeusanalyysin tulos.
  static LevelDifficultyResult? lastDifficultyResult;

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

    for (var attempt = 0; attempt < 50; attempt++) {
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

      if (layout == null) continue;

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

      if (!isValid) continue;

      lastDifficultyResult = LevelDifficultyAnalyzer.analyze(
        buses: generated.buses,
        boardSize: difficulty.boardSize,
        exitOrder: layout.exitOrder,
        queueA: generated.queueA,
        queueB: generated.queueB,
      );

      return Level(
        number: levelNumber,
        boardSize: difficulty.boardSize,
        buses: generated.buses,
        queueA: generated.queueA,
        queueB: generated.queueB,
      );
    }

    throw StateError(
      'Could not generate a playable level: $levelNumber',
    );
  }
}
