
class LevelDifficulty {
  final int boardSize;
  final int colorCount;
  final int busCount;
  final int customers;
  final String stage;

  const LevelDifficulty({
    required this.boardSize,
    required this.colorCount,
    required this.busCount,
    required this.customers,
    required this.stage,
  });
}

LevelDifficulty difficultyForLevel(int level) {
  if (level <= 20) {
    return const LevelDifficulty(
      boardSize: 8,
      colorCount: 4,
      busCount: 12,
      customers: 100,
      stage: 'Alkuvaihe',
    );
  }

  if (level <= 100) {
    return const LevelDifficulty(
      boardSize: 10,
      colorCount: 5,
      busCount: 15,
      customers: 125,
      stage: 'Viisi väriä',
    );
  }

  if (level <= 300) {
    return const LevelDifficulty(
      boardSize: 12,
      colorCount: 6,
      busCount: 18,
      customers: 150,
      stage: 'Kuusi väriä',
    );
  }

  if (level <= 1000) {
    return const LevelDifficulty(
      boardSize: 14,
      colorCount: 7,
      busCount: 21,
      customers: 175,
      stage: 'Seitsemän väriä',
    );
  }

  return const LevelDifficulty(
    boardSize: 16,
    colorCount: 8,
    busCount: 24,
    customers: 200,
    stage: 'Kahdeksan väriä',
  );
}
