
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

/// Palauttaa kentän tavoitevaikeuden väliltä 10–80.
///
/// Vaikeus kasvaa asteittain koko 2 000 kentän matkalla.
/// Myöhemmin LevelBuilder käyttää tätä arvoa valitessaan
/// vaikeusanalyysin perusteella sopivaa kenttärakennetta.
int targetDifficultyScoreForLevel(int level) {
  if (level < 1) {
    throw ArgumentError.value(
      level,
      'level',
      'Level number must be at least 1.',
    );
  }

  if (level <= 100) {
    return _interpolate(
      level,
      1,
      100,
      10,
      25,
    );
  }

  if (level <= 300) {
    return _interpolate(
      level,
      101,
      300,
      25,
      38,
    );
  }

  if (level <= 600) {
    return _interpolate(
      level,
      301,
      600,
      38,
      50,
    );
  }

  if (level <= 1000) {
    return _interpolate(
      level,
      601,
      1000,
      50,
      60,
    );
  }

  if (level <= 1500) {
    return _interpolate(
      level,
      1001,
      1500,
      60,
      68,
    );
  }

  if (level <= 1800) {
    return _interpolate(
      level,
      1501,
      1800,
      68,
      75,
    );
  }

  if (level <= 2000) {
    return _interpolate(
      level,
      1801,
      2000,
      75,
      80,
    );
  }

  // Yli 2 000 kentän vaikeus jatkaa kasvuaan
  // hitaammin, jotta järjestelmä on laajennettavissa.
  return _interpolate(
    level,
    2001,
    5000,
    80,
    95,
  );
}

int _interpolate(
  int level,
  int startLevel,
  int endLevel,
  int startScore,
  int endScore,
) {
  if (startLevel == endLevel) {
    return endScore;
  }

  final progress = level - startLevel;
  final range = endLevel - startLevel;

  return startScore +
      ((endScore - startScore) * progress ~/ range);
}

/// Palauttaa kentän rakenteelliset vaikeusasetukset.
LevelDifficulty difficultyForLevel(int level) {
  if (level < 1) {
    throw ArgumentError.value(
      level,
      'level',
      'Level number must be at least 1.',
    );
  }

  final targetScore = targetDifficultyScoreForLevel(level);

  if (level <= 20) {
    return LevelDifficulty(
      boardSize: 8,
      colorCount: 4,
      busCount: 12,
      customers: 100,
      stage: 'Alkuvaihe',
      targetDifficultyScore: targetScore,
    );
  }

  if (level <= 100) {
    return LevelDifficulty(
      boardSize: 10,
      colorCount: 5,
      busCount: 15,
      customers: 125,
      stage: 'Viisi väriä',
      targetDifficultyScore: targetScore,
    );
  }

  if (level <= 300) {
    return LevelDifficulty(
      boardSize: 12,
      colorCount: 6,
      busCount: 18,
      customers: 150,
      stage: 'Kuusi väriä',
      targetDifficultyScore: targetScore,
    );
  }

  if (level <= 600) {
    return LevelDifficulty(
      boardSize: 12,
      colorCount: 6,
      busCount: 18,
      customers: 150,
      stage: 'Kehittyminen',
      targetDifficultyScore: targetScore,
    );
  }

  if (level <= 1000) {
    return LevelDifficulty(
      boardSize: 14,
      colorCount: 7,
      busCount: 21,
      customers: 175,
      stage: 'Haaste',
      targetDifficultyScore: targetScore,
    );
  }

  if (level <= 1500) {
    return LevelDifficulty(
      boardSize: 14,
      colorCount: 7,
      busCount: 21,
      customers: 175,
      stage: 'Mestaruus',
      targetDifficultyScore: targetScore,
    );
  }

  if (level <= 1800) {
    return LevelDifficulty(
      boardSize: 16,
      colorCount: 8,
      busCount: 24,
      customers: 200,
      stage: 'Stella Expert',
      targetDifficultyScore: targetScore,
    );
  }

  return LevelDifficulty(
    boardSize: 16,
    colorCount: 8,
    busCount: 24,
    customers: 200,
    stage: 'Stella Master',
    targetDifficultyScore: targetScore,
  );
}
