
import 'package:flutter_test/flutter_test.dart';

import 'package:stella_bus_jam/services/level_generation/difficulty_config.dart';
import 'package:stella_bus_jam/services/level_generation/level_builder.dart';

void main() {
  group('Level difficulty configuration', () {
    test('difficulty increases across 2000 levels', () {
      final checkpoints = [
        1,
        100,
        300,
        600,
        1000,
        1500,
        1800,
        2000,
      ];

      var previousScore = 0;

      for (final level in checkpoints) {
        final score = targetDifficultyScoreForLevel(level);

        expect(
          score,
          greaterThanOrEqualTo(previousScore),
          reason: 'Difficulty should not decrease at level $level.',
        );

        expect(
          score,
          inInclusiveRange(0, 100),
        );

        previousScore = score;
      }

      expect(targetDifficultyScoreForLevel(1), 10);
      expect(targetDifficultyScoreForLevel(100), 25);
      expect(targetDifficultyScoreForLevel(300), 38);
      expect(targetDifficultyScoreForLevel(600), 50);
      expect(targetDifficultyScoreForLevel(1000), 60);
      expect(targetDifficultyScoreForLevel(1500), 68);
      expect(targetDifficultyScoreForLevel(1800), 75);
      expect(targetDifficultyScoreForLevel(2000), 80);
    });

    test('difficulty continues beyond level 2000', () {
      expect(
        targetDifficultyScoreForLevel(2001),
        80,
      );

      expect(
        targetDifficultyScoreForLevel(5000),
        95,
      );
    });

    test('invalid level numbers are rejected', () {
      expect(
        () => difficultyForLevel(0),
        throwsArgumentError,
      );

      expect(
        () => targetDifficultyScoreForLevel(0),
        throwsArgumentError,
      );
    });

    test('difficulty configuration has valid values', () {
      for (final level in [
        1,
        20,
        21,
        100,
        101,
        300,
        301,
        600,
        601,
        1000,
        1001,
        1500,
        1501,
        1800,
        1801,
        2000,
      ]) {
        final difficulty = difficultyForLevel(level);

        expect(difficulty.boardSize, greaterThan(0));
        expect(difficulty.colorCount, greaterThan(0));
        expect(difficulty.busCount, greaterThan(0));
        expect(difficulty.customers, greaterThan(0));
        expect(difficulty.stage, isNotEmpty);

        expect(
          difficulty.targetDifficultyScore,
          targetDifficultyScoreForLevel(level),
        );
      }
    });
  });

  group('Level generation', () {
    test('generates playable levels at different stages', () {
      final levelsToGenerate = [
        1,
        100,
        1000,
        2000,
      ];

      for (final levelNumber in levelsToGenerate) {
        final level = LevelBuilder.build(levelNumber);

        expect(level.number, levelNumber);

        expect(
          level.boardSize,
          difficultyForLevel(levelNumber).boardSize,
        );

        expect(
          level.buses.length,
          difficultyForLevel(levelNumber).busCount,
        );

        expect(
          level.queueA.isNotEmpty || level.queueB.isNotEmpty,
          isTrue,
        );

        final result = LevelBuilder.lastDifficultyResult;

        expect(
          result,
          isNotNull,
          reason: 'Level $levelNumber must have difficulty analysis.',
        );

        expect(
          result!.score,
          inInclusiveRange(0, 100),
        );

        expect(
          result.totalBuses,
          level.buses.length,
        );
      }
    });
  });
}
