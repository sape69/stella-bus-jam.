import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  ProgressService._();

  static const String _unlockedLevelKey = 'unlocked_level';
  static const String _levelStarsPrefix = 'level_stars_';

  /// Returns the highest unlocked level.
  static Future<int> getUnlockedLevel() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getInt(_unlockedLevelKey) ?? 1;
  }

  /// Returns the best star result for a level.
  static Future<int> getStarsForLevel(int levelNumber) async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getInt(
          '$_levelStarsPrefix$levelNumber',
        ) ??
        0;
  }

  /// Returns the total number of stars collected.
  static Future<int> getTotalStars() async {
    final preferences = await SharedPreferences.getInstance();

    var totalStars = 0;

    for (final key in preferences.getKeys()) {
      if (key.startsWith(_levelStarsPrefix)) {
        totalStars += preferences.getInt(key) ?? 0;
      }
    }

    return totalStars;
  }

  /// Saves a completed level and unlocks the next one.
  /// Only the best star result for each level is retained.
  static Future<int> saveLevelCompletion({
    required int levelNumber,
    required int stars,
  }) async {
    if (levelNumber < 1) {
      throw ArgumentError.value(
        levelNumber,
        'levelNumber',
        'Level number must be at least 1.',
      );
    }

    final preferences = await SharedPreferences.getInstance();

    final safeStars = stars.clamp(1, 3).toInt();
    final starsKey = '$_levelStarsPrefix$levelNumber';

    final previousStars = preferences.getInt(starsKey) ?? 0;

    final bestStars =
        safeStars > previousStars ? safeStars : previousStars;

    if (bestStars > previousStars) {
      await preferences.setInt(starsKey, bestStars);
    }

    final currentUnlockedLevel =
        preferences.getInt(_unlockedLevelKey) ?? 1;

    final nextLevel = levelNumber + 1;

    if (nextLevel > currentUnlockedLevel) {
      await preferences.setInt(_unlockedLevelKey, nextLevel);
    }

    return bestStars;
  }

  /// Checks whether a level is unlocked.
  static Future<bool> isLevelUnlocked(int levelNumber) async {
    if (levelNumber < 1) {
      return false;
    }

    final unlockedLevel = await getUnlockedLevel();

    return levelNumber <= unlockedLevel;
  }
}