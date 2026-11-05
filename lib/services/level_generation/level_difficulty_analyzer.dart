
import '../../models/bus.dart';
import '../game_service.dart';

enum LevelDifficultyRating {
  easy,
  normal,
  hard,
  expert,
}

class LevelDifficultyResult {
  final int score;
  final int initiallyAvailableBuses;
  final int blockedBuses;
  final int totalBuses;
  final LevelDifficultyRating rating;

  const LevelDifficultyResult({
    required this.score,
    required this.initiallyAvailableBuses,
    required this.blockedBuses,
    required this.totalBuses,
    required this.rating,
  });

  String get ratingLabel {
    switch (rating) {
      case LevelDifficultyRating.easy:
        return 'Easy';
      case LevelDifficultyRating.normal:
        return 'Normal';
      case LevelDifficultyRating.hard:
        return 'Hard';
      case LevelDifficultyRating.expert:
        return 'Expert';
    }
  }
}

class LevelDifficultyAnalyzer {
  LevelDifficultyAnalyzer._();

  static LevelDifficultyResult analyze({
    required List<Bus> buses,
    required int boardSize,
  }) {
    if (boardSize < 1) {
      throw ArgumentError.value(
        boardSize,
        'boardSize',
        'Board size must be at least 1.',
      );
    }

    if (buses.isEmpty) {
      return const LevelDifficultyResult(
        score: 0,
        initiallyAvailableBuses: 0,
        blockedBuses: 0,
        totalBuses: 0,
        rating: LevelDifficultyRating.easy,
      );
    }

    final initiallyAvailable = <Bus>[];

    for (final bus in buses) {
      final otherBuses = buses
          .where((other) => other.id != bus.id)
          .toList();

      if (GameService.canBusExit(
        bus: bus,
        otherBuses: otherBuses,
        boardSize: boardSize,
      )) {
        initiallyAvailable.add(bus);
      }
    }

    final availableCount = initiallyAvailable.length;
    final blockedCount = buses.length - availableCount;

    final score = _calculateScore(
      totalBuses: buses.length,
      availableBuses: availableCount,
      blockedBuses: blockedCount,
    );

    return LevelDifficultyResult(
      score: score,
      initiallyAvailableBuses: availableCount,
      blockedBuses: blockedCount,
      totalBuses: buses.length,
      rating: _ratingForScore(score),
    );
  }

  static int _calculateScore({
    required int totalBuses,
    required int availableBuses,
    required int blockedBuses,
  }) {
    if (totalBuses == 0) {
      return 0;
    }

    var score = 0;

    final blockedRatio = blockedBuses / totalBuses;

    score += (blockedRatio * 60).round();

    if (availableBuses <= 1) {
      score += 30;
    } else if (availableBuses == 2) {
      score += 20;
    } else if (availableBuses == 3) {
      score += 10;
    }

    if (totalBuses >= 18) {
      score += 10;
    } else if (totalBuses >= 12) {
      score += 5;
    }

    return score.clamp(0, 100).toInt();
  }

  static LevelDifficultyRating _ratingForScore(int score) {
    if (score < 25) {
      return LevelDifficultyRating.easy;
    }

    if (score < 50) {
      return LevelDifficultyRating.normal;
    }

    if (score < 75) {
      return LevelDifficultyRating.hard;
    }

    return LevelDifficultyRating.expert;
  }
}
