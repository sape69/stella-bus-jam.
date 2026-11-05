
import 'package:flutter/material.dart';

import '../../models/bus.dart';
import '../../models/customer.dart';
import 'difficulty_config.dart';
import 'seeded_random.dart';
import 'vehicle_layout.dart';

class PassengerGenerationResult {
  final List<Bus> buses;
  final List<Customer> queueA;
  final List<Customer> queueB;

  const PassengerGenerationResult({
    required this.buses,
    required this.queueA,
    required this.queueB,
  });
}

class PassengerGenerator {
  PassengerGenerator._();

  static const List<Color> _colors = [
    Color(0xFFF05B68),
    Color(0xFF55A8FF),
    Color(0xFF55D69A),
    Color(0xFFFFD166),
    Color(0xFFB58CFF),
    Color(0xFFFF9D55),
    Color(0xFFFFB7E8),
    Color(0xFF5CE1E6),
  ];

  static PassengerGenerationResult generate({
    required VehicleBoardLayout layout,
    required int level,
    required SeededRandom random,
  }) {
    final difficulty = difficultyForLevel(level);

    final buses = List<Bus?>.filled(
      layout.vehicles.length,
      null,
    );

    final queueA = <Customer>[];
    final queueB = <Customer>[];

    const batchSize = 3;

    for (var batchStart = 0;
        batchStart < layout.exitOrder.length;
        batchStart += batchSize) {
      final batchCustomers = <Color>[];

      final batchEnd = (batchStart + batchSize)
          .clamp(0, layout.exitOrder.length);

      for (var step = batchStart; step < batchEnd; step++) {
        final vehicleIndex = layout.exitOrder[step];
        final vehicle = layout.vehicles[vehicleIndex];

        final color = _colors[
          step % difficulty.colorCount
        ];

        final capacity = _capacityForLength(vehicle.length);

        buses[vehicleIndex] = vehicle.toBus(
          id: 'bus_${vehicleIndex + 1}',
          color: color,
          capacity: capacity,
        );

        batchCustomers.addAll(
          List<Color>.filled(capacity, color),
        );
      }

      random.shuffle(batchCustomers);

      final minA = (batchCustomers.length * 0.35).floor();

      final maxA = (batchCustomers.length * 0.65)
          .ceil()
          .clamp(0, batchCustomers.length - 1);

      final aCount = minA +
          random.nextInt(maxA - minA + 1);

      final customersA = batchCustomers
          .take(aCount)
          .toList();

      final customersB = batchCustomers
          .skip(aCount)
          .toList();

      random.shuffle(customersA);
      random.shuffle(customersB);

      _appendCustomers(
        queueA,
        customersA,
        'A',
      );

      _appendCustomers(
        queueB,
        customersB,
        'B',
      );
    }

    return PassengerGenerationResult(
      buses: buses.cast<Bus>(),
      queueA: queueA,
      queueB: queueB,
    );
  }

  static int _capacityForLength(int length) {
    switch (length) {
      case 2:
        return 5;
      case 3:
        return 10;
      case 4:
        return 15;
      default:
        throw ArgumentError(
          'Unsupported bus length: $length',
        );
    }
  }

  static void _appendCustomers(
    List<Customer> target,
    List<Color> colors,
    String prefix,
  ) {
    final startPosition = target.length;

    for (var i = 0; i < colors.length; i++) {
      target.add(
        Customer(
          id: '${prefix}_${startPosition + i + 1}',
          color: colors[i],
          queuePosition: startPosition + i,
        ),
      );
    }
  }
}
