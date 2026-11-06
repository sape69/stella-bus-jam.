
import '../../models/bus.dart';
import '../../models/customer.dart';
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
  final int peakParkingOccupancy;
  final int waitingBusSteps;
  final int queueBlockedSteps;
  final LevelDifficultyRating rating;

  const LevelDifficultyResult({
    required this.score,
    required this.initiallyAvailableBuses,
    required this.blockedBuses,
    required this.totalBuses,
    required this.peakParkingOccupancy,
    required this.waitingBusSteps,
    required this.queueBlockedSteps,
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
    List<int>? exitOrder,
    List<Customer> queueA = const [],
    List<Customer> queueB = const [],
  }) {
    if (boardSize < 1) {
      throw ArgumentError.value(
        boardSize,
        'boardSize',
        'Board size must be at least 1.',
      );
    }

    if (exitOrder != null) {
      if (exitOrder.length != buses.length) {
        throw ArgumentError.value(
          exitOrder,
          'exitOrder',
          'Exit order must contain every bus exactly once.',
        );
      }

      final seenIndexes = <int>{};

      for (final index in exitOrder) {
        if (index < 0 ||
            index >= buses.length ||
            !seenIndexes.add(index)) {
          throw ArgumentError.value(
            exitOrder,
            'exitOrder',
            'Exit order contains an invalid or duplicate bus index.',
          );
        }
      }
    }

    if (buses.isEmpty) {
      return const LevelDifficultyResult(
        score: 0,
        initiallyAvailableBuses: 0,
        blockedBuses: 0,
        totalBuses: 0,
        peakParkingOccupancy: 0,
        waitingBusSteps: 0,
        queueBlockedSteps: 0,
        rating: LevelDifficultyRating.easy,
      );
    }

    final initiallyAvailableCount = buses.where((bus) {
      final otherBuses = buses
          .where((other) => other.id != bus.id)
          .toList();

      return GameService.canBusExit(
        bus: bus,
        otherBuses: otherBuses,
        boardSize: boardSize,
      );
    }).length;

    final blockedCount = buses.length - initiallyAvailableCount;

    final simulation = exitOrder == null
        ? const _BoardingSimulation(
            peakParkingOccupancy: 0,
            waitingBusSteps: 0,
            queueBlockedSteps: 0,
          )
        : _simulateBoarding(
            buses: buses,
            boardSize: boardSize,
            exitOrder: exitOrder,
            queueA: queueA,
            queueB: queueB,
          );

    final score = _calculateScore(
      totalBuses: buses.length,
      initiallyAvailableBuses: initiallyAvailableCount,
      blockedBuses: blockedCount,
      peakParkingOccupancy: simulation.peakParkingOccupancy,
      waitingBusSteps: simulation.waitingBusSteps,
      queueBlockedSteps: simulation.queueBlockedSteps,
    );

    return LevelDifficultyResult(
      score: score,
      initiallyAvailableBuses: initiallyAvailableCount,
      blockedBuses: blockedCount,
      totalBuses: buses.length,
      peakParkingOccupancy: simulation.peakParkingOccupancy,
      waitingBusSteps: simulation.waitingBusSteps,
      queueBlockedSteps: simulation.queueBlockedSteps,
      rating: _ratingForScore(score),
    );
  }

  static _BoardingSimulation _simulateBoarding({
    required List<Bus> buses,
    required int boardSize,
    required List<int> exitOrder,
    required List<Customer> queueA,
    required List<Customer> queueB,
  }) {
    final remainingBuses = List<Bus>.from(buses);

    var parking = List<Bus?>.filled(
      GameService.parkingSlots,
      null,
    );

    var remainingA = List<Customer>.from(queueA);
    var remainingB = List<Customer>.from(queueB);

    var peakParkingOccupancy = 0;
    var waitingBusSteps = 0;
    var queueBlockedSteps = 0;

    for (final busIndex in exitOrder) {
      final bus = buses[busIndex];

      final canExit = GameService.canBusExit(
        bus: bus,
        otherBuses: remainingBuses,
        boardSize: boardSize,
      );

      if (!canExit) {
        throw StateError(
          'Difficulty analysis received an invalid exit order.',
        );
      }

      final freeSlot = GameService.findFreeParkingSlot(parking);

      if (freeSlot == -1) {
        throw StateError(
          'Difficulty analysis exceeded available parking slots.',
        );
      }

      parking[freeSlot] = bus;

      remainingBuses.removeWhere(
        (remaining) => remaining.id == bus.id,
      );

      final occupiedBeforeBoarding =
          parking.where((parkedBus) => parkedBus != null).length;

      if (occupiedBeforeBoarding > peakParkingOccupancy) {
        peakParkingOccupancy = occupiedBeforeBoarding;
      }

      final result = GameService.processBoarding(
        parkingSlots: parking,
        queueA: remainingA,
        queueB: remainingB,
      );

      parking = result.parkingSlots;
      remainingA = result.queueA;
      remainingB = result.queueB;

      final waitingBuses =
          parking.where((parkedBus) => parkedBus != null).toList();

      waitingBusSteps += waitingBuses.length;

      final hasQueuedCustomers =
          remainingA.isNotEmpty || remainingB.isNotEmpty;

      if (waitingBuses.isNotEmpty && hasQueuedCustomers) {
        final hasMatchingQueueHead = waitingBuses.any((parkedBus) {
          if (parkedBus == null) return false;

          final matchesA = remainingA.isNotEmpty &&
              remainingA.first.color == parkedBus.color;

          final matchesB = remainingB.isNotEmpty &&
              remainingB.first.color == parkedBus.color;

          return matchesA || matchesB;
        });

        if (!hasMatchingQueueHead) {
          queueBlockedSteps++;
        }
      }
    }

    return _BoardingSimulation(
      peakParkingOccupancy: peakParkingOccupancy,
      waitingBusSteps: waitingBusSteps,
      queueBlockedSteps: queueBlockedSteps,
    );
  }

  static int _calculateScore({
    required int totalBuses,
    required int initiallyAvailableBuses,
    required int blockedBuses,
    required int peakParkingOccupancy,
    required int waitingBusSteps,
    required int queueBlockedSteps,
  }) {
    if (totalBuses == 0) return 0;

    final blockedRatio = blockedBuses / totalBuses;

    final parkingRatio =
        peakParkingOccupancy / GameService.parkingSlots;

    final waitingRatio = waitingBusSteps / (totalBuses * 2);

    final queueBlockedRatio = queueBlockedSteps / totalBuses;

    var score = (blockedRatio * 40).round();

    score += (parkingRatio * 20).round();

    score += (
      waitingRatio.clamp(0.0, 1.0) * 25
    ).round();

    score += (
      queueBlockedRatio.clamp(0.0, 1.0) * 15
    ).round();

    if (initiallyAvailableBuses <= 1) {
      score += 10;
    } else if (initiallyAvailableBuses == 2) {
      score += 6;
    } else if (initiallyAvailableBuses == 3) {
      score += 3;
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

class _BoardingSimulation {
  final int peakParkingOccupancy;
  final int waitingBusSteps;
  final int queueBlockedSteps;

  const _BoardingSimulation({
    required this.peakParkingOccupancy,
    required this.waitingBusSteps,
    required this.queueBlockedSteps,
  });
}
