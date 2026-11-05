
import 'dart:math' as math;

import '../../models/bus.dart';
import 'difficulty_config.dart';
import 'seeded_random.dart';
import 'vehicle_layout.dart';

class LayoutGenerator {
  LayoutGenerator._();

  static VehicleBoardLayout? generate({
    required int level,
    required SeededRandom random,
    int maxAttempts = 500,
  }) {
    final difficulty = difficultyForLevel(level);

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final vehicles = <VehicleLayout>[];

      for (var i = 0; i < difficulty.busCount; i++) {
        final length = 2 + (i % 3);

        final candidates = _findCandidates(
          difficulty.boardSize,
          length,
          vehicles,
        );

        if (candidates.isEmpty) break;

        final scored = candidates.map((candidate) {
          return (
            vehicle: candidate,
            score: _scoreCandidate(
              candidate,
              vehicles,
              difficulty.boardSize,
              random,
            ),
          );
        }).toList();

        scored.sort((a, b) => b.score.compareTo(a.score));

        final shortlistSize = math.min(
          scored.length,
          math.max(4, (scored.length * 0.25).ceil()),
        );

        final selected =
            scored[random.nextInt(shortlistSize)].vehicle;

        vehicles.add(selected);
      }

      if (vehicles.length != difficulty.busCount) continue;

      final exitOrder = _findExitOrder(
        vehicles,
        difficulty.boardSize,
      );

      if (exitOrder != null) {
        return VehicleBoardLayout(
          boardSize: difficulty.boardSize,
          vehicles: vehicles,
          exitOrder: exitOrder,
        );
      }
    }

    return null;
  }

  static List<VehicleLayout> _findCandidates(
    int size,
    int length,
    List<VehicleLayout> existing,
  ) {
    final result = <VehicleLayout>[];

    for (final direction in BusExitDirection.values) {
      for (var y = 0; y < size; y++) {
        for (var x = 0; x < size; x++) {
          final candidate = VehicleLayout(
            x: x,
            y: y,
            direction: direction,
            length: length,
          );

          if (!_isInside(candidate, size)) continue;
          if (_overlaps(candidate, existing)) continue;
          if (!_hasClearExit(candidate, existing, size)) continue;

          result.add(candidate);
        }
      }
    }

    return result;
  }

  static bool _isInside(VehicleLayout vehicle, int size) {
    if (vehicle.x < 0 || vehicle.y < 0) return false;

    if (vehicle.direction == BusExitDirection.left ||
        vehicle.direction == BusExitDirection.right) {
      return vehicle.x + vehicle.length <= size &&
          vehicle.y < size;
    }

    return vehicle.y + vehicle.length <= size &&
        vehicle.x < size;
  }

  static List<BoardCell> _cells(VehicleLayout vehicle) {
    return List.generate(vehicle.length, (index) {
      if (vehicle.direction == BusExitDirection.left ||
          vehicle.direction == BusExitDirection.right) {
        return BoardCell(vehicle.x + index, vehicle.y);
      }

      return BoardCell(vehicle.x, vehicle.y + index);
    });
  }

  static bool _overlaps(
    VehicleLayout candidate,
    List<VehicleLayout> existing,
  ) {
    final occupied = _cells(candidate).toSet();

    for (final vehicle in existing) {
      for (final cell in _cells(vehicle)) {
        if (occupied.contains(cell)) return true;
      }
    }

    return false;
  }

  static bool _hasClearExit(
    VehicleLayout vehicle,
    List<VehicleLayout> existing,
    int size,
  ) {
    final ray = _exitRay(vehicle, size);

    for (final other in existing) {
      final occupied = _cells(other).toSet();

      for (final cell in ray) {
        if (occupied.contains(cell)) return false;
      }
    }

    return true;
  }

  static List<BoardCell> _exitRay(
    VehicleLayout vehicle,
    int size,
  ) {
    final result = <BoardCell>[];

    switch (vehicle.direction) {
      case BusExitDirection.right:
        for (var x = vehicle.x + vehicle.length; x < size; x++) {
          result.add(BoardCell(x, vehicle.y));
        }
        break;

      case BusExitDirection.left:
        for (var x = vehicle.x - 1; x >= 0; x--) {
          result.add(BoardCell(x, vehicle.y));
        }
        break;

      case BusExitDirection.down:
        for (var y = vehicle.y + vehicle.length; y < size; y++) {
          result.add(BoardCell(vehicle.x, y));
        }
        break;

      case BusExitDirection.up:
        for (var y = vehicle.y - 1; y >= 0; y--) {
          result.add(BoardCell(vehicle.x, y));
        }
        break;
    }

    return result;
  }

  static int _scoreCandidate(
    VehicleLayout candidate,
    List<VehicleLayout> existing,
    int size,
    SeededRandom random,
  ) {
    var blockedExits = 0;
    final candidateCells = _cells(candidate).toSet();

    for (final other in existing) {
      final ray = _exitRay(other, size);

      if (ray.any(candidateCells.contains)) {
        blockedExits++;
      }
    }

    final distance = switch (candidate.direction) {
      BusExitDirection.right =>
        size - candidate.x - candidate.length,
      BusExitDirection.left => candidate.x,
      BusExitDirection.down =>
        size - candidate.y - candidate.length,
      BusExitDirection.up => candidate.y,
    };

    return blockedExits * 100 +
        distance * 12 +
        (random.nextDouble() * 100).floor();
  }

  static List<int>? _findExitOrder(
    List<VehicleLayout> vehicles,
    int size,
  ) {
    final remaining = List<int>.generate(
      vehicles.length,
      (index) => index,
    );

    final order = <int>[];

    while (remaining.isNotEmpty) {
      var found = -1;

      for (final index in remaining) {
        final others = remaining
            .where((other) => other != index)
            .map((other) => vehicles[other])
            .toList();

        if (_hasClearExit(vehicles[index], others, size)) {
          found = index;
          break;
        }
      }

      if (found == -1) return null;

      order.add(found);
      remaining.remove(found);
    }

    return order;
  }
}
