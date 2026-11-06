
class LevelDifficulty {
  final int boardSize;
  final int colorCount;
  final int busCount;
  final int customers;
  final String stage;
  final int targetDifficultyScore;

  const LevelDifficulty({
    required this.boardSize,
    required this.colorCount,
    required this.busCount,
    required this.customers,
    required this.stage,
    required this.targetDifficultyScore,
  });
}

int targetDifficultyScoreForLevel(int level) {
  if (level < 1) {
    throw ArgumentError.value(
      level,
      'level',
      'Level must be at least 1.',
    );
  }

  if (level <= 20) {
    return 10 + ((level - 1) * 15 ~/ 19);
  }

  if (level <= 40) {
    return 26 + ((level - 21) * 9 ~/ 19);
  }

  if (level <= 60) {
    return 36 + ((level - 41) * 9 ~/ 19);
  }

  if (level <= 80) {
    return 46 + ((level - 61) * 9 ~/ 19);
  }

  if (level <= 100) {
    return 56 + ((level - 81) * 9 ~/ 19);
  }

  return 65 + ((level - 100) * 5 ~/ 100);
}

LevelDifficulty difficultyForLevel(int level) {
  if (level < 1) {
    throw ArgumentError.value(
      level,
      'level',
      'Level must be at least 1.',
    );
  }

  if (level <= 20) {
    return LevelDifficulty(
      boardSize: 8,
      colorCount: 4,
      busCount: 12,
      customers: 100,
      stage: 'Alkuvaihe',
      targetDifficultyScore:
          targetDifficultyScoreForLevel(level),
    );
  }

  if (level <= 100) {
    return LevelDifficulty(
      boardSize: 10,
      colorCount: 5,
      busCount: 15,
      customers: 125,
      stage: 'Viisi väriä',
      targetDifficultyScore:
          targetDifficultyScoreForLevel(level),
    );
  }

  if (level <= 300) {
    return LevelDifficulty(
      boardSize: 12,
      colorCount: 6,
      busCount: 18,
      customers: 150,
      stage: 'Kuusi väriä',
      targetDifficultyScore:
          targetDifficultyScoreForLevel(level),
    );
  }

  if (level <= 1000) {
    return LevelDifficulty(
      boardSize: 14,
      colorCount: 7,
      busCount: 21,
      customers: 175,
      stage: 'Seitsemän väriä',
      targetDifficultyScore:
          targetDifficultyScoreForLevel(level),
    );
  }

  return LevelDifficulty(
    boardSize: 16,
    colorCount: 8,
    busCount: 24,
    customers: 200,
    stage: 'Kahdeksan väriä',
    targetDifficultyScore:
        targetDifficultyScoreForLevel(level),
  );
}
